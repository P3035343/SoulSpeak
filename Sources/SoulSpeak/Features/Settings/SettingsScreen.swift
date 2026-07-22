import SwiftUI

/// Settings — Theme toggle, notifications, mental health resources
struct SettingsScreen: View {
    @State private var darkMode = false
    @State private var notificationsOn = true
    @State private var jazzVolume: Double = 0.7

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                Section("Notifications") {
                    Toggle("Daily Check-in Reminder", isOn: $notificationsOn)
                }
                Section("Music") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Jazz Volume")
                        Slider(value: $jazzVolume, in: 0...1)
                            .tint(SSColors.primary)
                    }
                }
                Section("Mental Health Resources") {
                    Link(destination: URL(string: "tel:988")!) {
                        Label("988 Suicide & Crisis Lifeline", systemImage: "phone.fill")
                    }
                    Link(destination: URL(string: "sms:741741")!) {
                        Label("Crisis Text Line (741741)", systemImage: "message.fill")
                    }
                    NavigationLink("Find Nearby Help") {
                        NearbyResourcesView()
                    }
                }
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    Text("Dr. Hope is a virtual wellness companion and is not a licensed medical professional.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
