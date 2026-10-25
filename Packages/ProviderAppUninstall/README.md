# ProviderAppUninstall

Wakey 卸载流程 Provider。

> 命名说明：LumiProviders 1.12.0 起自带 `ProviderUninstall` 目标。为避免 SPM
> 包图内目标重名（target name 必须全局唯一），本包改名为 `ProviderAppUninstall`。
> 两者行为不同：LumiProviders 版本硬编码 Lumi 品牌（通知名、确认短语、Bundle ID），
> 而本包为 Wakey 品牌实现。
>
> **保持本地实现是有意为之（2026-10-25 确认）**：本包与 `LumiProviders` 的
> `ProviderUninstall` 协议与流程几乎逐行相同，仅品牌字符串与卸载白名单不同。
> 若直接改用远程版本，Wakey 的卸载界面会显示「Lumi 数据」「删除 Lumi 数据」，
> 且 `UninstallScope.production` 会指向 `com.coffic.lumi` 的 bundle ID——
> 卸载扫描将去动 Lumi 的数据目录（删错数据）。要合并必须先把品牌与 scope
> 在 LumiProviders 上游参数化并重新发版，该上游为 GameFactory / Netto /
> Kuzee / Cisum / GitOK 等仓库共用，发版影响面超出本仓库范围。

## Package

- Product: `ProviderAppUninstall`
- Platform: macOS 14+
- Swift tools: 6.0

## 提供什么

- `UninstallProviding`：卸载流程协议（预扫描 → 确认 → 执行）。
- `UninstallScope`：本应用的数据白名单（bundle ID / 偏好域 / 缓存域 / 旧版目录 / Keychain 服务）。
- `UninstallLocations`：文件系统位置集合，便于测试时注入临时目录。
- `DefaultUninstallProvider`：默认实现，只删白名单内的精确路径，不做模糊扫描。
- `Notification.Name.wakeyWillUninstall`：卸载前广播，让有异步写入的组件先落盘。

## 依赖与集成

```swift
dependencies: [
    .package(path: "../ProviderAppUninstall"),
],
targets: [
    .target(name: "YourTarget", dependencies: ["ProviderAppUninstall"]),
]
```

## Testing

From this package directory:

```sh
swift test
```
