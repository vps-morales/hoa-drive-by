import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingNotificationSettings = false

    private var statusCounts: [ViolationStatus: Int] {
        var counts: [ViolationStatus: Int] = [:]
        for violation in appState.store.violations {
            counts[violation.status, default: 0] += 1
        }
        return counts
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HOA Drive-By")
                            .font(.largeTitle.bold())

                        Text("Photo-first inspections for small HOAs.")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(action: { showingNotificationSettings = true }) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.blue)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    NavigationLink {
                        CommunitiesView()
                    } label: {
                        MetricCard(title: "Communities", value: "\(appState.store.communities.count)", systemImage: "building.2")
                    }
                    NavigationLink {
                        ViolationListView(statusFilter: .open, title: "Open Violations")
                    } label: {
                        MetricCard(title: "Open", value: "\(statusCounts[.open] ?? 0)", systemImage: "exclamationmark.circle")
                    }
                    NavigationLink {
                        ViolationListView(statusFilter: .warningSent, title: "Warning Sent")
                    } label: {
                        MetricCard(title: "Warning Sent", value: "\(statusCounts[.warningSent] ?? 0)", systemImage: "envelope.badge")
                    }
                    NavigationLink {
                        ViolationListView(statusFilter: .resolved, title: "Resolved Violations")
                    } label: {
                        MetricCard(title: "Resolved", value: "\(statusCounts[.resolved] ?? 0)", systemImage: "checkmark.circle")
                    }
                    NavigationLink {
                        AnalyticsView()
                    } label: {
                        MetricCard(title: "Analytics", value: "View", systemImage: "chart.bar")
                    }
                }

                Text("Recent Activity")
                    .font(.title2.bold())
                    .padding(.top, 8)

                if appState.store.violations.isEmpty {
                    ContentUnavailableView("No violations yet", systemImage: "doc.text.magnifyingglass", description: Text("Create your first violation from the New tab."))
                } else {
                    ForEach(appState.store.violations.sorted { $0.createdAt > $1.createdAt }.prefix(10)) { violation in
                        if let community = appState.store.community(for: violation.communityID),
                           let property = appState.store.property(for: violation.propertyID, in: violation.communityID) {
                            NavigationLink {
                                ViolationDetailView(violation: violation)
                            } label: {
                                ViolationRowView(violation: violation, communityName: community.name, propertyName: property.displayName)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
            Text(value)
                .font(.system(size: 28, weight: .bold))
            Text(title)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
