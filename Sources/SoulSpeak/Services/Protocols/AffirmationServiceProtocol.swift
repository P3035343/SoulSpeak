import Foundation

protocol AffirmationServiceProtocol {
    func getDailyAffirmation() async throws -> Affirmation
    func getAffirmations(category: String?) async throws -> [Affirmation]
    func createCustomAffirmation(_ text: String, category: String) async throws -> Affirmation
    func toggleFavorite(_ affirmation: Affirmation) async throws
    func markViewed(_ affirmation: Affirmation) async throws
    func getFavorites() async throws -> [Affirmation]
}
