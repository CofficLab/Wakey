import MagicKit
import SwiftUI

// MARK: - Break Reminder Poster View 1: Introduction

struct BreakReminderPosterIntro: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("休息提醒")
                        .asPosterTitle()

                    Text("健康工作，定时休息")
                        .asPosterSubTitle()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ZStack {
                    // Demo content preview
                    VStack(spacing: 20) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text("该休息一下了")
                            .font(.title)
                            .fontWeight(.semibold)

                        Text("你已经工作了 45 分钟")
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                    .background(.regularMaterial)
                    .roundedExtraLarge()
                    .shadow3xl()
                    .scaleEffect(2)
                }
                .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Break Reminder Poster View 2: Features

struct BreakReminderPosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("健康提醒")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: "定时提醒",
                            description: "设置工作时长，到时间自动提醒休息"
                        )
                        AppStoreFeatureItem(
                            icon: "bell.fill",
                            title: "多种提醒方式",
                            description: "支持通知、弹窗等多种提醒方式"
                        )
                        AppStoreFeatureItem(
                            icon: "slider.horizontal.3",
                            title: "灵活配置",
                            description: "自定义提醒间隔、时长等参数"
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
