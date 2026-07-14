import Foundation

final class MockAffirmationService: AffirmationServiceProtocol {
    var affirmations: [Affirmation] = [
        Affirmation(text: "I am worthy of love and happiness", category: "self-love"),
        Affirmation(text: "I choose peace over worry", category: "calm"),
        Affirmation(text: "I am growing stronger every day", category: "growth"),
    ]
    
    func getDailyAffirmation() async throws -> Affirmation {
        affirmations.randomElement() ?? Affirmation(text: "You are enough", category: "general")
    }
    
    func getAffirmations(category: String?) async throws -> [Affirmation] {
        if let category = category {
            return affirmations.filter { $0.category == category }
        }
        return affirmations
    }
    
    func createCustomAffirmation(_ text: String, category: String) async throws -> Affirmation {
        let affirmation = Affirmation(text: text, category: category, isCustom: true)
        affirmations.append(affirmation)
        return affirmation
    }
    
    func toggleFavorite(_ affirmation: Affirmation) async throws {
        affirmation.isFavorite.toggle()
    }
    
    func markViewed(_ affirmation: Affirmation) async throws {
        affirmation.timesViewed += 1
        affirmation.lastViewedAt = Date()
    }
    
    func getFavorites() async throws -> [Affirmation] {
        affirmations.filter { $0.isFavorite }
    }
}
