import Foundation

final class MockStreakService: StreakServiceProtocol {
    var streaks: [Streak] = []
    
    func getStreak(type: String) async throws -> Streak? {
        streaks.first { $0.type == type }
    }
    
    func updateStreak(type: String) async throws -> Streak {
        if let streak = streaks.first(where: { $0.type == type }) {
            streak.incrementStreak()
            return streak
        }
        let newStreak = Streak(type: type, currentCount: 1, longestCount: 1)
        streaks.append(newStreak)
        return newStreak
    }
    
    func resetStreak(type: String) async throws {
        if let streak = streaks.first(where: { $0.type == type }) {
            streak.resetStreak()
        }
    }
    
    func getAllStreaks() async throws -> [Streak] { streaks }
    func checkAndUpdateStreaks() async throws {}
}
