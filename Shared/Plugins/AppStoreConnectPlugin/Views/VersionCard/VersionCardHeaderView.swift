import SwiftUI

struct VersionCardHeaderView: View {
    let version: AppStoreVersion
    @Binding var isEditing: Bool
    @Binding var newVersionString: String
    @Binding var isSaving: Bool
    @Binding var errorMessage: String?
    @Binding var isLoadingDetail: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    let onRefresh: () async -> Void

    var body: some View {
        HStack {
            versionNumberView
            errorView
            Spacer()
            refreshButton
        }
    }

    @ViewBuilder
    private var versionNumberView: some View {
        HStack {
            if isEditing {
                editingModeView
            } else {
                displayModeView
            }
        }
    }

    private var editingModeView: some View {
        HStack(spacing: 8) {
            Text("v")
                .foregroundColor(.secondary)
            TextField("版本号", text: $newVersionString)
                .textFieldStyle(.roundedBorder)
                .font(.headline)
                .frame(width: 120)
                .onSubmit { onSave() }

            if isSaving {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button("保存") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                Button("取消") { onCancel() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
    }

    private var displayModeView: some View {
        Button(action: { newVersionString = version.versionString; isEditing = true }) {
            HStack(spacing: 6) {
                Text("v\(version.versionString)")
                    .font(.headline)
                    .fontWeight(.semibold)
                Image(systemName: "pencil.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("点击编辑版本号")
    }

    @ViewBuilder
    private var errorView: some View {
        if let error = errorMessage {
            Text(error)
                .font(.caption)
                .foregroundColor(.red)
        }
    }

    private var refreshButton: some View {
        Button(action: {
            Task {
                isLoadingDetail = true
                await onRefresh()
                isLoadingDetail = false
            }
        }) {
            Image(systemName: isLoadingDetail ? "arrow.clockwise" : "arrow.clockwise")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .help("刷新版本详情")
        .disabled(isLoadingDetail)
    }
}
