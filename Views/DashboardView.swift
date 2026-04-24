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

    var gradient: LinearGradient {
        switch systemImage {
        case "building.2":
            return LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case "exclamationmark.circle":
            return LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.1), Color.orange.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case "envelope.badge":
            return LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case "checkmark.circle":
            return LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.mint.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case "chart.bar":
            return LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var iconColor: Color {
        switch systemImage {
        case "building.2": return Color.blue
        case "exclamationmark.circle": return Color.red
        case "envelope.badge": return Color.orange
        case "checkmark.circle": return Color.green
        case "chart.bar": return Color.purple
        default: return Color.blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [iconColor, iconColor.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: iconColor.opacity(0.4), radius: 12, x: 0, y: 6)
                    )

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(value)
                        .font(.system(size: Int(value) != nil ? 36 : 16, weight: .bold))
                        .foregroundStyle(iconColor)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(gradient)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}
