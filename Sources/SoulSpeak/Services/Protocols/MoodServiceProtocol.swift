import Foundation

protocol MoodServiceProtocol {
    func logMood(_ entry: MoodEntry) async throws
    func getMoodHistory(days: Int) async throws -> [MoodEntry]
    func getMoodTrend(days: Int) async throws -> String
    func getAverageMood(days: Int) async throws -> Double
    func getMostCommonTriggers(days: Int) async throws -> [String]
    func deleteMoodEntry(_ entry: MoodEntry) async throws
}
