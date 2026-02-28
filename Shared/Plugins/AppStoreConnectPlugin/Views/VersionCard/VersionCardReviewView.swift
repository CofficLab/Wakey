import SwiftUI

struct VersionCardReviewView: View {
    let review: AppStoreReviewDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("审核信息")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            if let firstName = review.contactFirstName, let lastName = review.contactLastName {
                contactInfoRow(icon: "person.circle", text: "\(firstName) \(lastName)")
            }

            if let email = review.contactEmail {
                contactInfoRow(icon: "envelope", text: email, selectable: true)
            }

            if let phone = review.contactPhone {
                contactInfoRow(icon: "phone", text: phone)
            }

            if let demoRequired = review.demoRequired, demoRequired {
                HStack(spacing: 4) {
                    Image(systemName: "key.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text("需要演示账号")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func contactInfoRow(icon: String, text: String, selectable: Bool = false) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            if selectable {
                Text(text)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            } else {
                Text(text)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
