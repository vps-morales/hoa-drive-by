import XCTest
@testable import HOADriveBy

final class ViolationStatusTests: XCTestCase {
    func testViolationStatusRawValues() {
        XCTAssertEqual(ViolationStatus.open.rawValue, "Open")
        XCTAssertEqual(ViolationStatus.warningSent.rawValue, "Warning Sent")
        XCTAssertEqual(ViolationStatus.resolved.rawValue, "Resolved")
        XCTAssertEqual(ViolationStatus.escalated.rawValue, "Escalated")
    }

    func testViolationStatusIdentifiable() {
        XCTAssertEqual(ViolationStatus.open.id, "Open")
        XCTAssertEqual(ViolationStatus.warningSent.id, "Warning Sent")
    }

    func testViolationStatusSortOrder() {
        XCTAssertEqual(ViolationStatus.open.sortOrder, 0)
        XCTAssertEqual(ViolationStatus.warningSent.sortOrder, 1)
        XCTAssertEqual(ViolationStatus.escalated.sortOrder, 2)
        XCTAssertEqual(ViolationStatus.resolved.sortOrder, 3)
    }

    func testViolationStatusSorting() {
        let statuses = [ViolationStatus.resolved, ViolationStatus.open, ViolationStatus.escalated, ViolationStatus.warningSent]
        let sorted = statuses.sorted { $0.sortOrder < $1.sortOrder }

        XCTAssertEqual(sorted[0], .open)
        XCTAssertEqual(sorted[1], .warningSent)
        XCTAssertEqual(sorted[2], .escalated)
        XCTAssertEqual(sorted[3], .resolved)
    }

    func testViolationStatusCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let status = ViolationStatus.warningSent
        let encoded = try encoder.encode(status)
        let decoded = try decoder.decode(ViolationStatus.self, from: encoded)

        XCTAssertEqual(decoded, status)
    }
}

final class CommunityTests: XCTestCase {
    func testCommunityInitialization() {
        let community = Community(name: "Test HOA", address: "123 Main St")

        XCTAssertEqual(community.name, "Test HOA")
        XCTAssertEqual(community.address, "123 Main St")
        XCTAssertEqual(community.properties.count, 0)
    }

    func testCommunityWithProperties() {
        let property = Property(streetAddress: "456 Oak Ave")
        let community = Community(name: "Test HOA", properties: [property])

        XCTAssertEqual(community.properties.count, 1)
        XCTAssertEqual(community.properties[0].streetAddress, "456 Oak Ave")
    }

    func testCommunityIdentifiable() {
        let community = Community(name: "Test HOA")
        XCTAssertNotNil(community.id)
    }

    func testCommunityDefaultDate() {
        let community = Community(name: "Test HOA")
        let now = Date()

        XCTAssertLessThan(abs(community.createdAt.timeIntervalSince(now)), 1.0)
    }

    func testCommunityCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let community = Community(name: "Test HOA", address: "123 Main St")
        let encoded = try encoder.encode(community)
        let decoded = try decoder.decode(Community.self, from: encoded)

        XCTAssertEqual(decoded.name, community.name)
        XCTAssertEqual(decoded.address, community.address)
    }

    func testCommunityHashable() {
        let id = UUID()
        let community1 = Community(id: id, name: "Test HOA")
        let community2 = Community(id: id, name: "Test HOA")

        XCTAssertEqual(community1, community2)
    }
}

final class PropertyTests: XCTestCase {
    func testPropertyInitialization() {
        let property = Property(streetAddress: "123 Main St")

        XCTAssertEqual(property.streetAddress, "123 Main St")
        XCTAssertEqual(property.unit, "")
        XCTAssertEqual(property.lotNumber, "")
        XCTAssertEqual(property.ownerName, "")
    }

    func testPropertyDisplayNameWithoutUnit() {
        let property = Property(streetAddress: "123 Main St", unit: "")
        XCTAssertEqual(property.displayName, "123 Main St")
    }

    func testPropertyDisplayNameWithUnit() {
        let property = Property(streetAddress: "123 Main St", unit: "5B")
        XCTAssertEqual(property.displayName, "123 Main St, Unit 5B")
    }

    func testPropertyFullInitialization() {
        let property = Property(
            streetAddress: "456 Oak Ave",
            unit: "2A",
            lotNumber: "42",
            ownerName: "John Doe",
            notes: "Corner property"
        )

        XCTAssertEqual(property.streetAddress, "456 Oak Ave")
        XCTAssertEqual(property.unit, "2A")
        XCTAssertEqual(property.lotNumber, "42")
        XCTAssertEqual(property.ownerName, "John Doe")
        XCTAssertEqual(property.notes, "Corner property")
    }

    func testPropertyCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let property = Property(
            streetAddress: "123 Main St",
            unit: "5B",
            lotNumber: "10"
        )
        let encoded = try encoder.encode(property)
        let decoded = try decoder.decode(Property.self, from: encoded)

        XCTAssertEqual(decoded.streetAddress, property.streetAddress)
        XCTAssertEqual(decoded.unit, property.unit)
    }
}

final class ViolationRecordTests: XCTestCase {
    let communityID = UUID()
    let propertyID = UUID()

    func testViolationRecordInitialization() {
        let violation = ViolationRecord(
            communityID: communityID,
            propertyID: propertyID,
            category: .trashBins,
            title: "Test Violation",
            note: "Test note"
        )

        XCTAssertEqual(violation.communityID, communityID)
        XCTAssertEqual(violation.propertyID, propertyID)
        XCTAssertEqual(violation.category, .trashBins)
        XCTAssertEqual(violation.title, "Test Violation")
        XCTAssertEqual(violation.status, .open)
    }

    func testViolationRecordWithCoordinates() {
        let violation = ViolationRecord(
            communityID: communityID,
            propertyID: propertyID,
            category: .landscaping,
            title: "Landscape Issue",
            note: "Dead grass",
            latitude: 39.7392,
            longitude: -104.9903
        )

        XCTAssertEqual(violation.latitude, 39.7392)
        XCTAssertEqual(violation.longitude, -104.9903)
        XCTAssertEqual(violation.coordinateText, "39.73920, -104.99030")
    }

    func testViolationRecordCoordinateUnavailable() {
        let violation = ViolationRecord(
            communityID: communityID,
            propertyID: propertyID,
            category: .parking,
            title: "Parking Issue",
            note: "No GPS data"
        )

        XCTAssertNil(violation.latitude)
        XCTAssertNil(violation.longitude)
        XCTAssertEqual(violation.coordinateText, "Unavailable")
    }

    func testViolationRecordWithPhotos() {
        let photos = ["photo1.jpg", "photo2.jpg"]
        let violation = ViolationRecord(
            communityID: communityID,
            propertyID: propertyID,
            category: .trashBins,
            title: "Trash Issue",
            note: "Multiple bins",
            photoFileNames: photos
        )

        XCTAssertEqual(violation.photoFileNames.count, 2)
        XCTAssertEqual(violation.photoFileNames, photos)
    }

    func testViolationRecordStatusChange() {
        var violation = ViolationRecord(
            communityID: communityID,
            propertyID: propertyID,
            category: .other,
            title: "Test",
            note: "Note"
        )

        XCTAssertEqual(violation.status, .open)

        violation.status = .resolved
        XCTAssertEqual(violation.status, .resolved)
    }

    func testViolationRecordCodable() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let violation = ViolationRecord(
            communityID: communityID,
            propertyID: propertyID,
            category: .trashBins,
            title: "Test Violation",
            note: "Test note",
            latitude: 39.7392,
            longitude: -104.9903
        )

        let encoded = try encoder.encode(violation)
        let decoded = try decoder.decode(ViolationRecord.self, from: encoded)

        XCTAssertEqual(decoded.title, violation.title)
        XCTAssertEqual(decoded.latitude, violation.latitude)
    }
}
