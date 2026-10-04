import Foundation
import LumiLocalizationKit

/// 插件作用域的本地化服务（绑定本模块资源 bundle）。
///
/// 由原 `LumiPluginLocalization` 转发 shim 收敛而来；调用点使用 `pluginLocalization.string(_:)`。
/// （Wakey 沿用该结构，仅保留模块自身的本地化键。）
public let pluginLocalization = PluginLocalization(bundle: .module)
