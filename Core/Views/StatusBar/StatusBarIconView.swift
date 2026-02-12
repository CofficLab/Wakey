import SwiftUI

/// 状态栏图标视图
/// 显示 Logo 图标和插件提供的内容视图
struct StatusBarIconView: View {
    @ObservedObject var viewModel: StatusBarIconViewModel

    var body: some View {
        LogoView(
            variant: .statusBar(isActive: viewModel.isActive)
        )
        .infinite()
        .frame(width: 20, height: 20)
        .inRootView()
    }
}
