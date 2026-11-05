import Foundation
import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import KitLayout

@Suite("View 快照")
@MainActor
struct ViewSnapshotTests {
    // MARK: - 尺寸与转换

    @Test("getWidth 返回渲染宽度")
    func getWidth() {
        let width = Color.red.frame(width: 12, height: 30).getWidth()
        #expect(width == 12)
    }

    @Test("getHeight 返回渲染高度")
    func getHeight() {
        let height = Color.red.frame(width: 12, height: 30).getHeight()
        #expect(height == 30)
    }

    @Test("toImage 返回 Image 对象")
    func toImage() {
        let image = Color.red.frame(width: 4, height: 4).toImage()
        #expect(type(of: image) == Image.self)
    }

    @Test("toCGImage 返回与渲染一致的位图")
    func toCGImage() {
        let cgImage = Color.red.frame(width: 6, height: 9).toCGImage()
        #expect(cgImage.width == 6)
        #expect(cgImage.height == 9)
    }

    // MARK: - 落盘

    @Test("snapshot 按标题写入 PNG")
    func snapshotWritesPng() throws {
        let directory = try makeTemporaryDirectory("KitLayoutSnapshot")
        defer { try? FileManager.default.removeItem(at: directory) }

        let target = directory.appendingPathComponent("shot.png")
        try Color.red.frame(width: 10, height: 10).snapshot(path: target, title: "shot")

        #expect(FileManager.default.fileExists(atPath: target.path))
        let source = CGImageSourceCreateWithURL(target as CFURL, nil)
        #expect(source != nil)
        let decoded = CGImageSourceCreateImageAtIndex(source!, 0, nil)
        #expect(decoded != nil)
        let width = decoded?.width ?? 0
        #expect(width >= 10)
    }

    @Test("snapshot 省略 path 时写入下载目录")
    func snapshotDefaultsToDownloads() throws {
        guard let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return
        }
        let before = Image.getTimeString()
        try Color.red.frame(width: 10, height: 10).snapshot()
        let after = Image.getTimeString()

        // 文件名形如 "<时间戳>-<宽>x<高>.png"
        var created: URL?
        for stamp in [before, after] {
            let candidate = downloads.appendingPathComponent("\(stamp)-10x10.png")
            if FileManager.default.fileExists(atPath: candidate.path) {
                created = candidate
                break
            }
        }
        defer {
            if let created {
                try? FileManager.default.removeItem(at: created)
            }
        }
        #expect(created != nil)
    }

    @Test("snapshot 支持显式缩放倍数")
    func snapshotRespectsScale() throws {
        let directory = try makeTemporaryDirectory("KitLayoutSnapshot")
        defer { try? FileManager.default.removeItem(at: directory) }

        let single = directory.appendingPathComponent("s1.png")
        let double = directory.appendingPathComponent("s2.png")
        try Color.red.frame(width: 10, height: 10).snapshot(path: single, title: "s1", scale: 1)
        try Color.red.frame(width: 10, height: 10).snapshot(path: double, title: "s2", scale: 2)

        let first = CGImageSourceCreateWithURL(single as CFURL, nil)
        let second = CGImageSourceCreateWithURL(double as CFURL, nil)
        let firstImage = first.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }
        let secondImage = second.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }
        #expect(firstImage?.width == 10)
        #expect(firstImage?.height == 10)
        #expect(secondImage?.width == 20)
        #expect(secondImage?.height == 20)
    }

    @Test("snapshot 默认缩放使用渲染器默认值，不会失败")
    func snapshotDefaultScaleSucceeds() throws {
        let directory = try makeTemporaryDirectory("KitLayoutSnapshot")
        defer { try? FileManager.default.removeItem(at: directory) }

        let target = directory.appendingPathComponent("default.png")
        try Color.red.frame(width: 10, height: 10).snapshot(path: target, title: "default")
        #expect(FileManager.default.fileExists(atPath: target.path))
    }

    // MARK: - 失败路径

    @Test("渲染失败时抛出 imageRenderFailed")
    func throwsWhenRenderFails() {
        let directory = try? makeTemporaryDirectory("KitLayoutSnapshot")
        defer {
            if let directory {
                try? FileManager.default.removeItem(at: directory)
            }
        }
        let target = directory?.appendingPathComponent("empty.png")

        var thrown: SnapshotError?
        do {
            try Color.clear.frame(width: 0, height: 0).snapshot(path: target, title: "empty")
        } catch let error as SnapshotError {
            thrown = error
        } catch {
            thrown = nil
        }
        guard case .imageRenderFailed = thrown else {
            Issue.record("期望抛出 imageRenderFailed，实际为 \(String(describing: thrown))")
            return
        }
    }

    @Test("目标目录不存在时抛出 destinationCreateFailed")
    func throwsWhenDestinationInvalid() {
        let directory = try? makeTemporaryDirectory("KitLayoutSnapshot")
        defer {
            if let directory {
                try? FileManager.default.removeItem(at: directory)
            }
        }
        let target = directory?
            .appendingPathComponent("missing", isDirectory: true)
            .appendingPathComponent("out.png")

        var thrown: SnapshotError?
        do {
            try Color.red.frame(width: 10, height: 10).snapshot(path: target, title: "out")
        } catch let error as SnapshotError {
            thrown = error
        } catch {
            thrown = nil
        }
        guard case .destinationCreateFailed = thrown else {
            Issue.record("期望抛出 destinationCreateFailed，实际为 \(String(describing: thrown))")
            return
        }
    }

    @Test("目标目录不可写时在创建目标阶段就失败")
    func failsWhenDirectoryNotWritable() {
        let directory = try? makeTemporaryDirectory("KitLayoutSnapshot")
        defer {
            if let directory {
                try? FileManager.default.removeItem(at: directory)
            }
        }
        guard let directory else { return }

        // 目录存在但不可写：ImageIO 在创建目标时就返回 nil，
        // 因此抛出的是 destinationCreateFailed 而不是 saveFailed。
        let locked = directory.appendingPathComponent("locked", isDirectory: true)
        try? FileManager.default.createDirectory(at: locked, withIntermediateDirectories: true)
        try? FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: locked.path)
        defer {
            try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: locked.path)
        }
        let target = locked.appendingPathComponent("out.png")

        var thrown: SnapshotError?
        do {
            try Color.red.frame(width: 10, height: 10).snapshot(path: target, title: "out")
        } catch let error as SnapshotError {
            thrown = error
        } catch {
            thrown = nil
        }
        guard case .destinationCreateFailed = thrown else {
            Issue.record("期望抛出 destinationCreateFailed，实际为 \(String(describing: thrown))")
            return
        }
    }

    // MARK: - 错误描述
    @Test("SnapshotError 都有可读的错误描述")
    func errorDescriptions() {
        let errors: [SnapshotError] = [
            .failedToAccessDownloads,
            .imageRenderFailed,
            .destinationCreateFailed,
            .saveFailed
        ]
        let descriptions = errors.map { $0.errorDescription }
        for description in descriptions {
            #expect(description != nil)
            #expect((description ?? "").isEmpty == false)
        }
        let unique = Set(descriptions)
        #expect(unique.count == errors.count)
    }
}
