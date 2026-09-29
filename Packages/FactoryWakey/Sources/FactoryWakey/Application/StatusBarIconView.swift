import KernelCore
import SwiftUI

/// 状态栏图标视图
struct StatusBarIconView: View {
    @ObservedObject var viewModel: StatusBarIconViewModel
    let kernel: KernelCoreContainer?

    var body: some View {
        LogoView(
            kernel: kernel,
            variant: .statusBar(isActive: viewModel.isActive)
        )
        .frame(width: 20, height: 20)
        .inRootView()
    }
}
