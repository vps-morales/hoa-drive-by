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

#Preview {
    AnalyticsView()
        .environmentObject(AppState())
}
