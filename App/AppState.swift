import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var store = AppStore()
    @Published var isLoaded = false
    @Published var bootstrapError: AppError?

    func bootstrap() async {
        do {
            try await store.load()
            if store.communities.isEmpty {
                store.seedSampleData()
                try await store.save()
            }
            isLoaded = true
        } catch {
            let appError = AppError.from(error)
            bootstrapError = appError
            isLoaded = true
        }
    }
}
