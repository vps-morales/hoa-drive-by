import Foundation

struct Community: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var address: String
    var properties: [Property]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        address: String = "",
        properties: [Property] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.properties = properties
        self.createdAt = createdAt
    }
}
