import Foundation

enum ViolationStatus: String, Codable, CaseIterable, Identifiable {
    case open = "Open"
    case warningSent = "Warning Sent"
    case resolved = "Resolved"
    case escalated = "Escalated"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .open: return 0
        case .warningSent: return 1
        case .escalated: return 2
        case .resolved: return 3
        }
    }
}
