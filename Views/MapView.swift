import SwiftUI
import MapKit

struct MapViewContainer: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedCommunityID: UUID?
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedViolationID: UUID?

    private var selectedCommunity: Community? {
        guard let id = selectedCommunityID else { return nil }
        return appState.store.community(for: id)
    }

    private var violationsToShow: [ViolationRecord] {
        if let communityID = selectedCommunityID {
            return appState.store.violations(for: communityID)
        }
        return appState.store.violations
    }

    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(violationsToShow) { violation in
                    if let property = appState.store.property(for: violation.propertyID, in: violation.communityID),
                       let latitude = violation.latitude,
                       let longitude = violation.longitude {
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                            ViolationMapMarker(violation: violation, isSelected: selectedViolationID == violation.id)
                                .onTapGesture {
                                    selectedViolationID = violation.id
                                }
                        }
                    }
                }
            }
            .mapStyle(.standard)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Picker("Community", selection: $selectedCommunityID) {
                        Text("All Communities").tag(Optional<UUID>.none)
                        ForEach(appState.store.communities) { community in
                            Text(community.name).tag(Optional(community.id))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.white)
                    .cornerRadius(8)
                }
                .padding()

                Spacer()

                if let selectedViolationID = selectedViolationID,
                   let violation = appState.store.violations.first(where: { $0.id == selectedViolationID }),
                   let community = appState.store.community(for: violation.communityID),
                   let property = appState.store.property(for: violation.propertyID, in: violation.communityID) {
                    ViolationMapCard(violation: violation, community: community, property: property)
                        .padding()
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationTitle("Map View")
    }
}

struct ViolationMapMarker: View {
    let violation: ViolationRecord
    let isSelected: Bool

    var markerColor: Color {
        violation.status.color
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(markerColor)
                .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)

            Image(systemName: "exclamationmark")
                .font(.system(size: isSelected ? 20 : 16, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring, value: isSelected)
    }
}

struct ViolationMapCard: View {
    let violation: ViolationRecord
    let community: Community
    let property: Property

    var statusColor: Color {
        violation.status.color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(violation.title)
                        .font(.headline)
                    Text(property.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(community.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Label(violation.status.rawValue, systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(statusColor)
                    Text(violation.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            Text(violation.note)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if let latitude = violation.latitude, let longitude = violation.longitude {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.5f, %.5f", latitude, longitude))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    MapViewContainer()
        .environmentObject(AppState())
}
