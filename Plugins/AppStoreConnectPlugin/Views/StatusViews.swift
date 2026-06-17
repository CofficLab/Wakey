import SwiftUI

// MARK: - 空状态视图

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Label("请先配置 API 密钥", systemImage: "key.fill")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - 加载视图

struct LoadingView: View {
    var message: String = "加载中..."
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView(message)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - 刷新视图

struct RefreshingView: View {
    var message: String = "刷新中..."
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - 错误视图

struct ErrorView: View {
    let error: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("请求失败", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Spacer()
                Button(action: onRetry) {
                    Label("重试", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }

            Divider()

            ScrollView {
                Text(error)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300)

            HStack {
                Button("复制错误信息") {
                    #if os(iOS)
                    UIPasteboard.general.string = error
                    #elseif os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(error, forType: .string)
                    #endif
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - 空版本视图

struct EmptyVersionsView: View {
    let onFetch: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Label("暂无版本信息", systemImage: "tray")
                .foregroundColor(.secondary)

            Button("获取版本信息") {
                onFetch()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
