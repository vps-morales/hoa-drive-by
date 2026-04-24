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
                    // Date Range Selector
                    Picker("Date Range", selection: $selectedDateRange) {
                        Text("7 Days").tag(DateRange.week)
                        Text("1 Month").tag(DateRange.month)
                        Text("3 Months").tag(DateRange.threeMonths)
                        Text("1 Year").tag(DateRange.year)
                        Text("All Time").tag(DateRange.allTime)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Summary Cards
                    VStack(spacing: 12) {
                        AnalyticsMetricCard(
                            title: "Total Violations",
                            value: "\(metrics.totalViolations)",
                            icon: "exclamationmark.circle.fill",
                            color: .blue,
                            subtitle: trendText
                        )

                        StatusGridView(metrics: metrics)
                    }
                    .padding()

                    if !dailyCounts.isEmpty {
                        TrendChartView(dailyCounts: dailyCounts)
                    }

                    if !metrics.violationsByCategory.isEmpty {
                        CategoryBreakdownView(categories: metrics.violationsByCategory)
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

struct ViolationTrendChart: View {
    let dailyCounts: [DailyViolationCount]

    private var maxCount: Int {
        dailyCounts.map { $0.count }.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(dailyCounts.suffix(14)).enumerated(), id: \.element.date) { index, day in
                    DailyBarView(day: day, maxCount: maxCount, showLabel: index % 2 == 0)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct DailyBarView: View {
    let day: DailyViolationCount
    let maxCount: Int
    let showLabel: Bool

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue)
                .frame(height: CGFloat(day.count) / CGFloat(max(maxCount, 1)) * 150)

            if showLabel {
                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct StatusGridView: View {
    let metrics: ViolationMetrics

    var body: some View {
        HStack(spacing: 12) {
            StatusCard(
                status: .open,
                count: metrics.openCount,
                color: .red
            )
            StatusCard(
                status: .warningSent,
                count: metrics.warningCount,
                color: .orange
            )
            StatusCard(
                status: .escalated,
                count: metrics.escalatedCount,
                color: .purple
            )
            StatusCard(
                status: .resolved,
                count: metrics.resolvedCount,
                color: .green
            )
        }
    }
}

private struct TrendChartView: View {
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

private struct CategoryBreakdownView: View {
    let categories: [String: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(
                    categories.sorted { $0.value > $1.value },
                    id: \.key
                ) { category, count in
                    HStack {
                        Text(category)
                            .font(.subheadline)
                        Spacer()
                        Text("\(count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(AppState())
}
