import SwiftUI

/// Settings view
struct SettingView: View {
    @Environment(\.dismiss) private var dismiss

    var defaultTab: SettingTab = .about
    @State private var selectedTab: SettingTab

    enum SettingTab: String, CaseIterable {
        case general = "General"
        case about = "About"

        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .about: return "info.circle"
            }
        }
    }

    init(defaultTab: SettingTab = .about) {
        self.defaultTab = defaultTab
        self._selectedTab = State(initialValue: defaultTab)
    }

    private var appInfo: AppInfo {
        AppInfo()
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                sidebarHeader
                Divider()
                List(SettingTab.allCases, id: \.self, selection: $selectedTab) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 200)
        } detail: {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .general:
                        GeneralSettingView()
                    case .about:
                        AboutView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()
                HStack {
                    Spacer()
                    Button("Done") {
                        NotificationCenter.postDismissSettings()
                    }
                    .keyboardShortcut(.defaultAction)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                }
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(width: 600, height: 500)
        .onDismissSettings{
            dismiss()
        }
    }

    private var sidebarHeader: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer().frame(height: 20)
            LogoView(variant: .about)
                .frame(width: 64, height: 64)
            Text(appInfo.name)
                .font(.headline)
                .fontWeight(.semibold)
            VStack(alignment: .center, spacing: 2) {
                Text("v\(appInfo.version)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Build \(appInfo.build)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer().frame(height: 16)
        }
        .frame(maxWidth: .infinity)
    }
}
