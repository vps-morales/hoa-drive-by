import SwiftUI

struct CommunitiesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingAdd = false

    var body: some View {
        List {
            ForEach(appState.store.communities) { community in
                NavigationLink {
                    CommunityDetailView(communityID: community.id)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(community.name)
                            .font(.headline)
                        Text(community.address.isEmpty ? "No address" : community.address)
                            .foregroundStyle(.secondary)
                        Text("\(community.properties.count) properties")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Communities")
        .toolbar {
            Button {
                showingAdd = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddCommunityView()
        }
    }
}
