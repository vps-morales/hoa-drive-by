import SwiftUI
import UIKit

struct NewViolationView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = NewViolationViewModel()
    @StateObject private var locationService = LocationService()

    @State private var showingImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    @State private var showingAddPropertyView = false
    @State private var alertMessage = ""
    @State private var showingAlert = false

    private var selectedCommunity: Community? {
        guard let id = viewModel.selectedCommunityID else { return nil }
        return appState.store.community(for: id)
    }

    private var locationText: String {
        guard let location = locationService.latestLocation else { return "No GPS captured." }
        return String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
    }

    private var locationStatusText: String {
        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return "Location access granted"
        case .denied, .restricted:
            return "Location access denied"
        case .notDetermined:
            return "Location permission not requested"
        @unknown default:
            return "Location permission unknown"
        }
    }

    var body: some View {
        Form {
            Section("Select Location") {
                Picker("Community", selection: $viewModel.selectedCommunityID) {
                    Text("Choose").tag(Optional<UUID>.none)
                    ForEach(appState.store.communities) { community in
                        Text(community.name).tag(Optional(community.id))
                    }
                }

                if let selectedCommunity {
                    if selectedCommunity.properties.isEmpty {
                        HStack {
                            Text("No properties yet")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Add Property") {
                                showingAddPropertyView = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Picker("Property", selection: $viewModel.selectedPropertyID) {
                        Text("Choose").tag(Optional<UUID>.none)
                        ForEach(selectedCommunity.properties) { property in
                            Text(property.displayName).tag(Optional(property.id))
                        }
                    }
                    .disabled(selectedCommunity.properties.isEmpty)
                } else {
                    Picker("Property", selection: $viewModel.selectedPropertyID) {
                        Text("Choose").tag(Optional<UUID>.none)
                    }
                    .disabled(true)
                }
            }

            Section("Violation") {
                Picker("Category", selection: $viewModel.category) {
                    ForEach(ViolationCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.systemImage)
                            .tag(category)
                    }
                }

                Picker("Status", selection: $viewModel.status) {
                    ForEach(ViolationStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }

                TextField("Short title", text: $viewModel.title)
                TextField("Notes", text: $viewModel.note, axis: .vertical)
                    .lineLimit(4...8)

                Button("Use Current GPS") {
                    locationService.requestAccess()
                }

                HStack {
                    Text("GPS")
                    Spacer()
                    Text(locationText)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                Text(locationStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Photos") {
                if !viewModel.images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(viewModel.images.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .frame(height: 120)
                }

                HStack {
                    Button("Camera") {
                        imageSource = .camera
                        showingImagePicker = true
                    }
                    Button("Photo Library") {
                        imageSource = .photoLibrary
                        showingImagePicker = true
                    }
                }
            }

            Section {
                Button("Save Violation") {
                    Task { await saveViolation() }
                }
                .disabled(viewModel.selectedCommunityID == nil || viewModel.selectedPropertyID == nil)
            }
        }
        .navigationTitle("New Violation")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imageSource) { image in
                if let image {
                    viewModel.images.append(image)
                }
            }
        }
        .sheet(isPresented: $showingAddPropertyView) {
            if let selectedCommunity {
                AddPropertyView(communityID: selectedCommunity.id)
                    .environmentObject(appState)
            } else {
                EmptyView()
            }
        }
        .alert("Notice", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func saveViolation() async {
        guard var violation = viewModel.buildViolation(location: locationService.latestLocation) else {
            alertMessage = "Please select a community and property."
            showingAlert = true
            return
        }

        do {
            let fileNames = try viewModel.images.map { try appState.store.saveImage($0) }
            violation.photoFileNames = fileNames
            try await appState.store.addViolation(violation)
            appState.objectWillChange.send()
            viewModel.reset()
            alertMessage = "Violation saved successfully."
            showingAlert = true
        } catch {
            alertMessage = "Failed to save violation: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
