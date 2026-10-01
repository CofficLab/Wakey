import SwiftUI

struct ReviewDetailCard: View {
    let reviewDetail: AppStoreReviewDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.accentColor)
                Text("审核信息")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            Divider()

            // 联系人信息
            if let firstName = reviewDetail.contactFirstName,
               let lastName = reviewDetail.contactLastName {
                InfoRow(label: "联系人", value: "\(firstName) \(lastName)", systemImage: "person.circle")
            }

            if let email = reviewDetail.contactEmail {
                InfoRow(label: "邮箱", value: email, systemImage: "envelope")
            }

            if let phone = reviewDetail.contactPhone {
                InfoRow(label: "电话", value: phone, systemImage: "phone")
            }

            // 演示账号信息
            if let demoRequired = reviewDetail.demoAccountRequired, demoRequired {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.orange)
                        Text("演示账号")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    if let demoName = reviewDetail.demoAccountName {
                        InfoRow(label: "账号", value: demoName, systemImage: "person.circle")
                    }

                    if let demoPassword = reviewDetail.demoAccountPassword {
                        InfoRow(label: "密码", value: demoPassword, systemImage: "lock.fill")
                    }
                }
                .padding(.vertical, 4)
            }

            // 备注
            if let notes = reviewDetail.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.accentColor)
                        Text("审核备注")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(notes)
                        .font(.caption)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

#Preview("Review Detail Card") {
    ReviewDetailCard(reviewDetail: AppStoreReviewDetail(
        contactFirstName: "张",
        contactLastName: "三",
        contactPhone: "13800138000",
        contactEmail: "test@example.com",
        demoAccountRequired: true,
        demoAccountName: "test@test.com",
        demoAccountPassword: "Test123",
        notes: "这是一个测试应用的备注信息"
    ))
    .padding()
    .frame(width: 400)
}
