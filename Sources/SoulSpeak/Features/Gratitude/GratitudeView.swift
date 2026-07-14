import SwiftUI
import SwiftData

struct GratitudeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GratitudeEntry.createdAt, order: .reverse) private var entries: [GratitudeEntry]
    @State private var showNewEntry = false
    @State private var todayItems: [String] = ["", "", ""]
    @State private var reflection = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todaySection
                    streakSection
                    historySection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Gratitude")
        }
    }
    
    private var todaySection: some View {
        SSCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today I'm grateful for...")
                    .font(SSTypography.headline)
                
                ForEach(0..<3, id: \.self) { index in
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(SSColors.love)
                            .font(.caption)
                        TextField("Something you're grateful for", text: $todayItems[index])
                            .font(SSTypography.body)
                    }
                }
                
                TextEditor(text: $reflection)
                    .frame(minHeight: 60)
                    .font(SSTypography.body)
                    .overlay(
                        Group {
                            if reflection.isEmpty {
                                Text("Reflect on why these matter to you...")
                                    .font(SSTypography.body)
                                    .foregroundColor(SSColors.textSecondary.opacity(0.5))
                                    .padding(.leading, 4)
                                    .padding(.top, 8)
                            }
                        },
                        alignment: .topLeading
                    )
                
                SSButton(title: "Save", style: .primary) {
                    saveGratitudeEntry()
                }
            }
        }
    }
    
    private var streakSection: some View {
        SSCard {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(SSColors.energy)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("Gratitude Streak")
                        .font(SSTypography.caption)
                        .foregroundColor(SSColors.textSecondary)
                    Text("\(calculateStreak()) days")
                        .font(SSTypography.title3)
                }
                Spacer()
            }
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Gratitude")
                .font(SSTypography.headline)
            ForEach(entries.prefix(7)) { entry in
                SSCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.date, style: .date)
                            .font(SSTypography.caption)
                            .foregroundColor(SSColors.textSecondary)
                        ForEach(entry.items, id: \.self) { item in
                            HStack(spacing: 6) {
                                Image(systemName: "sparkle")
                                    .font(.caption2)
                                    .foregroundColor(SSColors.energy)
                                Text(item)
                                    .font(SSTypography.body)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveGratitudeEntry() {
        let items = todayItems.filter { !$0.isEmpty }
        guard !items.isEmpty else { return }
        let entry = GratitudeEntry(
            items: items,
            reflection: reflection.isEmpty ? nil : reflection
        )
        modelContext.insert(entry)
        todayItems = ["", "", ""]
        reflection = ""
    }
    
    private func calculateStreak() -> Int {
        var streak = 0
        var currentDate = Date()
        let calendar = Calendar.current
        for entry in entries {
            if calendar.isDate(entry.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        return streak
    }
}
