import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var avatarImageData: Data?
    var joinDate: Date
    var preferredTheme: String
    var notificationsEnabled: Bool
    var dailyReminderTime: Date?
    var biometricEnabled: Bool
    var encryptionEnabled: Bool
    var preferredAffirmationCategories: [String]
    var journalStreak: Int
    var totalJournalEntries: Int
    var totalMoodEntries: Int
    var lastActiveDate: Date
    
    init(
        id: UUID = UUID(),
        displayName: String = "Soul Seeker",
        preferredTheme: String = "default",
        notificationsEnabled: Bool = true,
        biometricEnabled: Bool = true,
        encryptionEnabled: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.joinDate = Date()
        self.preferredTheme = preferredTheme
        self.notificationsEnabled = notificationsEnabled
        self.biometricEnabled = biometricEnabled
        self.encryptionEnabled = encryptionEnabled
        self.preferredAffirmationCategories = []
        self.journalStreak = 0
        self.totalJournalEntries = 0
        self.totalMoodEntries = 0
        self.lastActiveDate = Date()
    }
}
