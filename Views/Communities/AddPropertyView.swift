import SwiftUI

struct AddPropertyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    let communityID: UUID

    @State private var streetAddress = ""
    @State private var unit = ""
    @State private var lotNumber = ""
    @State private var ownerName = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Property") {
                    TextField("Street address", text: $streetAddress)
                    TextField("Unit", text: $unit)
                    TextField("Lot number", text: $lotNumber)
                    TextField("Owner name", text: $ownerName)
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            do {
                                let property = Property(streetAddress: streetAddress, unit: unit, lotNumber: lotNumber, ownerName: ownerName, notes: notes)
                                try await appState.store.addProperty(property, to: communityID)
                                appState.objectWillChange.send()
                                dismiss()
                            } catch {
                                print(error)
                            }
                        }
                    }
                    .disabled(streetAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
