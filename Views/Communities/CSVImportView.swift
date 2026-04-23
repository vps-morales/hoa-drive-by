import SwiftUI

struct CSVImportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    let communityID: UUID

    @State private var csvText = "101 Aspen Ridge Dr,,12,Jordan Smith\n105 Aspen Ridge Dr,,13,Taylor Ruiz"

    var body: some View {
        NavigationStack {
            Form {
                Section("Paste CSV") {
                    Text("Format: streetAddress,unit,lotNumber,ownerName")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $csvText)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("Import Properties")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Import") {
                        Task {
                            do {
                                try await appState.store.importProperties(csv: csvText, into: communityID)
                                dismiss()
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
}
