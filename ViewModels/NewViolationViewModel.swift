import Foundation
import UIKit
import CoreLocation

@MainActor
final class NewViolationViewModel: ObservableObject {
    @Published var selectedCommunityID: UUID?
    @Published var selectedPropertyID: UUID?
    @Published var category: ViolationCategory = .exteriorMaintenance
    @Published var status: ViolationStatus = .open
    @Published var title = ""
    @Published var note = ""
    @Published var images: [UIImage] = []

    func buildViolation(location: CLLocation?) -> ViolationRecord? {
        guard let selectedCommunityID, let selectedPropertyID else { return nil }
        return ViolationRecord(
            communityID: selectedCommunityID,
            propertyID: selectedPropertyID,
            category: category,
            status: status,
            title: title.isEmpty ? category.rawValue : title,
            note: note,
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )
    }

    func reset() {
        selectedPropertyID = nil
        category = .exteriorMaintenance
        status = .open
        title = ""
        note = ""
        images = []
    }
}
