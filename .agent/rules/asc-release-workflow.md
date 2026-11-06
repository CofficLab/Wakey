# App Store Connect 提审规范

> 本规范记录 Wakey 在 App Store Connect（ASC）发布版本时踩的坑与正确流程。
> 适用于 macOS 平台应用（App ID `6758871065`，bundle id `com.coffic.wakey`）。

## 1. 提审前三步

标准顺序：**确认构建已处理完成 → 列出对应平台构建 → 关联构建 → 确认元数据和截图 → 提交审核**。

提交审核前必须逐项确认，缺一项都会被 Apple 拒绝：

| 检查项 | 如何确认 |
|---|---|
| 构建已关联 | `GET /v1/appStoreVersions/{id}/relationships/build` 返回非 null |
| 构建已处理 | `GET /v1/builds` 中该 build 的 `processingState == VALID` |
| 出口合规 | build 的 `usesNonExemptEncryption` 已声明（false = 不使用非豁免加密） |
| 本地化齐全 | `GET /v1/appStoreVersions/{id}/appStoreVersionLocalizations` |
| 截图齐全 | `GET /v1/appStoreVersionLocalizations/{id}/relationships/appScreenshotSets` |
| 年龄分级 | 见 §4（`socialMedia` 必须已设置，否则提审 409） |

## 2. `assign_build` 报 409，构建其实没被关联

**这个报错意味着构建关联根本没发生，不要以为「只差重新关联」。**

现象：

```
app_store_connect_assign_build(versionID=..., buildID=..., usesNonExemptEncryption=false)
→ "Failed to assign build: The provided entity includes an attribute with an invalid value:
   You cannot update when the value is already set."
```

根因：`assign_build` 的实现是**先更新出口合规、再关联构建**，任一步失败就整体中止：

```swift
if let usesNonExempt = parseBool(arguments["usesNonExemptEncryption"]) {
    try await client.updateBuildEncryption(buildID: buildID, usesNonExemptEncryption: usesNonExempt)
}
try await client.assignBuild(versionID: versionID, buildID: buildID)
```

当 build 的 `usesNonExemptEncryption` **已经**是 `false` 时，Apple 对同值 PATCH 返回 409：

```json
{
  "status": "409",
  "code": "ENTITY_ERROR.ATTRIBUTE.INVALID",
  "detail": "You cannot update when the value is already set.",
  "source": { "pointer": "/data/attributes/usesNonExemptEncryption" }
}
```

也就是说，**传了这个参数反而会让关联失败**。处置方式：调用 `assign_build` 时不要传
`usesNonExemptEncryption`，只传 `versionID` 与 `buildID`；出口合规若确需声明，单独
PATCH `/v1/builds/{id}`。

验证关联是否真的成功：

```bash
GET /v1/appStoreVersions/{id}/relationships/build
# => {"data":{"type":"builds","id":"<buildID>"}}   已关联
```

> 已上报上游：<https://github.com/CofficLab/Lumi/issues/667>

## 3. `submit_version` 报 "no build is assigned" 的真相

**这个报错是误导性的，不要据此重新关联构建。**

现象：

```
app_store_connect_assign_build  →  "Build ... assigned to version ..."（成功）
app_store_connect_submit_version →  "Cannot submit: no build is assigned ... Use assign-build first."
```

根因（已定位到 Lumi 源码）：**插件的缓存失效逻辑漏了一个分支**，不是「缓存过期」这么模糊。

1. 前置检查 `readAssignedBuildID` 发 GET `/v1/appStoreVersions/{id}/relationships/build`，
   该 GET 会被 `ConnectAPICache` 缓存，并打上 `.version(versionID)` 标签（standard 保留期，非 volatile）。
2. 关联动作 `assignBuild` 走 `requestWithoutResponse` → `cache.invalidateAfterMutation(method:path:body:)`。
3. `ConnectCacheInvalidator.invalidateAfterMutation` 的 switch 处理了
   `PATCH .../appStoreVersionLocalizations/`、`POST /v1/appScreenshotSets`、
   `POST /v1/appStoreVersions`、`DELETE /v1/appStoreVersions/...` 等，
   但**没有 `PATCH /v1/appStoreVersions/{id}/relationships/build` 分支** → 落到 `default: break` → 缓存不失效。
4. 于是关联之前缓存的 `{"data": null}` 继续被返回，前置检查据此判定「没关联构建」。

关键特征：**报错时没有发出任何 HTTP 请求**（查 NetworkManager 日志无 `reviewSubmissions` 相关记录），
说明是插件本地的**前置校验读取了陈旧缓存**，而非 Apple 的真实响应。

此时构建其实早已正确关联 —— 用 curl 直接查可证实：

```bash
GET /v1/appStoreVersions/{id}/relationships/build
# => {"data":{"type":"builds","id":"<buildID>"}}   已关联
```

**处置方式**：不要反复重试 `assign_build`（同值 PATCH 会 409，见 §2），直接走 §5 的 curl 流程提交。

> 已上报上游：<https://github.com/CofficLab/Lumi/issues/668>

## 4. 真正的常见阻塞项：年龄分级的 `socialMedia`

加入审核条目时 Apple 返回 409，真正的细节藏在 `meta.associatedErrors` 里：

```json
{
  "status": "409",
  "code": "STATE_ERROR.ENTITY_STATE_INVALID",
  "detail": "This resource cannot be reviewed, please check associated errors to see why.",
  "meta": { "associatedErrors": {
    "/v1/ageRatingDeclarations/<id>": [{
      "code": "ENTITY_ERROR.ATTRIBUTE.REQUIRED",
      "detail": "You must provide a value for the attribute 'socialMedia' with this request"
    }]
  }}
}
```

**`socialMedia` 是 BOOLEAN 类型**，不是枚举 —— 传 `"NONE"` 会报 `Unexpected json type provided`，
传 `null` 会报 `value cannot be null`，正确值是 `false`：

```bash
PATCH /v1/ageRatingDeclarations/<declarationID>
{"data":{"id":"<declarationID>","type":"ageRatingDeclarations","attributes":{"socialMedia":false}}}
```

该字段**不在 `app_store_connect_set_age_rating` 工具的参数列表里**（该工具只暴露 11 个枚举字段
+ 3 个布尔字段 `gambling` / `seventeenPlus` / `unrestrictedWebAccess`），所以用内置工具永远补不上，
必须走 API。

实际核对 Apple 返回的完整字段列表，共有 **14 个字段**工具无法设置：

- 布尔类：`socialMedia`、`advertising`、`healthOrWellnessTopics`、`lootBox`、`messagingAndChat`、
  `parentalControls`、`ageAssurance`、`socialMediaAgeRestricted`、`userGeneratedContent`
- 枚举类：`gunsOrOtherWeapons`、`matureOrSuggestiveThemes`、`ageRatingOverride`、
  `ageRatingOverrideV2`、`koreaAgeRatingOverride`

注意 `ageRatingDeclarations` 只允许 `UPDATE`（`GET_INSTANCE` 返回 403），无法读回当前值，只能按需 PATCH。

年龄分级声明是**应用级**的（与版本共享），所有版本共用一份 —— 所以缺字段会阻塞该应用的**每一次**提审。

> 已上报上游：<https://github.com/CofficLab/Lumi/issues/669>

## 5. curl 直连 ASC 调试流程

内置工具返回的错误含糊、需要 Apple 原始 JSON、或需要探测工具未覆盖的端点时使用。

### 取凭据（macOS 钥匙串，服务 `com.coffic.lumi.appstoreconnect`）

```bash
ISSUER=$(security find-generic-password -s com.coffic.lumi.appstoreconnect -a appStoreConnect.issuerID -w)
KEY_ID=$(security find-generic-password -s com.coffic.lumi.appstoreconnect -a appStoreConnect.keyID -w)
PRIVATE_KEY=$(security find-generic-password -s com.coffic.lumi.appstoreconnect -a appStoreConnect.privateKey -w)
```

私钥可能是十六进制编码（不是明文 PEM），JWT 脚本会自动还原。签名必须是原始 `r||s` 拼接，不能直接用
`openssl dgst -sign` 的 DER 输出。完整可用的 JWT 生成脚本见 Lumi 插件包的
`PluginAppStoreConnect_PluginAppStoreConnect.bundle/Contents/Resources/Skills/app-store-connect/SKILL.md`。

### 自己写 JWT 脚本时的坑：DER 前导零

**用 `int.to_bytes(32, "big")`，不要用 `bytes.rjust(32, b"\x00")`。**

`openssl dgst -sign` 输出的 DER 里，r / s 是可变长度的整数，约一半情况下带一个 `0x00` 正数标记
（33 字节）。`rjust` 只在**短于** 32 字节时补齐，**不会截断** 33 字节的值，于是签名变成 65/66 字节 ——
不是合法的 64 字节 ES256 签名。Apple 会间歇性返回 `401 NOT_AUTHORIZED`。

实测对比（同一把密钥、同一端点、25 次采样）：

```
rjust 补齐（错误）  -> {401: 22, 200: 3}     约 3/4 的请求失败
int.to_bytes(32)    -> {200: 25}            全部成功
```

错误写法的签名长度会随机变成 64 / 65 / 66 字节（取决于 r、s 是否带前导零），
这也是断言 `len(sig) == 64` 能立刻抓出问题的原因。

注意这**不是** ECDSA「高 S 值」问题（那个说法流传很广，但实测与 401 无关）。Lumi 官方 SKILL.md 里的
脚本用的是 `int.to_bytes(32)`，是正确的 —— 只有自己另写脚本时容易踩这个坑。

### 提审三步（`submit_version` 失效时的替代路径）

**① 创建提交**

```bash
POST /v1/reviewSubmissions
{"data":{"type":"reviewSubmissions","relationships":{"app":{"data":{"type":"apps","id":"<appID>"}}}}}
```

**② 加入版本** —— 必须**同时**带 `reviewSubmission` 与 `appStoreVersion` 两个关系，只带后者会报
`ENTITY_ERROR.RELATIONSHIP.REQUIRED`（缺 `reviewSubmission`）：

```bash
POST /v1/reviewSubmissionItems
{"data":{"type":"reviewSubmissionItems","relationships":{
  "reviewSubmission":{"data":{"type":"reviewSubmissions","id":"<submissionID>"}},
  "appStoreVersion":{"data":{"type":"appStoreVersions","id":"<versionID>"}}}}}
```

**③ 标记提交**

```bash
PATCH /v1/reviewSubmissions/<submissionID>
{"data":{"id":"<submissionID>","type":"reviewSubmissions","attributes":{"submitted":true}}}
```

成功后 `state` 变为 `WAITING_FOR_REVIEW`。

## 6. 查询某个版本是否在途

旧端点已废弃（`POST /v1/appStoreVersionSubmissions` 返回 403）：

- `GET /v1/apps/{id}/appStoreVersionSubmissions` → 404
- `GET /v1/appStoreVersions/{id}/relationships/appStoreVersionSubmission` → 404

正确做法：列出应用的所有提交，逐个查 items 是否包含目标版本：

```bash
GET /v1/apps/{id}/reviewSubmissions
GET /v1/reviewSubmissions/{id}/items
```

状态语义：`READY_FOR_REVIEW` / `WAITING_FOR_REVIEW` / `IN_REVIEW` / `UNRESOLVED_ISSUES` / `COMPLETING` 算在途；`COMPLETE` / `CANCELING` 是终态。

## 7. 版本号不可修改

Apple 不允许修改已创建版本的 `versionString`。需要改号时：

1. `app_store_connect_delete_version` 删除**进行中**的草稿版本
2. `app_store_connect_create_version` 用新版本号重建
3. 重新做本地化与截图关联

## 8. 发布类型

- `AFTER_APPROVAL`：通过审核后自动发布（Wakey 当前使用）
- `MANUAL`：通过后需手动点发布
- `SCHEDULED`：需配 `earliestReleaseDate`

## 相关规范

- [插件包目录结构规范](./plugin-package-structure.md)
- 商店文案的多语言要求见项目记忆 `wakey-i18n-conventions`（默认英语，zh-Hans / zh-HK 需完整翻译）
