import Foundation

protocol StreakServiceProtocol {
    func getStreak(type: String) async throws -> Streak?
    func updateStreak(type: String) async throws -> Streak
    func resetStreak(type: String) async throws
    func getAllStreaks() async throws -> [Streak]
    func checkAndUpdateStreaks() async throws
}
