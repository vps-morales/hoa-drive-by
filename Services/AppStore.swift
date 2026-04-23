import Foundation
import UIKit

@MainActor
final class AppStore: ObservableObject {
    @Published var communities: [Community] = []
    @Published var violations: [ViolationRecord] = []

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func load() async throws {
        let url = FileManager.appDataURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            communities = []
            violations = []
            return
        }
        let data = try Data(contentsOf: url)
        let appData = try decoder.decode(AppData.self, from: data)
        communities = appData.communities
        violations = appData.violations
    }

    func save() async throws {
        let data = try encoder.encode(AppData(communities: communities, violations: violations))
        try data.write(to: FileManager.appDataURL, options: .atomic)
    }

    func seedSampleData() {
        let properties = [
            Property(streetAddress: "101 Aspen Ridge Dr", lotNumber: "12", ownerName: "Jordan Smith"),
            Property(streetAddress: "105 Aspen Ridge Dr", lotNumber: "13", ownerName: "Taylor Ruiz"),
            Property(streetAddress: "220 Willow Bend Ct", lotNumber: "41", ownerName: "Casey Lane")
        ]
        let community = Community(name: "Aspen Ridge HOA", address: "Denver Metro Area", properties: properties)
        let sample = ViolationRecord(
            communityID: community.id,
            propertyID: properties[0].id,
            category: .trashBins,
            title: "Trash bins visible from street",
            note: "Two bins left at curb beyond permitted pickup window."
        )
        communities = [community]
        violations = [sample]
    }

    func addCommunity(_ community: Community) async throws {
        communities.append(community)
        try await save()
    }

    func addProperty(_ property: Property, to communityID: UUID) async throws {
        guard let i = communities.firstIndex(where: { $0.id == communityID }) else { return }
        communities[i].properties.append(property)
        try await save()
    }

    func importProperties(csv: String, into communityID: UUID) async throws {
        guard let i = communities.firstIndex(where: { $0.id == communityID }) else { return }
        for row in csv.csvRows {
            guard let street = row[safe: 0], !street.isEmpty else { continue }
            let unit = row[safe: 1] ?? ""
            let lot = row[safe: 2] ?? ""
            let owner = row[safe: 3] ?? ""
            communities[i].properties.append(Property(streetAddress: street, unit: unit, lotNumber: lot, ownerName: owner))
        }
        try await save()
    }

    func addViolation(_ violation: ViolationRecord) async throws {
        violations.append(violation)
        try await save()
    }

    func updateViolation(_ violation: ViolationRecord) async throws {
        guard let i = violations.firstIndex(where: { $0.id == violation.id }) else { return }
        violations[i] = violation
        try await save()
    }

    func community(for id: UUID) -> Community? {
        communities.first(where: { $0.id == id })
    }

    func property(for propertyID: UUID, in communityID: UUID) -> Property? {
        community(for: communityID)?.properties.first(where: { $0.id == propertyID })
    }

    func violations(for communityID: UUID) -> [ViolationRecord] {
        violations.filter { $0.communityID == communityID }.sorted {
            if $0.status.sortOrder != $1.status.sortOrder {
                return $0.status.sortOrder < $1.status.sortOrder
            }
            return $0.createdAt > $1.createdAt
        }
    }

    func violations(for propertyID: UUID, in communityID: UUID) -> [ViolationRecord] {
        violations.filter { $0.communityID == communityID && $0.propertyID == propertyID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func saveImage(_ image: UIImage) throws -> String {
        let fileName = "\(UUID().uuidString).jpg"
        let url = FileManager.imagesDirectoryURL.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.82) else {
            throw NSError(domain: "HOADriveBy", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image."])
        }
        try data.write(to: url, options: .atomic)
        return fileName
    }

    func image(for fileName: String) -> UIImage? {
        let url = FileManager.imagesDirectoryURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
