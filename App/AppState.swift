import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var store = AppStore()
    @Published var isLoaded = false

    func bootstrap() async {
        do {
            try await store.load()
            if store.communities.isEmpty {
                store.seedSampleData()
                try await store.save()
            }
            isLoaded = true
        } catch {
            print("Bootstrap failed: \(error)")
            isLoaded = true
        }
    }
}
