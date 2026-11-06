import AppKit
import Foundation
import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import KitLayout

@Suite("Image 保存为 JPEG")
@MainActor
struct ImageSaveJpegTests {
    // MARK: - CGImage

    @Test("saveAsJpeg 按指定路径写入 CGImage")
    func savesCGImageToGivenURL() throws {
        // 沙盒应用不能静默写入「下载」目录（需要额外 entitlement），
        // 因此导出必须显式指定目标路径。
        let directory = try makeTemporaryDirectory("KitLayoutSave")
        defer { try? FileManager.default.removeItem(at: directory) }
        let target = directory.appendingPathComponent("c.jpeg")

        Image.saveAsJpeg(
            renderedImage(of: Color.red.frame(width: 8, height: 8)),
            saveTo: target
        )

        #expect(FileManager.default.fileExists(atPath: target.path))
        let source = CGImageSourceCreateWithURL(target as CFURL, nil)
        #expect(source != nil)
        let decoded = source.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }
        #expect(decoded != nil)
    }

    @Test("CGImage.saveAsJpeg 按指定路径写入")
    func cgImageSaveAsJpegExtension() throws {
        let directory = try makeTemporaryDirectory("KitLayoutSave")
        defer { try? FileManager.default.removeItem(at: directory) }
        let target = directory.appendingPathComponent("c.jpeg")

        renderedImage(of: Color.blue.frame(width: 8, height: 8)).saveAsJpeg(saveTo: target)

        #expect(FileManager.default.fileExists(atPath: target.path))
        let source = CGImageSourceCreateWithURL(target as CFURL, nil)
        #expect(source != nil)
    }

    // MARK: - NSImage

    @Test("saveAsJpeg 按指定路径写入 NSImage")
    func savesNSImageToGivenURL() throws {
        let directory = try makeTemporaryDirectory("KitLayoutSave")
        defer { try? FileManager.default.removeItem(at: directory) }

        let target = directory.appendingPathComponent("out.jpeg")
        let nsImage = NSImage(
            cgImage: renderedImage(of: Color.green.frame(width: 8, height: 8)),
            size: NSSize(width: 8, height: 8)
        )
        Image.saveAsJpeg(nsImage, saveTo: target)

        #expect(FileManager.default.fileExists(atPath: target.path))
        let source = CGImageSourceCreateWithURL(target as CFURL, nil)
        #expect(source != nil)
        let decoded = source.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }
        #expect(decoded != nil)
    }

    @Test("saveAsJpeg 省略路径时按时间戳写入下载目录")
    func savesNSImageToDownloadsByDefault() throws {
        guard let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let start = Date()
        let nsImage = NSImage(
            cgImage: renderedImage(of: Color.orange.frame(width: 8, height: 8)),
            size: NSSize(width: 8, height: 8)
        )
        Image.saveAsJpeg(nsImage)
        let end = Date()

        // 内部使用调用瞬间的时间戳命名，枚举该时间窗内的候选文件名。
        var candidates: [URL] = []
        var cursor = start.addingTimeInterval(-1)
        while cursor <= end.addingTimeInterval(1) {
            let name = "\(formatter.string(from: cursor)).jpeg"
            candidates.append(downloads.appendingPathComponent(name))
            cursor = cursor.addingTimeInterval(1)
        }

        let created = candidates.first { FileManager.default.fileExists(atPath: $0.path) }
        defer {
            if let created {
                try? FileManager.default.removeItem(at: created)
            }
        }
        #expect(created != nil)
    }

    @Test("无法转换位图时静默跳过，不产出文件")
    func skipsUnconvertibleImage() throws {
        let directory = try makeTemporaryDirectory("KitLayoutSave")
        defer { try? FileManager.default.removeItem(at: directory) }

        let target = directory.appendingPathComponent("empty.jpeg")
        // 空 NSImage 没有 tiffRepresentation，转换失败时直接返回。
        Image.saveAsJpeg(NSImage(), saveTo: target)
        #expect(FileManager.default.fileExists(atPath: target.path) == false)
    }

    @Test("写入失败时不会抛出异常")
    func swallowsWriteFailure() throws {
        let directory = try makeTemporaryDirectory("KitLayoutSave")
        defer { try? FileManager.default.removeItem(at: directory) }

        // 目标目录不存在，write 会失败并被内部捕获。
        let target = directory.appendingPathComponent("missing", isDirectory: true)
            .appendingPathComponent("out.jpeg")
        let nsImage = NSImage(
            cgImage: renderedImage(of: Color.purple.frame(width: 8, height: 8)),
            size: NSSize(width: 8, height: 8)
        )
        Image.saveAsJpeg(nsImage, saveTo: target)
        #expect(FileManager.default.fileExists(atPath: target.path) == false)
    }
}
