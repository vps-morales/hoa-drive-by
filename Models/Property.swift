import Foundation

struct Property: Identifiable, Codable, Hashable {
    var id: UUID
    var streetAddress: String
    var unit: String
    var lotNumber: String
    var ownerName: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        streetAddress: String,
        unit: String = "",
        lotNumber: String = "",
        ownerName: String = "",
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.streetAddress = streetAddress
        self.unit = unit
        self.lotNumber = lotNumber
        self.ownerName = ownerName
        self.notes = notes
        self.createdAt = createdAt
    }

    var displayName: String {
        unit.isEmpty ? streetAddress : "\(streetAddress), Unit \(unit)"
    }
}
