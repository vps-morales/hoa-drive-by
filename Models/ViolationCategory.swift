import Foundation

enum ViolationCategory: String, Codable, CaseIterable, Identifiable {
    case landscaping = "Landscaping"
    case exteriorMaintenance = "Exterior Maintenance"
    case trashBins = "Trash Bins"
    case parking = "Parking"
    case unauthorizedStructure = "Unauthorized Structure"
    case noise = "Noise"
    case pets = "Pets"
    case signage = "Signage"
    case other = "Other"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .landscaping: return "leaf"
        case .exteriorMaintenance: return "hammer"
        case .trashBins: return "trash"
        case .parking: return "car"
        case .unauthorizedStructure: return "house"
        case .noise: return "speaker.wave.2"
        case .pets: return "pawprint"
        case .signage: return "signpost.right"
        case .other: return "exclamationmark.bubble"
        }
    }
}
