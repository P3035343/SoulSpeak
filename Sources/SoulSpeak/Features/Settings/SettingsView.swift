import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("biometricEnabled") private var biometricEnabled = true
    @AppStorage("encryptionEnabled") private var encryptionEnabled = true
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = true
    @State private var showResetAlert = false
    @State private var showExportSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Privacy & Security") {
                    Toggle("Biometric Lock", isOn: $biometricEnabled)
                    Toggle("Encrypt Journal Entries", isOn: $encryptionEnabled)
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Daily Reminder", isOn: $dailyReminderEnabled)
                }
                
                Section("Data") {
                    Button("Export My Data") {
                        showExportSheet = true
                    }
                    Button("Reset All Data", role: .destructive) {
                        showResetAlert = true
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(SSColors.textSecondary)
                    }
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    NavigationLink("Terms of Service") {
                        TermsView()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    appStateManager.resetApp()
                }
            } message: {
                Text("This will permanently delete all your journal entries, mood data, and settings. This action cannot be undone.")
            }
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(SSTypography.title)
                Text("""
                SoulSpeak is designed with your privacy as our top priority.
                
                Data Storage: All your personal data, journal entries, and mood logs are stored locally on your device. We do not have access to your content.
                
                Encryption: When enabled, your journal entries are encrypted using AES-256 encryption before being stored.
                
                Biometric Protection: Face ID/Touch ID adds an additional layer of security to prevent unauthorized access.
                
                No Tracking: We do not use analytics trackers, advertising IDs, or any form of user surveillance.
                
                No Cloud Sync: Your data never leaves your device unless you explicitly choose to export it.
                """)
                    .font(SSTypography.body)
                    .foregroundColor(SSColors.textSecondary)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(SSTypography.title)
                Text("""
                By using SoulSpeak, you agree to the following terms:
                
                1. SoulSpeak is a personal wellness tool and is not a substitute for professional mental health care.
                
                2. If you are experiencing a mental health crisis, please contact emergency services or a crisis hotline immediately.
                
                3. You are responsible for maintaining the security of your device and your biometric authentication.
                
                4. We reserve the right to update these terms with reasonable notice.
                
                5. The app is provided "as is" without warranty of any kind.
                """)
                    .font(SSTypography.body)
                    .foregroundColor(SSColors.textSecondary)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
