import SwiftUI

struct CommunityDetailView: View {
    @EnvironmentObject private var appState: AppState
    let communityID: UUID

    @State private var showingAddProperty = false
    @State private var showingImport = false

    private var community: Community? {
        appState.store.community(for: communityID)
    }

    private var recentViolations: [ViolationRecord] {
        appState.store.violations(for: communityID)
    }

    var body: some View {
        Group {
            if let community {
                List {
                    Section("Overview") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(community.name).font(.headline)
                            Text(community.address.isEmpty ? "No address entered" : community.address)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("Properties") {
                        ForEach(community.properties) { property in
                            NavigationLink {
                                PropertyDetailView(communityID: communityID, propertyID: property.id)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(property.displayName)
                                    if !property.ownerName.isEmpty {
                                        Text(property.ownerName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    Section("Recent Violations") {
                        if recentViolations.isEmpty {
                            Text("No violations yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(recentViolations.prefix(10)) { violation in
                                if let property = appState.store.property(for: violation.propertyID, in: communityID) {
                                    NavigationLink {
                                        ViolationDetailView(violation: violation)
                                    } label: {
                                        ViolationRowView(violation: violation, communityName: community.name, propertyName: property.displayName)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle(community.name)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Import CSV") { showingImport = true }
                        Button {
                            showingAddProperty = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddProperty) {
                    AddPropertyView(communityID: communityID)
                }
                .sheet(isPresented: $showingImport) {
                    CSVImportView(communityID: communityID)
                }
            } else {
                ContentUnavailableView("Community not found", systemImage: "building.2.crop.circle", description: Text("The selected community could not be loaded."))
            }
        }
    }
}
