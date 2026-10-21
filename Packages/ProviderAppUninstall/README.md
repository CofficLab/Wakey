# ProviderAppUninstall

Wakey 卸载流程 Provider。

> 命名说明：LumiProviders 1.12.0 起自带 `ProviderUninstall` 目标。为避免 SPM
> 包图内目标重名（target name 必须全局唯一），本包改名为 `ProviderAppUninstall`。
> 两者行为不同：LumiProviders 版本硬编码 Lumi 品牌（通知名、确认短语、Bundle ID），
> 而本包为 Wakey 品牌实现。

## Package

- Product: `ProviderAppUninstall`
- Platform: macOS 14+
- Swift tools: 6.0

## 提供什么

<!-- TODO: 描述本包提供的功能 -->

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
