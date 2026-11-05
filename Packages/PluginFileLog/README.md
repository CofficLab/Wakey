# PluginFileLog

Wakey 磁盘日志插件（对齐 Lumi 的 `PluginFileLog`）。

> **重要规则：本插件包不能依赖其他插件包，也不能被其他插件包依赖。**
>
> 插件之间只通过 Provider 契约通信：共享能力放入 `Provider*` / `Kit*` 包，
> 由宿主（`Factory*`）统一装配；跨插件互相引用会破坏插件的独立装配与卸载。

## Package

- Product: `PluginFileLog`
- Platform: macOS 14+
- Swift tools: 6.0

## 提供什么

- 通过 `OSLogStore` 轮询订阅 `com.coffic.wakey`（及其子 subsystem）的系统日志，
  异步写入磁盘文件，支持按大小轮转与过期清理。
- 实现 `DiagnosticsProviding`（来自 `ProviderDiagnostics`），为设置页
  「通用 → 诊断日志 → 导出日志」提供打包好的 zip 诊断包（含 `manifest.json`）。
- 监听 `Notification.Name.wakeyWillUninstall`，在卸载前关闭文件句柄并 flush。

## 依赖与集成

```swift
dependencies: [
    .package(path: "../PluginFileLog"),
],
targets: [
    .target(name: "YourTarget", dependencies: ["PluginFileLog"]),
]
```

宿主需把它加入插件数组（`FactoryWakey.makePlugins()`），并在启动前注册
`StorageProviding`（日志目录由 `storage.pluginDataDirectory(for:)` 决定）。

## Testing

From this package directory:

```sh
swift test
```
