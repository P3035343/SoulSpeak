import SwiftUI
import SwiftData

struct RitualsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Ritual.createdAt, order: .reverse) private var rituals: [Ritual]
    @State private var showCreateRitual = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if rituals.isEmpty {
                        emptyState
                    } else {
                        ForEach(rituals) { ritual in
                            RitualCard(ritual: ritual) {
                                ritual.completionCount += 1
                                ritual.lastCompletedAt = Date()
                            }
                        }
                    }
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Rituals")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreateRitual = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(SSColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateRitual) {
                CreateRitualView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 64))
                .foregroundColor(SSColors.primary.opacity(0.5))
            Text("Create Your First Ritual")
                .font(SSTypography.title3)
            Text("Build mindful habits with personalized daily rituals")
                .font(SSTypography.body)
                .foregroundColor(SSColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 48)
    }
}

struct RitualCard: View {
    let ritual: Ritual
    let onComplete: () -> Void
    
    var body: some View {
        SSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ritual.name)
                            .font(SSTypography.headline)
                            .foregroundColor(SSColors.textPrimary)
                        Text(ritual.category.capitalized)
                            .font(SSTypography.caption)
                            .foregroundColor(SSColors.textSecondary)
                    }
                    Spacer()
                    Button(action: onComplete) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(SSColors.success)
                    }
                }
                if !ritual.steps.isEmpty {
                    ForEach(ritual.steps, id: \.self) { step in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(SSColors.primary.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text(step)
                                .font(SSTypography.body)
                                .foregroundColor(SSColors.textSecondary)
                        }
                    }
                }
                HStack {
                    Label("\(ritual.completionCount)x", systemImage: "checkmark")
                        .font(SSTypography.caption)
                        .foregroundColor(SSColors.textSecondary)
                    Spacer()
                    Text("\(Int(ritual.duration / 60)) min")
                        .font(SSTypography.caption)
                        .foregroundColor(SSColors.textSecondary)
                }
            }
        }
    }
}

struct CreateRitualView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var steps: [String] = [""]
    @State private var duration: Double = 5
    @State private var category = "morning"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Ritual name", text: $name)
                    TextField("Description", text: $description)
                    Picker("Category", selection: $category) {
                        ForEach(["morning", "evening", "meditation", "movement", "creativity"], id: \.self) {
                            Text($0.capitalized)
                        }
                    }
                }
                Section("Steps") {
                    ForEach(steps.indices, id: \.self) { index in
                        TextField("Step \(index + 1)", text: $steps[index])
                    }
                    Button("Add Step") { steps.append("") }
                }
                Section("Duration") {
                    Slider(value: $duration, in: 1...60, step: 1)
                    Text("\(Int(duration)) minutes")
                }
            }
            .navigationTitle("New Ritual")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let ritual = Ritual(
                            name: name,
                            ritualDescription: description,
                            steps: steps.filter { !$0.isEmpty },
                            duration: duration * 60,
                            category: category
                        )
                        modelContext.insert(ritual)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
