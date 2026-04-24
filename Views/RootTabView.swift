import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var errorHandler = ErrorHandler()

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
                MapViewContainer()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                NewViolationView()
            }
            .tabItem {
                Label("New", systemImage: "camera.viewfinder")
            }
        }
        .environmentObject(errorHandler)
        .overlay {
            if !appState.isLoaded {
                ProgressView("Loading...")
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .errorAlert(errorHandler: errorHandler)
        .alert("Bootstrap Error", isPresented: .constant(appState.bootstrapError != nil)) {
            Button("Retry") {
                Task { await appState.bootstrap() }
            }
            Button("Close App", role: .destructive) { }
        } message: {
            if let error = appState.bootstrapError {
                let title = error.errorDescription ?? "An error occurred"
                let suggestion = error.recoverySuggestion ?? ""
                let message = suggestion.isEmpty ? title : "\(title)\n\n\(suggestion)"
                return Text(message)
            }
            return Text("An unknown error occurred")
        }
    }
}
