import MagicKit
import SwiftUI

struct PurchaseNavigationView: View {
    /// 是否正在生成购买海报截图
    @State private var isGenerating = false

    var body: some View {
        PurchasePosterPro()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("购买海报")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: captureAppStoreScreenshots) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "square.and.arrow.down.on.square")
                            }

                            Text("截图")
                        }
                    }
                    .disabled(isGenerating)
                }
            }
    }

    /// 生成购买页面的 App Store 截图并保存到下载目录
    private func captureAppStoreScreenshots() {
        let macOSSizes: [(String, CGSize)] = [
            ("macOS_2560x1600", CGSize(width: 2560, height: 1600)),
        ]

        let timestamp = Int(Date().timeIntervalSince1970)
        let folderName = "PurchasePosterScreenshots_\(timestamp)"

        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return
        }

        let folderURL = downloadsURL.appendingPathComponent(folderName)

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            return
        }

        isGenerating = true

        DispatchQueue.main.async {
            for (sizeName, size) in macOSSizes {
                let posterContent = PurchasePosterPro()
                    .frame(width: size.width, height: size.height)
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 10)

                let fileName = "PurchasePoster_\(sizeName).png"
                let fileURL = folderURL.appendingPathComponent(fileName)

                try? posterContent.snapshot(path: fileURL, scale: 1.0)
            }

            isGenerating = false
        }
    }
}

// MARK: - Preview

#Preview("Purchase Plugin") {
    PurchaseNavigationView()
        .inRootView()
        .withDebugBar()
}
