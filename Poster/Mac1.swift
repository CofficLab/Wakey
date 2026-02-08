import MagicKit
import SwiftUI

struct Mac1: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("Wakey")
                        .asPosterTitle()

                    Text("简单纯粹的防休眠工具")
                        .asPosterSubTitle()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ZStack {
                    ContentLayout()
                        .inRootView()
                        .inDemoMode()
                        .background(.background).frame(width: geo.size.width * 0.16)
                        .frame(height: geo.size.height * 0.4)
                        .roundedLarge()
                        .rotation3DEffect(
                            .degrees(-8),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .bottomLeading,
                            perspective: 1.0
                        )
                        .offset(x: -70, y: -20)
                        .shadowSm()
                        .scaleEffect(2)

                    ContentLayout()
                        .inRootView()
                        .inDemoMode()
                        .inDemoModeActivated()
                        .background(.background)
                        .frame(width: geo.size.width * 0.16)
                        .frame(height: geo.size.height * 0.4)
                        .roundedLarge()
                        .shadow3xl()
                        .rotation3DEffect(
                            .degrees(8),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .bottomLeading,
                            perspective: 1.0
                        )
                        .offset(x: 10, y: -20)
                        .scaleEffect(2)
                }
                .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Mac1") {
    Mac1()
        .inMagicContainer(.macBook13, scale: 0.2)
}
