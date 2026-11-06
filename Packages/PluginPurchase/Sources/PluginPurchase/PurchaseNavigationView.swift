import KitDesktop
import KitLayout
import SwiftUI

struct PurchaseNavigationView: View {
    /// 是否正在生成购买海报截图
    @State private var isGenerating = false
    /// 导出结果反馈（成功给出位置，失败给出原因）。
    @State private var exportFeedback: String?
    /// 最近一次导出的目录，供「在访达中显示」使用。
    @State private var lastExportDirectory: URL?

    var body: some View {
        PurchasePosterPro()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle(String(localized: "Purchase Poster", table: "Purchase", comment: "Title of the purchase poster page"))
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

                            Text(String(localized: "Screenshot", table: "Purchase", comment: "Button label that captures a screenshot"))
                        }
                    }
                    .disabled(isGenerating)
                }
            }
            .safeAreaInset(edge: .top) {
                if let exportFeedback {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(exportFeedback)
                            .font(.callout)
                            .foregroundColor(.secondary)

                        if let lastExportDirectory {
                            Button(String(localized: "Show in Finder", table: "Purchase", bundle: .module, comment: "Button that reveals the exported screenshots in Finder")) {
                                ExportDestinationPicker.revealInFinder(lastExportDirectory)
                            }
                            .buttonStyle(.link)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
    }

    /// 导出购买页面的 App Store 截图
    ///
    /// 先让用户选择保存位置，再渲染写入。沙盒应用不能静默写入「下载」目录
    /// （需要额外 entitlement，且用户未必期望文件自动出现在那里），
    /// 因此交由用户在保存面板中决定。
    private func captureAppStoreScreenshots() {
        let macOSSizes: [(String, CGSize)] = [
            ("macOS_2560x1600", CGSize(width: 2560, height: 1600)),
        ]

        let timestamp = Int(Date().timeIntervalSince1970)
        let folderName = "PurchasePosterScreenshots_\(timestamp)"

        let message = String(
            localized: "Choose where to save the purchase poster screenshots.",
            table: "Purchase",
            bundle: .module,
            comment: "Prompt shown when choosing where to export the purchase poster screenshots"
        )

        guard let chosenDirectory = ExportDestinationPicker.chooseDirectory(
            suggestedName: folderName,
            message: message
        ) else {
            return
        }

        let folderURL = chosenDirectory.appendingPathComponent(folderName, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            exportFeedback = String(
                localized: "Failed to create the export folder.",
                table: "Purchase",
                bundle: .module,
                comment: "Shown when the export folder could not be created"
            )
            return
        }

        isGenerating = true
        exportFeedback = nil
        lastExportDirectory = folderURL

        DispatchQueue.main.async {
            var failures = 0
            for (sizeName, size) in macOSSizes {
                let posterContent = PurchasePosterPro()
                    .frame(width: size.width, height: size.height)
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 10)

                let fileName = "PurchasePoster_\(sizeName).png"
                let fileURL = folderURL.appendingPathComponent(fileName)

                do {
                    try posterContent.snapshot(path: fileURL, scale: 1.0)
                } catch {
                    failures += 1
                }
            }

            isGenerating = false

            if failures > 0 {
                exportFeedback = String(
                    format: String(
                        localized: "Exported with %lld failure(s).",
                        table: "Purchase",
                        bundle: .module,
                        comment: "Shown when some screenshots failed to export"
                    ),
                    failures
                )
            } else {
                exportFeedback = String(
                    format: String(
                        localized: "Exported to %@.",
                        table: "Purchase",
                        bundle: .module,
                        comment: "Shown after screenshots are exported successfully"
                    ),
                    folderURL.lastPathComponent
                )
            }
        }
    }
}
