import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var isEditing = false
    
    var profile: UserProfile? { profiles.first }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatarSection
                    statsSection
                    preferencesSection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
        }
    }
    
    private var avatarSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(SSColors.primary)
            Text(profile?.displayName ?? "Soul Seeker")
                .font(SSTypography.title2)
                .foregroundColor(SSColors.textPrimary)
            if let joinDate = profile?.joinDate {
                Text("Member since \(joinDate, format: .dateTime.month().year())")
                    .font(SSTypography.caption)
                    .foregroundColor(SSColors.textSecondary)
            }
        }
    }
    
    private var statsSection: some View {
        SSCard {
            HStack(spacing: 24) {
                StatItem(value: "\(profile?.totalJournalEntries ?? 0)", label: "Entries")
                StatItem(value: "\(profile?.totalMoodEntries ?? 0)", label: "Moods")
                StatItem(value: "\(profile?.journalStreak ?? 0)", label: "Streak")
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(SSTypography.headline)
            SSCard {
                VStack(spacing: 12) {
                    PreferenceRow(icon: "paintbrush.fill", title: "Theme", value: profile?.preferredTheme ?? "Default")
                    PreferenceRow(icon: "bell.fill", title: "Notifications", value: (profile?.notificationsEnabled ?? true) ? "On" : "Off")
                    PreferenceRow(icon: "lock.fill", title: "Biometric", value: (profile?.biometricEnabled ?? true) ? "Enabled" : "Disabled")
                }
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(SSTypography.title2)
                .foregroundColor(SSColors.primary)
            Text(label)
                .font(SSTypography.caption)
                .foregroundColor(SSColors.textSecondary)
        }
    }
}

struct PreferenceRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(SSColors.primary)
                .frame(width: 24)
            Text(title)
                .font(SSTypography.body)
            Spacer()
            Text(value)
                .font(SSTypography.body)
                .foregroundColor(SSColors.textSecondary)
        }
    }
}
