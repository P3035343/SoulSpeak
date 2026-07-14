import SwiftUI
import SwiftData

struct MoodTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var moodEntries: [MoodEntry]
    @State private var showLogMood = false
    @State private var selectedTimeRange = 7
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentMoodSection
                    moodChartSection
                    triggersSection
                    historySection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Mood")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showLogMood = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(SSColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showLogMood) {
                LogMoodView()
            }
        }
    }
    
    private var currentMoodSection: some View {
        SSGradientCard(gradient: SSColors.gradientWarm) {
            VStack(spacing: 12) {
                Text("Today's Mood")
                    .font(SSTypography.caption)
                    .foregroundColor(.white.opacity(0.8))
                if let latestMood = moodEntries.first {
                    Text(latestMood.mood.capitalized)
                        .font(SSTypography.largeTitle)
                        .foregroundColor(.white)
                    Text("Intensity: \(latestMood.intensity)/10")
                        .font(SSTypography.body)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("No mood logged yet")
                        .font(SSTypography.body)
                        .foregroundColor(.white.opacity(0.8))
                    SSButton(title: "Log Mood", style: .outline) {
                        showLogMood = true
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var moodChartSection: some View {
        SSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Mood Trend")
                        .font(SSTypography.headline)
                    Spacer()
                    Picker("Range", selection: $selectedTimeRange) {
                        Text("7d").tag(7)
                        Text("30d").tag(30)
                        Text("90d").tag(90)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }
                
                // Simplified chart representation
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(moodEntries.prefix(selectedTimeRange).reversed(), id: \.id) { entry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(SSColors.primary.opacity(0.7))
                            .frame(height: CGFloat(entry.intensity) * 8)
                    }
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var triggersSection: some View {
        SSCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Common Triggers")
                    .font(SSTypography.headline)
                let allTriggers = moodEntries.flatMap { $0.triggers }
                let uniqueTriggers = Array(Set(allTriggers)).prefix(5)
                ForEach(Array(uniqueTriggers), id: \.self) { trigger in
                    HStack {
                        Circle()
                            .fill(SSColors.primary)
                            .frame(width: 8, height: 8)
                        Text(trigger)
                            .font(SSTypography.body)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(SSTypography.headline)
            ForEach(moodEntries.prefix(10)) { entry in
                SSCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.mood.capitalized)
                                .font(SSTypography.headline)
                            Text(entry.timestamp, style: .relative)
                                .font(SSTypography.caption)
                                .foregroundColor(SSColors.textSecondary)
                        }
                        Spacer()
                        Text("\(entry.intensity)/10")
                            .font(SSTypography.title3)
                            .foregroundColor(SSColors.primary)
                    }
                }
            }
        }
    }
}

struct LogMoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood = "neutral"
    @State private var intensity = 5
    @State private var note = ""
    @State private var selectedTriggers: [String] = []
    @State private var energyLevel = 5
    
    private let moods = ["happy", "calm", "neutral", "sad", "anxious", "angry", "grateful", "energetic", "stressed", "hopeful"]
    private let triggers = ["work", "relationships", "health", "finance", "sleep", "exercise", "weather", "social", "food", "news"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    moodSelectionGrid
                    intensitySlider
                    triggerSelection
                    energySlider
                    noteSection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Log Mood")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveMood() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var moodSelectionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
            ForEach(moods, id: \.self) { mood in
                Button(action: { selectedMood = mood }) {
                    Text(mood.capitalized)
                        .font(SSTypography.caption)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(selectedMood == mood ? SSColors.primary : SSColors.surface)
                        .foregroundColor(selectedMood == mood ? .white : SSColors.textPrimary)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var intensitySlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intensity: \(intensity)/10")
                .font(SSTypography.headline)
            Slider(value: Binding(get: { Double(intensity) }, set: { intensity = Int($0) }), in: 1...10, step: 1)
                .tint(SSColors.primary)
        }
    }
    
    private var triggerSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Triggers")
                .font(SSTypography.headline)
            FlowLayout(tags: triggers.map { trigger in
                selectedTriggers.contains(trigger) ? "[\(trigger)]" : trigger
            })
        }
    }
    
    private var energySlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Energy Level: \(energyLevel)/10")
                .font(SSTypography.headline)
            Slider(value: Binding(get: { Double(energyLevel) }, set: { energyLevel = Int($0) }), in: 1...10, step: 1)
                .tint(SSColors.energy)
        }
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes (optional)")
                .font(SSTypography.headline)
            TextEditor(text: $note)
                .frame(minHeight: 80)
                .padding(8)
                .background(SSColors.surface)
                .cornerRadius(12)
        }
    }
    
    private func saveMood() {
        let entry = MoodEntry(
            mood: selectedMood,
            intensity: intensity,
            note: note.isEmpty ? nil : note,
            triggers: selectedTriggers,
            energyLevel: energyLevel
        )
        modelContext.insert(entry)
        dismiss()
    }
}
