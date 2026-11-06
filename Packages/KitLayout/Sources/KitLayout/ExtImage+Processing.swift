import Foundation
import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

// MARK: - Image Processing
public extension Image {
    /// 将 SwiftUI 视图转换为 SwiftUI Image 对象
    /// 
    /// - Parameter view: 需要转换的 SwiftUI 视图
    /// - Returns: 转换后的 SwiftUI Image 对象
    /// - Note: 此方法必须在主线程上调用
    ///        返回的 Image 对象比例因子为 1，标签文本为 "Rendered Image"
    @MainActor static func fromView(_ view: some View) -> Image {
        Image(Image.makeCGImage(from: view), scale: 1, label: Text("Rendered Image"))
    }
    
    /// 将 SwiftUI 视图转换为 CGImage
    /// 
    /// - Parameter view: 需要转换的 SwiftUI 视图
    /// - Returns: 转换后的 CGImage 对象
    /// - Note: 此方法必须在主线程上调用
    ///        如果转换失败，会创建一个1x1的透明图片作为fallback
    @MainActor static func makeCGImage(from view: some View) -> CGImage {
        let renderer = ImageRenderer(content: view)
        if let cgImage = renderer.cgImage {
            return cgImage
        } else {
            // 如果渲染失败，创建一个1x1的透明图片作为fallback
            let size = CGSize(width: 1, height: 1)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            return context.makeImage()!
        }
    }
    
    /// 将 CGImage 转换为 JPEG 格式并保存到指定位置
    ///
    /// - Parameters:
    ///   - image: 需要转换和保存的 CGImage 对象
    ///   - saveTo: 保存文件的目标 URL。为 `nil` 时通过保存面板让用户选择位置。
    /// - Note: 沙盒应用不能静默写入「下载」目录（需要额外 entitlement，
    ///        且用户未必期望文件自动出现在那里），因此未指定路径时
    ///        交由用户在保存面板中决定。
    @MainActor static func saveAsJpeg(_ image: CGImage, saveTo: URL? = nil) {
        let targetURL: URL
        if let saveTo {
            targetURL = saveTo
        } else {
            guard let chosen = ExportDestinationPicker.chooseFile(
                suggestedName: "image.jpeg",
                message: "Choose where to save the image."
            ) else {
                return
            }
            targetURL = chosen
        }

        guard let destination = CGImageDestinationCreateWithURL(targetURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            print("创建图像目标失败")
            return
        }

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            print("图像保存失败")
            return
        }
    }
    
    #if os(macOS)
    /// 将 NSImage 转换为 JPEG 格式并保存到指定位置或下载目录
    /// 
    /// - Parameters:
    ///   - image: 需要转换和保存的 NSImage 对象
    ///   - saveTo: 保存文件的目标 URL，如果为 nil 则保存到下载目录
    /// - Note: 图像将以当前时间戳命名，JPEG 压缩质量为 80%
    ///        如果保存失败，错误信息将打印到控制台
    static func saveAsJpeg(_ image: NSImage, saveTo: URL? = nil) {
        var saveToUrl = saveTo
        if saveToUrl == nil {
            guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                let message = "Failed to access downloads folder."
                print(message)
                return
            }

            saveToUrl = downloadsURL.appendingPathComponent("\(Image.getTimeString()).jpeg")
        }
        
        // 将 NSImage 对象转换为 NSBitmapImageRep 对象
        guard let imageData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: imageData) else {
            // 转换失败
            return
        }

        // 设置保存选项
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: 0.8 // 设置 JPEG 压缩质量为 80%
        ]

        // 将位图写入磁盘
        if let jpgData = bitmapRep.representation(using: .jpeg, properties: properties) {
            do {
                try jpgData.write(to: saveToUrl!)
            } catch {
                // 保存失败
                print("保存图像失败：\(error)")
            }
        }
    }
    #endif
    
    /// 生成当前时间的格式化字符串
    /// 
    /// - Returns: 返回格式为 "yyyyMMddHHmmss" 的时间字符串，
    ///           例如："20240101235959"
    static func getTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: Date())
    }
}

// MARK: - CGImage Extensions
public extension CGImage {
    /// 将 CGImage 转换为 JPEG 格式并保存
    ///
    /// - Parameter saveTo: 保存文件的目标 URL。为 `nil` 时通过保存面板让用户选择位置。
    /// - Note: 沙盒应用不能静默写入「下载」目录（需要额外 entitlement，
    ///        且用户未必期望文件自动出现在那里），因此未指定路径时
    ///        交由用户在保存面板中决定。
    @MainActor func saveAsJpeg(saveTo: URL? = nil) {
        Image.saveAsJpeg(self, saveTo: saveTo)
    }
}
