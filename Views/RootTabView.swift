import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }

            NavigationStack {
                CommunitiesView()
            }
            .tabItem {
                Label("Communities", systemImage: "building.2")
            }

            NavigationStack {
                NewViolationView()
            }
            .tabItem {
                Label("New", systemImage: "camera.viewfinder")
            }
        }
        .overlay {
            if !appState.isLoaded {
                ProgressView("Loading...")
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}
