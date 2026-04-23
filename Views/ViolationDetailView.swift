import SwiftUI
import UIKit

struct ViolationDetailView: View {
    @EnvironmentObject private var appState: AppState
    let violation: ViolationRecord

    @State private var selectedStatus: ViolationStatus = .open
    @State private var shareURL: URL?
    @State private var showingShare = false

    private var community: Community? {
        appState.store.community(for: violation.communityID)
    }

    private var property: Property? {
        appState.store.property(for: violation.propertyID, in: violation.communityID)
    }

    private var images: [UIImage] {
        violation.photoFileNames.compactMap { appState.store.image(for: $0) }
    }

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Community", value: community?.name ?? "Unknown")
                LabeledContent("Property", value: property?.displayName ?? "Unknown")
                LabeledContent("Category", value: violation.category.rawValue)
                LabeledContent("Created", value: violation.createdAt.shortDateTime)
                LabeledContent("Updated", value: violation.updatedAt.shortDateTime)
                LabeledContent("GPS", value: violation.coordinateText)
            }

            Section("Notes") {
                Text(violation.note.isEmpty ? "No notes entered." : violation.note)
            }

            Section("Status") {
                Picker("Status", selection: $selectedStatus) {
                    ForEach(ViolationStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .onAppear {
                    selectedStatus = violation.status
                }

                Button("Update Status") {
                    Task { await updateStatus() }
                }
            }

            Section("Photos") {
                if images.isEmpty {
                    Text("No photos attached.")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 220, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .frame(height: 175)
                }
            }

            Section {
                Button("Export PDF Report") {
                    shareURL = PDFReportService.createViolationReport(
                        violation: violation,
                        community: community,
                        property: property,
                        images: images
                    )
                    if shareURL != nil {
                        showingShare = true
                    }
                }
            }
        }
        .navigationTitle(violation.title)
        .sheet(isPresented: $showingShare) {
            if let shareURL {
                ShareSheet(items: [shareURL])
            }
        }
    }

    private func updateStatus() async {
        var updated = violation
        updated.status = selectedStatus
        updated.updatedAt = .now
        do {
            try await appState.store.updateViolation(updated)
            appState.objectWillChange.send()
        } catch {
            print("Status update failed: \(error)")
        }
    }
}
