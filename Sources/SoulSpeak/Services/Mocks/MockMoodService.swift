import Foundation

final class MockMoodService: MoodServiceProtocol {
    var moodEntries: [MoodEntry] = []
    
    func logMood(_ entry: MoodEntry) async throws {
        moodEntries.append(entry)
    }
    
    func getMoodHistory(days: Int) async throws -> [MoodEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return moodEntries.filter { $0.timestamp >= cutoff }
    }
    
    func getMoodTrend(days: Int) async throws -> String {
        "improving"
    }
    
    func getAverageMood(days: Int) async throws -> Double {
        guard !moodEntries.isEmpty else { return 5.0 }
        let total = moodEntries.reduce(0) { $0 + $1.intensity }
        return Double(total) / Double(moodEntries.count)
    }
    
    func getMostCommonTriggers(days: Int) async throws -> [String] {
        ["work", "sleep", "exercise"]
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) async throws {
        moodEntries.removeAll { $0.id == entry.id }
    }
}
