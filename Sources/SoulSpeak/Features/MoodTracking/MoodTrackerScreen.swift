import SwiftUI

/// Mood Tracker — Calendar with emotion icons + mood history + reflection prompt
struct MoodTrackerScreen: View {
    @State private var selectedDate = Date()
    @State private var todayMood: String?
    @State private var showReflection = false

    private let moods = [
        ("😊", "Happy"), ("😌", "Calm"), ("😢", "Sad"),
        ("😰", "Anxious"), ("😡", "Angry"), ("🙏", "Grateful"),
        ("⚡", "Energetic"), ("🌟", "Hopeful"), ("😫", "Stressed"), ("😐", "Neutral")
    ]

    private let weekMoods = ["😌", "😊", "😢", "😊", "🙏", "😌", "🌟"]
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's check-in
                    todayCheckIn

                    // Week calendar
                    weekView

                    // Mood selector
                    moodGrid

                    // Reflection prompt
                    if showReflection {
                        reflectionCard
                    }
                }
                .padding()
            }
            .background(SSColors.background.ignoresSafeArea())
            .navigationTitle("Mood Tracker")
        }
    }

    private var todayCheckIn: some View {
        VStack(spacing: 8) {
            Text("How are you feeling today?")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            if let mood = todayMood {
                Text(mood)
                    .font(.system(size: 48))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }


    private var weekView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Week")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SSColors.textSecondary)
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 6) {
                        Text(weekDays[i])
                            .font(.system(size: 11))
                            .foregroundColor(SSColors.textSecondary)
                        Text(weekMoods[i])
                            .font(.system(size: 22))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var moodGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select your mood")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SSColors.textSecondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 14) {
                ForEach(moods, id: \.0) { emoji, name in
                    Button(action: {
                        todayMood = emoji
                        withAnimation(.spring(response: 0.3)) { showReflection = true }
                    }) {
                        VStack(spacing: 4) {
                            Text(emoji).font(.system(size: 32))
                            Text(name).font(.system(size: 10)).foregroundColor(SSColors.textSecondary)
                        }
                        .padding(8)
                        .background(todayMood == emoji ? SSColors.primary.opacity(0.15) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image("dr_hope")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                Text("Dr. Hope says...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SSColors.textSecondary)
            }
            Text("Take a moment to reflect — what do you think brought on this feeling today? There's no wrong answer.")
                .font(.system(size: 15, design: .serif))
                .foregroundColor(SSColors.textPrimary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(SSColors.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
