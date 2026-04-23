import XCTest
@testable import HOADriveBy

final class AppStoreIntegrationTests: XCTestCase {
    var store: AppStore!

    @MainActor
    override func setUp() {
        super.setUp()
        store = AppStore()
    }

    @MainActor
    func testSampleDataSeeding() {
        store.seedSampleData()

        XCTAssertEqual(store.communities.count, 1)
        XCTAssertEqual(store.violations.count, 1)
        XCTAssertEqual(store.communities[0].name, "Aspen Ridge HOA")
        XCTAssertEqual(store.communities[0].properties.count, 3)
    }

    @MainActor
    func testAddCommunity() async throws {
        let community = Community(name: "New Community", address: "123 Main St")
        try await store.addCommunity(community)

        XCTAssertEqual(store.communities.count, 1)
        XCTAssertEqual(store.communities[0].name, "New Community")
    }

    @MainActor
    func testAddMultipleCommunities() async throws {
        let community1 = Community(name: "Community 1", address: "123 Main St")
        let community2 = Community(name: "Community 2", address: "456 Oak Ave")

        try await store.addCommunity(community1)
        try await store.addCommunity(community2)

        XCTAssertEqual(store.communities.count, 2)
    }

    @MainActor
    func testAddPropertyToCommunity() async throws {
        let community = Community(name: "Test HOA")
        try await store.addCommunity(community)

        let property = Property(streetAddress: "789 Pine Rd")
        try await store.addProperty(property, to: community.id)

        XCTAssertEqual(store.communities[0].properties.count, 1)
        XCTAssertEqual(store.communities[0].properties[0].streetAddress, "789 Pine Rd")
    }

    @MainActor
    func testAddPropertyToNonexistentCommunity() async throws {
        let fakeID = UUID()
        let property = Property(streetAddress: "123 Main St")

        try await store.addProperty(property, to: fakeID)

        XCTAssertEqual(store.communities.count, 0)
    }

    @MainActor
    func testImportPropertiesFromCSV() async throws {
        let community = Community(name: "Test HOA")
        try await store.addCommunity(community)

        let csv = """
        101 Main St,1A,10,John Doe
        102 Main St,2B,20,Jane Smith
        103 Main St,,30,Bob Johnson
        """

        try await store.importProperties(csv: csv, into: community.id)

        XCTAssertEqual(store.communities[0].properties.count, 3)
        XCTAssertEqual(store.communities[0].properties[0].ownerName, "John Doe")
        XCTAssertEqual(store.communities[0].properties[1].unit, "2B")
    }

    @MainActor
    func testImportPropertiesWithEmptyRows() async throws {
        let community = Community(name: "Test HOA")
        try await store.addCommunity(community)

        let csv = """
        101 Main St,1A,10,John Doe
        ,,,
        102 Main St,2B,20,Jane Smith
        """

        try await store.importProperties(csv: csv, into: community.id)

        XCTAssertEqual(store.communities[0].properties.count, 2)
    }

    @MainActor
    func testAddViolation() async throws {
        let community = Community(name: "Test HOA")
        let property = Property(streetAddress: "123 Main St")
        try await store.addCommunity(community)
        try await store.addProperty(property, to: community.id)

        let violation = ViolationRecord(
            communityID: community.id,
            propertyID: property.id,
            category: .trashBins,
            title: "Trash Issue",
            note: "Bins visible"
        )
        try await store.addViolation(violation)

        XCTAssertEqual(store.violations.count, 1)
        XCTAssertEqual(store.violations[0].title, "Trash Issue")
    }

    @MainActor
    func testUpdateViolation() async throws {
        let community = Community(name: "Test HOA")
        let property = Property(streetAddress: "123 Main St")
        try await store.addCommunity(community)
        try await store.addProperty(property, to: community.id)

        let violation = ViolationRecord(
            communityID: community.id,
            propertyID: property.id,
            category: .trashBins,
            title: "Trash Issue",
            note: "Bins visible"
        )
        try await store.addViolation(violation)

        var updated = violation
        updated.status = .resolved
        try await store.updateViolation(updated)

        XCTAssertEqual(store.violations[0].status, .resolved)
    }

    @MainActor
    func testUpdateNonexistentViolation() async throws {
        let violation = ViolationRecord(
            communityID: UUID(),
            propertyID: UUID(),
            category: .other,
            title: "Fake",
            note: "Fake"
        )

        try await store.updateViolation(violation)

        XCTAssertEqual(store.violations.count, 0)
    }

    @MainActor
    func testFindCommunity() async throws {
        let community = Community(name: "Test HOA")
        try await store.addCommunity(community)

        let found = store.community(for: community.id)

        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Test HOA")
    }

    @MainActor
    func testFindNonexistentCommunity() {
        let found = store.community(for: UUID())
        XCTAssertNil(found)
    }

    @MainActor
    func testFindProperty() async throws {
        let community = Community(name: "Test HOA")
        let property = Property(streetAddress: "123 Main St")
        try await store.addCommunity(community)
        try await store.addProperty(property, to: community.id)

        let found = store.property(for: property.id, in: community.id)

        XCTAssertNotNil(found)
        XCTAssertEqual(found?.streetAddress, "123 Main St")
    }

    @MainActor
    func testFindPropertyInWrongCommunity() async throws {
        let community1 = Community(name: "Community 1")
        let community2 = Community(name: "Community 2")
        let property = Property(streetAddress: "123 Main St")

        try await store.addCommunity(community1)
        try await store.addCommunity(community2)
        try await store.addProperty(property, to: community1.id)

        let found = store.property(for: property.id, in: community2.id)

        XCTAssertNil(found)
    }

    @MainActor
    func testViolationsForCommunity() async throws {
        let community = Community(name: "Test HOA")
        let property1 = Property(streetAddress: "123 Main St")
        let property2 = Property(streetAddress: "456 Oak Ave")

        try await store.addCommunity(community)
        try await store.addProperty(property1, to: community.id)
        try await store.addProperty(property2, to: community.id)

        let violation1 = ViolationRecord(
            communityID: community.id,
            propertyID: property1.id,
            category: .trashBins,
            title: "Violation 1",
            note: "Note 1"
        )
        let violation2 = ViolationRecord(
            communityID: community.id,
            propertyID: property2.id,
            category: .landscaping,
            title: "Violation 2",
            note: "Note 2"
        )

        try await store.addViolation(violation1)
        try await store.addViolation(violation2)

        let violations = store.violations(for: community.id)

        XCTAssertEqual(violations.count, 2)
    }

    @MainActor
    func testViolationsForProperty() async throws {
        let community = Community(name: "Test HOA")
        let property = Property(streetAddress: "123 Main St")

        try await store.addCommunity(community)
        try await store.addProperty(property, to: community.id)

        let violation1 = ViolationRecord(
            communityID: community.id,
            propertyID: property.id,
            category: .trashBins,
            title: "Violation 1",
            note: "Note 1"
        )
        let violation2 = ViolationRecord(
            communityID: community.id,
            propertyID: property.id,
            category: .landscaping,
            title: "Violation 2",
            note: "Note 2"
        )

        try await store.addViolation(violation1)
        try await store.addViolation(violation2)

        let violations = store.violations(for: property.id, in: community.id)

        XCTAssertEqual(violations.count, 2)
    }

    @MainActor
    func testViolationsSorting() async throws {
        let community = Community(name: "Test HOA")
        let property = Property(streetAddress: "123 Main St")

        try await store.addCommunity(community)
        try await store.addProperty(property, to: community.id)

        let violation1 = ViolationRecord(
            communityID: community.id,
            propertyID: property.id,
            category: .trashBins,
            status: .open,
            title: "Open Violation",
            note: "Open"
        )
        let violation2 = ViolationRecord(
            communityID: community.id,
            propertyID: property.id,
            category: .landscaping,
            status: .resolved,
            title: "Resolved Violation",
            note: "Resolved"
        )

        try await store.addViolation(violation1)
        try await store.addViolation(violation2)

        let violations = store.violations(for: community.id)

        XCTAssertEqual(violations[0].status, .open)
        XCTAssertEqual(violations[1].status, .resolved)
    }

    @MainActor
    func testEmptyStore() {
        XCTAssertEqual(store.communities.count, 0)
        XCTAssertEqual(store.violations.count, 0)
    }
}
