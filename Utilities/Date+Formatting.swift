import Foundation

enum DateFormatters {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension Date {
    var shortDateTime: String { DateFormatters.shortDateTime.string(from: self) }
    var shortDate: String { DateFormatters.shortDate.string(from: self) }
}
