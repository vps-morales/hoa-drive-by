import Foundation

struct AppData: Codable {
    var communities: [Community]
    var violations: [ViolationRecord]
}
