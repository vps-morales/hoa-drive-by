import SwiftUI

@main
struct HOADriveByApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}
