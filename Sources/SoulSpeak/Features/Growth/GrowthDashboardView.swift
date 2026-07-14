import SwiftUI
import SwiftData

struct GrowthDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var milestones: [GrowthMilestone]
    @Query private var achievements: [Achievement]
    @Query private var streaks: [Streak]
    @State private var showAddMilestone = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overviewSection
                    streakSection
                    milestonesSection
                    achievementsSection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Growth")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddMilestone = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(SSColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddMilestone) {
                AddMilestoneView()
            }
        }
    }
    
    private var overviewSection: some View {
        SSGradientCard(gradient: SSColors.gradientPrimary) {
            HStack(spacing: 16) {
                StatBubble(value: "\(milestones.filter { $0.isCompleted }.count)", label: "Completed")
                StatBubble(value: "\(milestones.filter { !$0.isCompleted }.count)", label: "In Progress")
                StatBubble(value: "\(achievements.filter { $0.isUnlocked }.count)", label: "Achievements")
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var streakSection: some View {
        SSCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Active Streaks")
                    .font(SSTypography.headline)
                if streaks.isEmpty {
                    Text("Start journaling to build your streak!")
                        .font(SSTypography.body)
                        .foregroundColor(SSColors.textSecondary)
                } else {
                    ForEach(streaks) { streak in
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(SSColors.energy)
                            Text(streak.type.capitalized)
                                .font(SSTypography.body)
                            Spacer()
                            Text("\(streak.currentCount) days")
                                .font(SSTypography.headline)
                                .foregroundColor(SSColors.primary)
                        }
                    }
                }
            }
        }
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(SSTypography.headline)
            ForEach(milestones.filter { !$0.isCompleted }) { milestone in
                SSCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(milestone.title)
                            .font(SSTypography.headline)
                        ProgressView(value: milestone.progress)
                            .tint(SSColors.primary)
                        Text("\(Int(milestone.progress * 100))% complete")
                            .font(SSTypography.caption)
                            .foregroundColor(SSColors.textSecondary)
                    }
                }
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(SSTypography.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(achievements) { achievement in
                    VStack(spacing: 4) {
                        Image(systemName: achievement.iconName)
                            .font(.title2)
                            .foregroundColor(achievement.isUnlocked ? SSColors.energy : SSColors.textSecondary.opacity(0.3))
                        Text(achievement.title)
                            .font(SSTypography.caption2)
                            .lineLimit(1)
                    }
                    .frame(width: 80)
                }
            }
        }
    }
}

struct StatBubble: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(SSTypography.title2)
                .foregroundColor(.white)
            Text(label)
                .font(SSTypography.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct AddMilestoneView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var category = "personal"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                Picker("Category", selection: $category) {
                    ForEach(["personal", "health", "career", "relationships", "spiritual"], id: \.self) {
                        Text($0.capitalized)
                    }
                }
            }
            .navigationTitle("New Milestone")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let milestone = GrowthMilestone(title: title, milestoneDescription: description, category: category)
                        modelContext.insert(milestone)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
