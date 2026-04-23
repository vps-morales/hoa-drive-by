import XCTest
@testable import HOADriveBy

final class AppStoreTests: XCTestCase {
    func testAppStoreInitialization() {
        let store = AppStore()
        XCTAssertTrue(store.communities.isEmpty)
        XCTAssertTrue(store.violations.isEmpty)
    }
}
