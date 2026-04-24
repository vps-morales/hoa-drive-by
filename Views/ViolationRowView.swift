import SwiftUI

struct ViolationRowView: View {
    let violation: ViolationRecord
    let communityName: String
    let propertyName: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: violation.category.systemImage)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(violation.title)
                    .font(.headline)
                Text(propertyName)
                    .foregroundStyle(.secondary)

                if !communityName.isEmpty {
                    Text("\(communityName) • \(violation.createdAt.shortDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(violation.createdAt.shortDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(violation.status.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(statusColor)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch violation.status {
        case .open: return .orange
        case .warningSent: return .blue
        case .resolved: return .green
        case .escalated: return .red
        }
    }
}
