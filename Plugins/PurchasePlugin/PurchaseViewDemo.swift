import Foundation
import MagicKit
import SwiftUI

// MARK: - PurchaseViewDemo

struct PurchaseViewDemo: View {
    var body: some View {
        VStack(spacing: 0) {
            // 订阅选项区域
            subscriptionSection

            Spacer().frame(height: 40)

            // 恢复购买区域
            restoreSection

            Spacer().frame(height: 40)

            // 法律条款区域
            legalSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(.blue.opacity(0.5))
        .roundedLarge()
    }
}

// MARK: - Subscription Section

extension PurchaseViewDemo {
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题区域
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "Wakey Pro", table: "Purchase"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(String(localized: "Unlock all premium features", table: "Purchase"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(String(localized: "ID: WAKEY001", table: "Purchase"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)

            // 订阅选项
            VStack(spacing: 16) {
                subscriptionOption(
                    title: String(localized: "Wakey Pro Lifetime", table: "Purchase"),
                    productId: "com.coffic.wakey.lifetime",
                    offer: String(localized: "One-time purchase, use forever", table: "Purchase"),
                    price: "¥18.00"
                )

                subscriptionOption(
                    title: String(localized: "Wakey Pro Annual", table: "Purchase"),
                    productId: "com.coffic.wakey.annual",
                    offer: String(localized: "Enjoy all updates", table: "Purchase"),
                    price: "¥6.00/year"
                )
            }
        }
        .padding(20)
        .background(.background)
        .cornerRadius(12)
    }

    private func subscriptionOption(title: String, productId: String, offer: String, price: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(productId)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(offer)
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            Spacer()

            Button(action: {}) {
                Text(price)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Restore Section

extension PurchaseViewDemo {
    private var restoreSection: some View {
        VStack(spacing: 16) {
            Text(String(localized: "Restore Purchase", table: "Purchase"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(String(localized: "If you have previously purchased a subscription on another device, you can restore your subscription by clicking the \"Restore Purchase\" button below. Please make sure you are using the same Apple ID used for the purchase.", table: "Purchase"))
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)

            Button(action: {}) {
                Text(String(localized: "Restore Purchase", table: "Purchase"))
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Legal Section

extension PurchaseViewDemo {
    private var legalSection: some View {
        HStack(spacing: 20) {
            Text(String(localized: "Privacy Policy", table: "Purchase"))
                .font(.body)
                .foregroundColor(.primary)

            Text(String(localized: "Terms of Use", table: "Purchase"))
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview("Purchase Plugin") {
    PurchaseNavigationView()
        .inRootView()
        .withDebugBar()
}

#Preview("Purchase Poster - Pro") {
    PurchasePosterPro()
        .inMagicContainer(.macBook13, scale: 0.4)
}
