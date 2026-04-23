import SwiftUI

struct ViolationListView: View {
    @EnvironmentObject private var appState: AppState
    let statusFilter: ViolationStatus?
    let title: String

    private var filteredViolations: [ViolationRecord] {
        let list = appState.store.violations
        if let status = statusFilter {
            return list.filter { $0.status == status }
        }
        return list
    }

    var body: some View {
        List {
            if filteredViolations.isEmpty {
                ContentUnavailableView("No violations", systemImage: "doc.text.magnifyingglass", description: Text(statusFilter.map { "No \($0.rawValue.lowercased()) violations yet." } ?? "Create your first violation from the New tab."))
            } else {
                ForEach(filteredViolations.sorted(by: { $0.createdAt > $1.createdAt })) { violation in
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
        .navigationTitle(title)
    }
}
