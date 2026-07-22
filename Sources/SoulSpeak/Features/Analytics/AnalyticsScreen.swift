import SwiftUI

/// Analytics Screen — Weekly stats, journaling streaks, mood trends, progress badges
struct AnalyticsScreen: View {
    @State private var currentStreak = 7
    @State private var totalEntries = 23
    @State private var avgMood = "😌"
    @State private var animate = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly overview
                    weeklyOverview

                    // Streak card
                    streakCard

                    // Mood trend
                    moodTrendCard

                    // Badges
                    badgesSection
                }
                .padding()
            }
            .background(SSColors.background.ignoresSafeArea())
            .navigationTitle("My Progress")
        }
    }

    private var weeklyOverview: some View {
        HStack(spacing: 16) {
            statBox(value: "\(totalEntries)", label: "Entries", icon: "book.fill", color: SSColors.primary)
            statBox(value: "\(currentStreak)", label: "Day Streak", icon: "flame.fill", color: .orange)
            statBox(value: avgMood, label: "Avg Mood", icon: "heart.fill", color: .pink)
        }
    }

    private func statBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(SSColors.textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(SSColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Journaling Streak")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(SSColors.textSecondary)
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(currentStreak)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("days")
                        .font(.system(size: 16))
                        .foregroundColor(SSColors.textSecondary)
                        .padding(.bottom, 4)
                }
                Text("Keep going! You're building a beautiful habit.")
                    .font(.system(size: 13))
                    .foregroundColor(SSColors.textSecondary)
            }
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 44))
                .foregroundColor(.orange.opacity(0.3))
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var moodTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week's Moods")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SSColors.textSecondary)

            HStack(spacing: 8) {
                ForEach(["😌", "😊", "😢", "😊", "🙏", "😌", "🌟"], id: \.self) { mood in
                    VStack(spacing: 4) {
                        Text(mood)
                            .font(.system(size: 24))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(SSColors.primary.opacity(0.3))
                            .frame(width: 4, height: CGFloat.random(in: 20...50))
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Text("Your mood is trending upward this week 📈")
                .font(.system(size: 13))
                .foregroundColor(SSColors.primary)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Badges")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SSColors.textSecondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                badge(icon: "star.fill", label: "First Entry", earned: true)
                badge(icon: "flame.fill", label: "7-Day Streak", earned: true)
                badge(icon: "heart.fill", label: "Mood Master", earned: false)
                badge(icon: "book.fill", label: "20 Entries", earned: true)
                badge(icon: "moon.fill", label: "Night Owl", earned: false)
                badge(icon: "hands.clap.fill", label: "Prayer Warrior", earned: false)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func badge(icon: String, label: String, earned: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(earned ? .yellow : .gray.opacity(0.3))
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(earned ? SSColors.textPrimary : .gray.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 70)
        .background(earned ? Color.yellow.opacity(0.08) : Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
