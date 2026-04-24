import Foundation

struct ViolationMetrics {
    let totalViolations: Int
    let openCount: Int
    let warningCount: Int
    let escalatedCount: Int
    let resolvedCount: Int
    let violationsByCategory: [String: Int]
    let violationsByDate: [Date: Int]
    let changeFromPreviousPeriod: Double
}

struct DailyViolationCount {
    let date: Date
    let count: Int
}

enum DateRange {
    case week
    case month
    case threeMonths
    case year
    case allTime

    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            return Date(timeIntervalSince1970: 0)
        }
    }

    var label: String {
        switch self {
        case .week: return "Last 7 Days"
        case .month: return "Last Month"
        case .threeMonths: return "Last 3 Months"
        case .year: return "Last Year"
        case .allTime: return "All Time"
        }
    }
}

struct AnalyticsService {
    static func calculateMetrics(
        violations: [ViolationRecord],
        dateRange: DateRange = .month
    ) -> ViolationMetrics {
        let startDate = dateRange.startDate
        let filteredViolations = violations.filter { $0.createdAt >= startDate }

        let openCount = filteredViolations.filter { $0.status == .open }.count
        let warningCount = filteredViolations.filter { $0.status == .warningSent }.count
        let escalatedCount = filteredViolations.filter { $0.status == .escalated }.count
        let resolvedCount = filteredViolations.filter { $0.status == .resolved }.count

        var categoryCounts: [String: Int] = [:]
        for violation in filteredViolations {
            let category = violation.category.rawValue
            categoryCounts[category, default: 0] += 1
        }

        var dateCounts: [Date: Int] = [:]
        let calendar = Calendar.current
        for violation in filteredViolations {
            let date = calendar.startOfDay(for: violation.createdAt)
            dateCounts[date, default: 0] += 1
        }

        let now = Date()
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
        let previousStartDate = calendar.date(byAdding: .day, value: -daysDiff, to: startDate) ?? startDate
        let previousViolations = violations.filter { v in
            v.createdAt >= previousStartDate && v.createdAt < startDate
        }

        let changeFromPrevious = previousViolations.isEmpty
            ? 0.0
            : Double(filteredViolations.count - previousViolations.count) / Double(previousViolations.count) * 100

        return ViolationMetrics(
            totalViolations: filteredViolations.count,
            openCount: openCount,
            warningCount: warningCount,
            escalatedCount: escalatedCount,
            resolvedCount: resolvedCount,
            violationsByCategory: categoryCounts,
            violationsByDate: dateCounts,
            changeFromPreviousPeriod: changeFromPrevious
        )
    }

    static func dailyViolationCounts(
        violations: [ViolationRecord],
        dateRange: DateRange = .month
    ) -> [DailyViolationCount] {
        let startDate = dateRange.startDate
        let filteredViolations = violations.filter { $0.createdAt >= startDate }

        var dateCounts: [Date: Int] = [:]
        let calendar = Calendar.current

        for violation in filteredViolations {
            let date = calendar.startOfDay(for: violation.createdAt)
            dateCounts[date, default: 0] += 1
        }

        return dateCounts
            .map { DailyViolationCount(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }

    static func violationTrend(
        violations: [ViolationRecord],
        dateRange: DateRange = .month
    ) -> String {
        let metrics = calculateMetrics(violations: violations, dateRange: dateRange)
        let change = metrics.changeFromPreviousPeriod

        if change > 0 {
            return String(format: "↑ %.0f%% from previous period", change)
        } else if change < 0 {
            return String(format: "↓ %.0f%% from previous period", abs(change))
        } else {
            return "→ No change from previous period"
        }
    }
}
