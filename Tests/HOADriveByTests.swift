import XCTest
@testable import HOADriveBy

final class HOADriveByTests: XCTestCase {

    // MARK: - Model Tests

    func testCommunityEncodingDecoding() throws {
        let community = Community(id: UUID(), name: "Test HOA", address: "123 Main St", properties: [], createdAt: Date())
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(community)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Community.self, from: data)

        XCTAssertEqual(community.id, decoded.id)
        XCTAssertEqual(community.name, decoded.name)
        XCTAssertEqual(community.address, decoded.address)
    }

    func testPropertyDisplayName() {
        let propertyWithUnit = Property(id: UUID(), streetAddress: "456 Elm St", unit: "Unit 5", lotNumber: "Lot 10", ownerName: "John Doe", notes: "", createdAt: Date())
        XCTAssertEqual(propertyWithUnit.displayName, "456 Elm St, Unit 5")

        let propertyWithoutUnit = Property(id: UUID(), streetAddress: "456 Elm St", unit: nil, lotNumber: "Lot 10", ownerName: "John Doe", notes: "", createdAt: Date())
        XCTAssertEqual(propertyWithoutUnit.displayName, "456 Elm St")
    }

    func testViolationRecordCoordinateText() {
        let violationWithCoords = ViolationRecord(id: UUID(), communityID: UUID(), propertyID: UUID(), category: .landscaping, status: .open, title: "Test", note: "", createdAt: Date(), updatedAt: Date(), latitude: 37.7749, longitude: -122.4194, photoFileNames: [])
        XCTAssertEqual(violationWithCoords.coordinateText, "37.7749, -122.4194")

        let violationWithoutCoords = ViolationRecord(id: UUID(), communityID: UUID(), propertyID: UUID(), category: .landscaping, status: .open, title: "Test", note: "", createdAt: Date(), updatedAt: Date(), latitude: nil, longitude: nil, photoFileNames: [])
        XCTAssertEqual(violationWithoutCoords.coordinateText, "No location captured")
    }

    func testViolationCategorySystemImage() {
        XCTAssertEqual(ViolationCategory.landscaping.systemImage, "leaf")
        XCTAssertEqual(ViolationCategory.parking.systemImage, "car")
        XCTAssertEqual(ViolationCategory.other.systemImage, "questionmark.circle")
    }

    func testViolationStatusSortOrder() {
        XCTAssertEqual(ViolationStatus.open.sortOrder, 0)
        XCTAssertEqual(ViolationStatus.warningSent.sortOrder, 1)
        XCTAssertEqual(ViolationStatus.resolved.sortOrder, 2)
        XCTAssertEqual(ViolationStatus.escalated.sortOrder, 3)
    }

    // MARK: - Utility Tests

    func testDateFormatting() {
        let date = Date(timeIntervalSince1970: 1713888000) // April 23, 2024, 12:00 PM UTC
        XCTAssertEqual(date.shortDateTime, "Apr 23, 2024, 12:00 PM")
        XCTAssertEqual(date.shortDate, "Apr 23, 2024")
    }

    func testCSVRows() {
        let csv = "123 Main St,Unit 1,Lot 1,John Doe\n456 Elm St,,Lot 2,Jane Smith"
        let rows = csv.csvRows
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0], ["123 Main St", "Unit 1", "Lot 1", "John Doe"])
        XCTAssertEqual(rows[1], ["456 Elm St", "", "Lot 2", "Jane Smith"])
    }

    // MARK: - Service Tests

    func testAppStoreInitialization() {
        let store = AppStore()
        XCTAssertTrue(store.communities.isEmpty)
        XCTAssertTrue(store.violations.isEmpty)
    }

    func testAppStoreAddCommunity() {
        let store = AppStore()
        let community = Community(id: UUID(), name: "New HOA", address: "789 Oak St", properties: [], createdAt: Date())
        store.addCommunity(community)
        XCTAssertEqual(store.communities.count, 1)
        XCTAssertEqual(store.communities.first?.name, "New HOA")
    }

    func testAppStoreAddProperty() {
        let store = AppStore()
        let communityID = UUID()
        let community = Community(id: communityID, name: "Test HOA", address: "123 St", properties: [], createdAt: Date())
        store.addCommunity(community)

        let property = Property(id: UUID(), streetAddress: "456 St", unit: nil, lotNumber: "Lot 1", ownerName: "Owner", notes: "", createdAt: Date())
        store.addProperty(property, toCommunity: communityID)

        XCTAssertEqual(store.communities.first?.properties.count, 1)
        XCTAssertEqual(store.communities.first?.properties.first?.streetAddress, "456 St")
    }

    func testAppStoreImportProperties() {
        let store = AppStore()
        let communityID = UUID()
        let community = Community(id: communityID, name: "Test HOA", address: "123 St", properties: [], createdAt: Date())
        store.addCommunity(community)

        let csv = "123 Main St,Unit 1,Lot 1,John Doe\n456 Elm St,,Lot 2,Jane Smith"
        store.importProperties(csv: csv, into: communityID)

        XCTAssertEqual(store.communities.first?.properties.count, 2)
        XCTAssertEqual(store.communities.first?.properties.first?.streetAddress, "123 Main St")
        XCTAssertEqual(store.communities.first?.properties.first?.unit, "Unit 1")
    }

    func testAppStoreAddViolation() {
        let store = AppStore()
        let communityID = UUID()
        let propertyID = UUID()
        let community = Community(id: communityID, name: "Test HOA", address: "123 St", properties: [
            Property(id: propertyID, streetAddress: "456 St", unit: nil, lotNumber: "Lot 1", ownerName: "Owner", notes: "", createdAt: Date())
        ], createdAt: Date())
        store.addCommunity(community)

        let violation = ViolationRecord(id: UUID(), communityID: communityID, propertyID: propertyID, category: .landscaping, status: .open, title: "Weeds", note: "Tall weeds", createdAt: Date(), updatedAt: Date(), latitude: nil, longitude: nil, photoFileNames: [])
        store.addViolation(violation)

        XCTAssertEqual(store.violations.count, 1)
        XCTAssertEqual(store.violations.first?.title, "Weeds")
    }

    func testAppStoreViolationsForCommunity() {
        let store = AppStore()
        let communityID1 = UUID()
        let communityID2 = UUID()
        let propertyID1 = UUID()
        let propertyID2 = UUID()

        let community1 = Community(id: communityID1, name: "HOA 1", address: "123 St", properties: [
            Property(id: propertyID1, streetAddress: "456 St", unit: nil, lotNumber: "Lot 1", ownerName: "Owner", notes: "", createdAt: Date())
        ], createdAt: Date())
        let community2 = Community(id: communityID2, name: "HOA 2", address: "789 St", properties: [
            Property(id: propertyID2, streetAddress: "101 St", unit: nil, lotNumber: "Lot 2", ownerName: "Owner2", notes: "", createdAt: Date())
        ], createdAt: Date())

        store.addCommunity(community1)
        store.addCommunity(community2)

        let violation1 = ViolationRecord(id: UUID(), communityID: communityID1, propertyID: propertyID1, category: .landscaping, status: .open, title: "Weeds", note: "", createdAt: Date(), updatedAt: Date(), latitude: nil, longitude: nil, photoFileNames: [])
        let violation2 = ViolationRecord(id: UUID(), communityID: communityID2, propertyID: propertyID2, category: .parking, status: .open, title: "Bad Parking", note: "", createdAt: Date(), updatedAt: Date(), latitude: nil, longitude: nil, photoFileNames: [])

        store.addViolation(violation1)
        store.addViolation(violation2)

        let violationsForCommunity1 = store.violations(for: communityID1)
        XCTAssertEqual(violationsForCommunity1.count, 1)
        XCTAssertEqual(violationsForCommunity1.first?.title, "Weeds")
    }

    // MARK: - ViewModel Tests

    func testNewViolationViewModelBuildViolation() {
        let viewModel = NewViolationViewModel()
        viewModel.selectedCommunityID = UUID()
        viewModel.selectedPropertyID = UUID()
        viewModel.category = .landscaping
        viewModel.status = .open
        viewModel.title = "Test Violation"
        viewModel.note = "Test note"

        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let violation = viewModel.buildViolation(location: location)

        XCTAssertEqual(violation.category, .landscaping)
        XCTAssertEqual(violation.status, .open)
        XCTAssertEqual(violation.title, "Test Violation")
        XCTAssertEqual(violation.note, "Test note")
        XCTAssertEqual(violation.latitude, 37.7749)
        XCTAssertEqual(violation.longitude, -122.4194)
    }

    func testNewViolationViewModelReset() {
        let viewModel = NewViolationViewModel()
        viewModel.selectedCommunityID = UUID()
        viewModel.title = "Test"
        viewModel.note = "Note"
        viewModel.images = [UIImage(systemName: "star")!]

        viewModel.reset()

        XCTAssertNil(viewModel.selectedCommunityID)
        XCTAssertNil(viewModel.selectedPropertyID)
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.note, "")
        XCTAssertTrue(viewModel.images.isEmpty)
    }
}