import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var selectedStatus: ViolationStatus? = nil
    @State private var selectedCategory: ViolationCategory? = nil
    @State private var selectedCommunityID: UUID? = nil
    @State private var sortBy: SortOption = .newestFirst

    enum SortOption {
        case newestFirst
        case oldestFirst
        case addressAZ
        case statusOrder
    }

    private var filteredViolations: [ViolationRecord] {
        var results = appState.store.violations

        // Filter by community
        if let communityID = selectedCommunityID {
            results = results.filter { $0.communityID == communityID }
        }

        // Filter by status
        if let status = selectedStatus {
            results = results.filter { $0.status == status }
        }

        // Filter by category
        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }

        // Search text
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter { violation in
                guard let property = appState.store.property(for: violation.propertyID, in: violation.communityID),
                      let community = appState.store.community(for: violation.communityID) else {
                    return false
                }

                return violation.title.lowercased().contains(query) ||
                       violation.note.lowercased().contains(query) ||
                       property.streetAddress.lowercased().contains(query) ||
                       property.ownerName.lowercased().contains(query) ||
                       community.name.lowercased().contains(query)
            }
        }

        // Sort
        switch sortBy {
        case .newestFirst:
            results.sort { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            results.sort { $0.createdAt < $1.createdAt }
        case .addressAZ:
            results.sort { violation1, violation2 in
                let addr1 = appState.store.property(for: violation1.propertyID, in: violation1.communityID)?.streetAddress ?? ""
                let addr2 = appState.store.property(for: violation2.propertyID, in: violation2.communityID)?.streetAddress ?? ""
                return addr1 < addr2
            }
        case .statusOrder:
            results.sort { $0.status.sortOrder < $1.status.sortOrder }
        }

        return results
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Community Filter
                        Menu {
                            Button("All Communities") {
                                selectedCommunityID = nil
                            }
                            Divider()
                            ForEach(appState.store.communities) { community in
                                Button(community.name) {
                                    selectedCommunityID = community.id
                                }
                            }
                        } label: {
                            FilterChip(
                                label: selectedCommunityID == nil ? "Community" :
                                    appState.store.community(for: selectedCommunityID!)?.name ?? "Community",
                                isActive: selectedCommunityID != nil
                            )
                        }

                        // Status Filter
                        Menu {
                            Button("All Status") {
                                selectedStatus = nil
                            }
                            Divider()
                            ForEach(ViolationStatus.allCases) { status in
                                Button(status.rawValue) {
                                    selectedStatus = status
                                }
                            }
                        } label: {
                            FilterChip(
                                label: selectedStatus?.rawValue ?? "Status",
                                isActive: selectedStatus != nil
                            )
                        }

                        // Category Filter
                        Menu {
                            Button("All Categories") {
                                selectedCategory = nil
                            }
                            Divider()
                            ForEach(ViolationCategory.allCases) { category in
                                Button(category.rawValue) {
                                    selectedCategory = category
                                }
                            }
                        } label: {
                            FilterChip(
                                label: selectedCategory?.rawValue ?? "Category",
                                isActive: selectedCategory != nil
                            )
                        }

                        // Sort
                        Menu {
                            Button("Newest First") { sortBy = .newestFirst }
                            Button("Oldest First") { sortBy = .oldestFirst }
                            Button("Address (A-Z)") { sortBy = .addressAZ }
                            Button("Status Order") { sortBy = .statusOrder }
                        } label: {
                            FilterChip(label: "Sort", isActive: false)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Results
                if filteredViolations.isEmpty {
                    ContentUnavailableView("No violations found", systemImage: "magnifyingglass", description: Text("Try adjusting your search or filters"))
                } else {
                    List {
                        Section("Results (\(filteredViolations.count))") {
                            ForEach(filteredViolations) { violation in
                                if let community = appState.store.community(for: violation.communityID),
                                   let property = appState.store.property(for: violation.propertyID, in: violation.communityID) {
                                    NavigationLink {
                                        ViolationDetailView(violation: violation)
                                    } label: {
                                        ViolationSearchRow(violation: violation, community: community, property: property)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search Violations")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search by address, owner, title...", text: $text)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FilterChip: View {
    let label: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
            if isActive {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
        .foregroundStyle(isActive ? .blue : .primary)
        .cornerRadius(16)
    }
}

struct ViolationSearchRow: View {
    let violation: ViolationRecord
    let community: Community
    let property: Property

    var statusColor: Color {
        switch violation.status {
        case .open: return .red
        case .warningSent: return .orange
        case .escalated: return .purple
        case .resolved: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(violation.title)
                        .font(.headline)
                    Text(property.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label(violation.status.rawValue, systemImage: "circle.fill")
                    .font(.caption2)
                    .foregroundStyle(statusColor)
            }

            HStack(spacing: 12) {
                Label(community.name, systemImage: "building.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(violation.category.rawValue, systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(violation.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SearchView()
        .environmentObject(AppState())
}
