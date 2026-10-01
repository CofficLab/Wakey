import SwiftUI

struct EditableUrlField: View {
    let label: String
    let icon: String
    let url: String
    @Binding var isEditing: Bool
    @Binding var tempUrl: String
    @Binding var isSaving: Bool
    let onSave: (String) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 12)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)

            if isEditing {
                editingView
            } else {
                displayView
            }
        }
    }

    private var editingView: some View {
        HStack(spacing: 4) {
            TextField("网址", text: $tempUrl)
                .textFieldStyle(.roundedBorder)
                .font(.caption2)
                .onSubmit { onSave(tempUrl) }

            if isSaving {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button(action: { onSave(tempUrl) }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .help("保存")

                Button(action: {
                    isEditing = false
                    tempUrl = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("取消")
            }
        }
    }

    private var displayView: some View {
        HStack(spacing: 4) {
            Text(url)
                .font(.caption2)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Button(action: {
                tempUrl = url
                isEditing = true
            }) {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("编辑")

            if let linkUrl = URL(string: url) {
                Link(destination: linkUrl) {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("打开链接")
            }
        }
    }
}
