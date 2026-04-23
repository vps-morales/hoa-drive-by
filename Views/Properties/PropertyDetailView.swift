import SwiftUI

struct PropertyDetailView: View {
    @EnvironmentObject private var appState: AppState
    let communityID: UUID
    let propertyID: UUID

    private var property: Property? {
        appState.store.property(for: propertyID, in: communityID)
    }

    private var propertyViolations: [ViolationRecord] {
        appState.store.violations(for: propertyID, in: communityID)
    }

    var body: some View {
        List {
            if let property {
                Section("Property Info") {
                    LabeledContent("Address", value: property.streetAddress)
                    if !property.unit.isEmpty {
                        LabeledContent("Unit", value: property.unit)
                    }
                    if !property.lotNumber.isEmpty {
                        LabeledContent("Lot", value: property.lotNumber)
                    }
                    if !property.ownerName.isEmpty {
                        LabeledContent("Owner", value: property.ownerName)
                    }
                    if !property.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notes").font(.headline)
                            Text(property.notes)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Violations") {
                    if propertyViolations.isEmpty {
                        Text("No violations recorded.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(propertyViolations) { violation in
                            NavigationLink {
                                ViolationDetailView(violation: violation)
                            } label: {
                                ViolationRowView(violation: violation, communityName: "", propertyName: property.displayName)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(property?.displayName ?? "Property")
    }
}
