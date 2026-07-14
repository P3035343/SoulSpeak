import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var recentMoods: [MoodEntry]
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var recentEntries: [JournalEntry]
    @State private var dailyAffirmation: String = "You are worthy of all the good things life has to offer."
    @State private var currentStreak: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingSection
                    affirmationCard
                    quickActionsSection
                    streakSection
                    recentActivitySection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Home")
        }
    }
    
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greetingText)
                .font(SSTypography.title)
                .foregroundColor(SSColors.textPrimary)
            Text("How are you feeling today?")
                .font(SSTypography.body)
                .foregroundColor(SSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var affirmationCard: some View {
        SSGradientCard(gradient: SSColors.gradientPrimary) {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.white)
                Text(dailyAffirmation)
                    .font(SSTypography.affirmation)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(SSTypography.headline)
                .foregroundColor(SSColors.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionCard(icon: "book.fill", title: "Journal", color: SSColors.calm)
                QuickActionCard(icon: "heart.fill", title: "Mood", color: SSColors.love)
                QuickActionCard(icon: "wind", title: "Breathe", color: SSColors.growth)
                QuickActionCard(icon: "star.fill", title: "Gratitude", color: SSColors.energy)
            }
        }
    }
    
    private var streakSection: some View {
        SSCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(SSTypography.caption)
                        .foregroundColor(SSColors.textSecondary)
                    Text("\(currentStreak) days")
                        .font(SSTypography.title2)
                        .foregroundColor(SSColors.textPrimary)
                }
                Spacer()
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(SSColors.energy)
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(SSTypography.headline)
                .foregroundColor(SSColors.textPrimary)
            
            if recentEntries.isEmpty {
                SSCard {
                    VStack(spacing: 8) {
                        Image(systemName: "pencil.circle")
                            .font(.title)
                            .foregroundColor(SSColors.textSecondary)
                        Text("Start your first journal entry")
                            .font(SSTypography.body)
                            .foregroundColor(SSColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(recentEntries.prefix(3)) { entry in
                    SSCard {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                                .font(SSTypography.headline)
                                .foregroundColor(SSColors.textPrimary)
                            Text(entry.createdAt, style: .relative)
                                .font(SSTypography.caption)
                                .foregroundColor(SSColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        SSCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(SSTypography.caption)
                    .foregroundColor(SSColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
