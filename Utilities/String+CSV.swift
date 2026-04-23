import Foundation

extension String {
    var csvRows: [[String]] {
        split(whereSeparator: \.isNewline).map { line in
            line.split(separator: ",", omittingEmptySubsequences: false)
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        }
    }
}
