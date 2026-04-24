import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = false
    @State private var violationCreatedEnabled = true
    @State private var statusChangedEnabled = true
    @State private var dailySummaryEnabled = false
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            Task {
                                if newValue {
                                    await requestNotificationPermission()
                                } else {
                                    NotificationService.shared.cancelAll()
                                }
                            }
                        }

                    if notificationsEnabled {
                        Text(authorizationStatusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if notificationsEnabled {
                    Section("Notification Types") {
                        Toggle("New Violations", isOn: $violationCreatedEnabled)
                            .help("Alert when a new violation is created")

                        Toggle("Status Changes", isOn: $statusChangedEnabled)
                            .help("Alert when a violation status is updated")

                        Toggle("Daily Summary", isOn: $dailySummaryEnabled)
                            .help("Receive a daily summary of violations")
                    }

                    Section("How It Works") {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("New violations trigger immediate alerts", systemImage: "bell.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Label("Status updates send notifications", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Label("Daily summaries at 9 AM", systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    if authorizationStatus == .denied {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notifications are disabled")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("Enable notifications in Settings > HOA Drive-By > Notifications")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Button(action: openAppSettings) {
                                    Label("Open Settings", systemImage: "gear")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 8)
                        } footer: {
                            Text("You can change notification settings at any time in your device settings.")
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            await checkAuthorizationStatus()
        }
    }

    private var authorizationStatusText: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "✓ Notifications enabled"
        case .denied:
            return "✗ Notifications disabled in settings"
        case .notDetermined:
            return "Tap 'Enable Notifications' to allow alerts"
        @unknown default:
            return "Unknown status"
        }
    }

    private func requestNotificationPermission() async {
        isLoading = true
        let granted = await NotificationService.shared.requestAuthorization()
        isLoading = false

        if granted {
            notificationsEnabled = true
            await checkAuthorizationStatus()
        } else {
            notificationsEnabled = false
        }
    }

    private func checkAuthorizationStatus() async {
        authorizationStatus = await NotificationService.shared.checkAuthorizationStatus()
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}

#Preview {
    NotificationSettingsView()
}
