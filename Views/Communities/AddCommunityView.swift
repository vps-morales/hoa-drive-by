import SwiftUI

struct AddCommunityView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var errorHandler: ErrorHandler

    @State private var name = ""
    @State private var address = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Community Info") {
                    TextField("Community name", text: $name)
                    TextField("Address or city", text: $address)
                }
            }
            .navigationTitle("New Community")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            do {
                                try await appState.store.addCommunity(Community(name: name, address: address))
                                appState.objectWillChange.send()
                                dismiss()
                            } catch {
                                errorHandler.handle(error)
                            }
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
