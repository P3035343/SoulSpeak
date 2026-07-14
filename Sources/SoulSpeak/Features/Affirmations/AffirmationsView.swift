import SwiftUI
import SwiftData

struct AffirmationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var affirmations: [Affirmation]
    @State private var currentIndex = 0
    @State private var showCreateSheet = false
    @State private var selectedCategory: String? = nil
    
    private let categories = ["all", "self-love", "calm", "growth", "confidence", "gratitude", "healing"]
    
    var filteredAffirmations: [Affirmation] {
        guard let category = selectedCategory, category != "all" else {
            return affirmations
        }
        return affirmations.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SSColors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    categoryPicker
                    affirmationCarousel
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Affirmations")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(SSColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateAffirmationView()
            }
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category.capitalized)
                            .font(SSTypography.caption)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? SSColors.primary : SSColors.surface)
                            .foregroundColor(selectedCategory == category ? .white : SSColors.textPrimary)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    private var affirmationCarousel: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(filteredAffirmations.enumerated()), id: \.element.id) { index, affirmation in
                SSGradientCard(gradient: SSColors.gradientCalm) {
                    VStack(spacing: 16) {
                        Image(systemName: "quote.opening")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                        Text(affirmation.text)
                            .font(SSTypography.affirmation)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        if affirmation.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
                .padding(.horizontal)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 300)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            SSButton(title: "Favorite", style: .outline, icon: "heart") {
                guard !filteredAffirmations.isEmpty else { return }
                filteredAffirmations[currentIndex].isFavorite.toggle()
            }
            SSButton(title: "Share", style: .secondary, icon: "square.and.arrow.up") {}
        }
    }
}

struct CreateAffirmationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var category = "general"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Your Affirmation") {
                    TextEditor(text: $text)
                        .frame(minHeight: 100)
                }
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(["general", "self-love", "calm", "growth", "confidence"], id: \.self) {
                            Text($0.capitalized).tag($0)
                        }
                    }
                }
            }
            .navigationTitle("New Affirmation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let affirmation = Affirmation(text: text, category: category, isCustom: true)
                        modelContext.insert(affirmation)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
            }
        }
    }
}
