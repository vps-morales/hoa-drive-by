import Foundation

struct ViolationRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var communityID: UUID
    var propertyID: UUID
    var category: ViolationCategory
    var status: ViolationStatus
    var title: String
    var note: String
    var createdAt: Date
    var updatedAt: Date
    var latitude: Double?
    var longitude: Double?
    var photoFileNames: [String]

    init(
        id: UUID = UUID(),
        communityID: UUID,
        propertyID: UUID,
        category: ViolationCategory,
        status: ViolationStatus = .open,
        title: String,
        note: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        latitude: Double? = nil,
        longitude: Double? = nil,
        photoFileNames: [String] = []
    ) {
        self.id = id
        self.communityID = communityID
        self.propertyID = propertyID
        self.category = category
        self.status = status
        self.title = title
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.latitude = latitude
        self.longitude = longitude
        self.photoFileNames = photoFileNames
    }

    var coordinateText: String {
        guard let latitude, let longitude else { return "Unavailable" }
        return String(format: "%.5f, %.5f", latitude, longitude)
    }
}
