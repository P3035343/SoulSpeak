import SwiftUI
import SwiftData

struct JournalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: JournalEntry?
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedMood: String = "neutral"
    @State private var moodIntensity: Int = 5
    @State private var tags: [String] = []
    @State private var isFavorite: Bool = false
    @State private var showCrisisAlert: Bool = false
    
    private let crisisService = LocalCrisisDetectionService()
    
    private let moods = ["happy", "calm", "neutral", "sad", "anxious", "angry", "grateful", "energetic"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    titleSection
                    moodSection
                    contentSection
                    tagsSection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .fontWeight(.semibold)
                }
                if entry != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { isFavorite.toggle() }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? SSColors.love : SSColors.textSecondary)
                        }
                    }
                }
            }
            .onAppear { loadEntry() }
            .alert("We Care About You", isPresented: $showCrisisAlert) {
                Button("View Resources", role: .none) {}
                Button("I'm OK", role: .cancel) {}
            } message: {
                Text("If you're going through a difficult time, please know that help is available. Would you like to see crisis resources?")
            }
        }
    }
    
    private var titleSection: some View {
        TextField("Entry title...", text: $title)
            .font(SSTypography.journalTitle)
            .foregroundColor(SSColors.textPrimary)
    }
    
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How are you feeling?")
                .font(SSTypography.caption)
                .foregroundColor(SSColors.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(moods, id: \.self) { mood in
                        MoodChip(mood: mood, isSelected: selectedMood == mood) {
                            selectedMood = mood
                        }
                    }
                }
            }
            Slider(value: Binding(
                get: { Double(moodIntensity) },
                set: { moodIntensity = Int($0) }
            ), in: 1...10, step: 1)
            .tint(SSColors.primary)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's on your mind?")
                .font(SSTypography.caption)
                .foregroundColor(SSColors.textSecondary)
            TextEditor(text: $content)
                .font(SSTypography.journalBody)
                .frame(minHeight: 200)
                .padding(8)
                .background(SSColors.surface)
                .cornerRadius(12)
                .onChange(of: content) { _, newValue in
                    checkForCrisisLanguage(newValue)
                }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(SSTypography.caption)
                .foregroundColor(SSColors.textSecondary)
            FlowLayout(tags: tags)
        }
    }
    
    private func loadEntry() {
        guard let entry = entry else { return }
        title = entry.title
        content = entry.content
        selectedMood = entry.mood
        moodIntensity = entry.moodIntensity
        tags = entry.tags
        isFavorite = entry.isFavorite
    }
    
    private func saveEntry() {
        if let entry = entry {
            entry.title = title
            entry.content = content
            entry.mood = selectedMood
            entry.moodIntensity = moodIntensity
            entry.tags = tags
            entry.isFavorite = isFavorite
            entry.updatedAt = Date()
            entry.wordCount = content.split(separator: " ").count
        } else {
            let newEntry = JournalEntry(
                title: title,
                content: content,
                mood: selectedMood,
                moodIntensity: moodIntensity,
                tags: tags,
                isFavorite: isFavorite
            )
            modelContext.insert(newEntry)
        }
        dismiss()
    }
    
    private func checkForCrisisLanguage(_ text: String) {
        let result = crisisService.detectCrisisLanguage(in: text)
        if result.isCrisisDetected && result.severity == .high || result.severity == .critical {
            showCrisisAlert = true
        }
    }
}

struct MoodChip: View {
    let mood: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(mood.capitalized)
                .font(SSTypography.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? SSColors.primary : SSColors.surface)
                .foregroundColor(isSelected ? .white : SSColors.textPrimary)
                .cornerRadius(16)
        }
    }
}

struct FlowLayout: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(SSTypography.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(SSColors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}
