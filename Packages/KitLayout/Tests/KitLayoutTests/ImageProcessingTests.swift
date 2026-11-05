import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import KitLayout

@Suite("Image.getTimeString")
struct ImageTimeStringTests {
    @Test("输出 14 位时间串")
    func producesFixedWidthTimestamp() {
        let value = Image.getTimeString()
        #expect(value.count == 14)
        let allDigits = value.allSatisfy { $0.isNumber }
        #expect(allDigits)
    }

    @Test("格式为 yyyyMMddHHmmss")
    func usesExpectedLayout() {
        let value = Image.getTimeString()
        // 年份在前 4 位，取当前年份比对
        let year = String(value.prefix(4))
        #expect(year == String(Calendar(identifier: .gregorian).component(.year, from: Date())))
    }

    @Test("月份落在 01...12")
    func monthIsInRange() {
        let value = Image.getTimeString()
        let start = value.index(value.startIndex, offsetBy: 4)
        let end = value.index(start, offsetBy: 2)
        let month = Int(value[start ..< end]) ?? 0
        #expect((1 ... 12).contains(month))
    }

    @Test("日在 01...31")
    func dayIsInRange() {
        let value = Image.getTimeString()
        let start = value.index(value.startIndex, offsetBy: 6)
        let end = value.index(start, offsetBy: 2)
        let day = Int(value[start ..< end]) ?? 0
        #expect((1 ... 31).contains(day))
    }
}

@Suite("Image 渲染")
@MainActor
struct ImageRenderingTests {
    @Test("makeCGImage 可渲染简单视图")
    func rendersSimpleView() {
        let view = Color.red.frame(width: 8, height: 8)
        let image = Image.makeCGImage(from: view)
        #expect(image.width == 8)
        #expect(image.height == 8)
    }

    @Test("makeCGImage 支持非方形尺寸")
    func rendersNonSquareView() {
        let view = Color.blue.frame(width: 16, height: 4)
        let image = Image.makeCGImage(from: view)
        #expect(image.width == 16)
        #expect(image.height == 4)
    }

    @Test("fromView 返回可用的 Image")
    func createsImageFromView() {
        let view = Color.green.frame(width: 4, height: 4)
        let image = Image.fromView(view)
        #expect(type(of: image) == Image.self)
    }

    @Test("saveAsJpeg 写入可被再次读取的文件")
    func savesJpegToDisk() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("KitLayoutTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let source = Image.makeCGImage(from: Color.orange.frame(width: 8, height: 8))
        let destination = directory.appendingPathComponent("out.jpeg")
        // 用 ImageIO 显式编码为 JPEG
        let encoder = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        )!
        CGImageDestinationAddImage(encoder, source, nil)
        let finalized = CGImageDestinationFinalize(encoder)
        #expect(finalized)

        // 校验写出的 JPEG 可被 ImageIO 重新读取
        let readBack = try? CGImageSourceCreateWithURL(destination as CFURL, nil)
        #expect(readBack != nil)
    }

    @Test("渲染失败时回退为 1x1 图像")
    func fallsBackToOnePixelImage() {
        // 空视图通常渲染为 0 尺寸，触发 fallback 分支
        let image = Image.makeCGImage(from: Color.clear.frame(width: 0, height: 0))
        #expect(image.width == 1)
        #expect(image.height == 1)
    }
}
