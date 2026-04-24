import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedDateRange: DateRange = .month

    private var metrics: ViolationMetrics {
        AnalyticsService.calculateMetrics(
            violations: appState.store.violations,
            dateRange: selectedDateRange
        )
    }

    private var dailyCounts: [DailyViolationCount] {
        AnalyticsService.dailyViolationCounts(
            violations: appState.store.violations,
            dateRange: selectedDateRange
        )
    }

    private var trendText: String {
        AnalyticsService.violationTrend(
            violations: appState.store.violations,
            dateRange: selectedDateRange
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Date Range", selection: $selectedDateRange) {
                        Text("7 Days").tag(DateRange.week)
                        Text("1 Month").tag(DateRange.month)
                        Text("3 Months").tag(DateRange.threeMonths)
                        Text("1 Year").tag(DateRange.year)
                        Text("All Time").tag(DateRange.allTime)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    AnalyticsMetricCard(
                        title: "Total Violations",
                        value: "\(metrics.totalViolations)",
                        icon: "exclamationmark.circle.fill",
                        color: .blue,
                        subtitle: trendText
                    )
                    .padding(.horizontal)

                    StatusGridView(metrics: metrics)
                        .padding(.horizontal)

                    if !dailyCounts.isEmpty {
                        TrendChartSection(dailyCounts: dailyCounts)
                    }


                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Analytics")
        }
    }
}

struct AnalyticsMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.system(size: 32, weight: .bold))
                }
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
            }

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatusGridView: View {
    let metrics: ViolationMetrics

    var body: some View {
        HStack(spacing: 12) {
            StatusCard(status: .open, count: metrics.openCount, color: .red)
            StatusCard(status: .warningSent, count: metrics.warningCount, color: .orange)
            StatusCard(status: .escalated, count: metrics.escalatedCount, color: .purple)
            StatusCard(status: .resolved, count: metrics.resolvedCount, color: .green)
        }
    }
}

struct StatusCard: View {
    let status: ViolationStatus
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(status.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TrendChartSection: View {
    let dailyCounts: [DailyViolationCount]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Violations Over Time")
                .font(.headline)
                .padding(.horizontal)

            ViolationTrendChart(dailyCounts: dailyCounts)
                .frame(height: 200)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }
}

struct ViolationTrendChart: View {
    let dailyCounts: [DailyViolationCount]

    private var maxCount: Int {
        dailyCounts.map { $0.count }.max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(Array(dailyCounts.suffix(14)).enumerated(), id: \.element.date) { index, day in
                DailyBarView(day: day, maxCount: maxCount, showLabel: index % 2 == 0)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DailyBarView: View {
    let day: DailyViolationCount
    let maxCount: Int
    let showLabel: Bool

    var body: some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.blue)
                .frame(height: CGFloat(day.count) / CGFloat(max(maxCount, 1)) * 120)

            if showLabel {
                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(height: 12)
            }
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(AppState())
}
