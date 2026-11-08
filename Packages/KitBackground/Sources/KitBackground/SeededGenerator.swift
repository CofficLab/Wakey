import Foundation

/// 确定性随机源。
///
/// 背景粒子在 `body` 里取值。如果用系统随机源，`GeometryReader` 每次布局
/// 变化都会重新洗牌，窗口一缩放星星就会跳位置；静态视图重复渲染时也会。
/// 用「索引 + 固定盐」作为种子，同一个粒子在每次求值时都得到同样的值，
/// 图案保持稳定，同时不同粒子仍有差异。
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
