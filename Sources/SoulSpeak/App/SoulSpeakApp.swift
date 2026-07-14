import SwiftUI
import SwiftData

@main
struct SoulSpeakApp: App {
    @StateObject private var appStateManager = AppStateManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            Affirmation.self,
            MoodEntry.self,
            UserProfile.self,
            Ritual.self,
            GrowthMilestone.self,
            GratitudeEntry.self,
            BreathworkSession.self,
            CrisisContact.self,
            DailyCheckIn.self,
            ThemePreference.self,
            Achievement.self,
            CommunityPost.self,
            Streak.self,
            InsightReport.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appStateManager)
                .modelContainer(sharedModelContainer)
        }
    }
}
