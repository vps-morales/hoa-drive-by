import Foundation

extension FileManager {
    static var appDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var appDataURL: URL {
        appDocumentsDirectory.appendingPathComponent("hoa_drive_by_data.json")
    }

    static var imagesDirectoryURL: URL {
        let url = appDocumentsDirectory.appendingPathComponent("ViolationImages", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
}
