import MagicKit
import SwiftUI

// MARK: - Caffeinate Poster View 1: Introduction

struct CaffeinatePosterIntro: View {
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

// MARK: - Caffeinate Poster View 2: Features

struct CaffeinatePosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("极简设计")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "cup.and.saucer.fill",
                            title: "一键防休眠",
                            description: "点击即可阻止系统进入睡眠模式"
                        )
                        AppStoreFeatureItem(
                            icon: "sun.max.fill",
                            title: "保持屏幕常亮",
                            description: "确保演示或工作时屏幕不熄灭"
                        )
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: "定时自动恢复",
                            description: "设置特定时长，结束后自动恢复系统休眠"
                        )
                        AppStoreFeatureItem(
                            icon: "bolt.fill",
                            title: "极致轻量",
                            description: "低资源占用，静默运行，不打扰工作"
                        )
                    }
                    .frame(width: geo.size.width * 0.4)
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .inRootView()
                    .inDemoMode()
                    .roundedLarge()
                    .shadowSm()
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .frame(width: geo.size.width * 0.5)
                    .scaleEffect(4)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Caffeinate Poster View 3: Status Bar Control

struct CaffeinatePosterStatusBar: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("状态栏控制")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "menubar.arrow.up.rectangle",
                            title: "快捷菜单",
                            description: "通过状态栏菜单快速切换不同的防休眠模式"
                        )
                    }
                    .frame(width: geo.size.width * 0.4)
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .inRootView()
                    .inDemoMode()
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .roundedLarge()
                    .shadowSm()
                    .scaleEffect(4)
                    .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Caffeinate Poster View 4: Multi-mode Support

struct CaffeinatePosterModes: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("多模式支持")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "laptopcomputer",
                            title: "系统防休眠",
                            description: "仅阻止系统睡眠，允许显示器按计划关闭"
                        )
                        AppStoreFeatureItem(
                            icon: "display",
                            title: "显示器常亮",
                            description: "同时阻止系统和显示器进入睡眠状态"
                        )
                        AppStoreFeatureItem(
                            icon: "power.circle",
                            title: "强制息屏",
                            description: "阻止系统休眠的同时，立即强制关闭显示器"
                        )
                    }
                    .frame(width: geo.size.width * 0.4)
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentView()
                    .inRootView()
                    .inDemoMode()
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .roundedLarge()
                    .shadowSm()
                    .frame(width: geo.size.width * 0.5)
                    .scaleEffect(4)
            }
        }
        .inPosterContainer()
    }
}
