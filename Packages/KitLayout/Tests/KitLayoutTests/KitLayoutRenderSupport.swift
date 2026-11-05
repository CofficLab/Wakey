import Foundation
import SwiftUI
@testable import KitLayout

// MARK: - 渲染辅助
//
// KitLayout 的扩展最终都落到 `ImageRenderer` 的产物上，
// 因此断言统一走「渲染成 CGImage 后读像素」这条路。

@MainActor
func renderedImage(of view: some View) -> CGImage {
    Image.makeCGImage(from: view)
}

@MainActor
func renderedSize(of view: some View) -> (width: Int, height: Int) {
    let image = renderedImage(of: view)
    return (image.width, image.height)
}

/// 读取 CGImage 的原始 RGBA 缓冲区（每像素 4 字节，premultipliedLast）。
@MainActor
func renderedBuffer(_ image: CGImage) -> [UInt8] {
    let width = image.width
    let height = image.height
    let bytesPerRow = width * 4
    var buffer = [UInt8](repeating: 0, count: bytesPerRow * height)
    guard let context = CGContext(
        data: &buffer,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return []
    }
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    return buffer
}

/// 读取单个像素。`y` 以图片顶部为 0。
@MainActor
func renderedPixel(_ image: CGImage, x: Int, y: Int) -> (r: Int, g: Int, b: Int, a: Int) {
    let buffer = renderedBuffer(image)
    let bytesPerRow = image.width * 4
    let index = y * bytesPerRow + x * 4
    guard index >= 0, index + 3 < buffer.count else { return (0, 0, 0, 0) }
    return (
        Int(buffer[index]),
        Int(buffer[index + 1]),
        Int(buffer[index + 2]),
        Int(buffer[index + 3])
    )
}

/// 读取单个像素的 alpha 通道。`y` 以图片顶部为 0。
@MainActor
func renderedAlpha(_ image: CGImage, x: Int, y: Int) -> Int {
    renderedPixel(image, x: x, y: y).a
}

/// 找出某一列上所有不透明像素占据的行区间。
@MainActor
func renderedRowRange(_ image: CGImage, x: Int) -> (first: Int, last: Int) {
    let buffer = renderedBuffer(image)
    let bytesPerRow = image.width * 4
    var first = -1
    var last = -1
    for y in 0 ..< image.height {
        let alpha = buffer[y * bytesPerRow + x * 4 + 3]
        if alpha > 0 {
            if first < 0 { first = y }
            last = y
        }
    }
    return (first, last)
}

/// 找出某一行上所有不透明像素占据的列区间。
@MainActor
func renderedColumnRange(_ image: CGImage, y: Int) -> (first: Int, last: Int) {
    let buffer = renderedBuffer(image)
    let bytesPerRow = image.width * 4
    var first = -1
    var last = -1
    for x in 0 ..< image.width {
        let alpha = buffer[y * bytesPerRow + x * 4 + 3]
        if alpha > 0 {
            if first < 0 { first = x }
            last = x
        }
    }
    return (first, last)
}

// MARK: - 临时目录辅助

func makeTemporaryDirectory(_ prefix: String) throws -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(prefix)-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}
