import Foundation

final class MockGratitudeService: GratitudeServiceProtocol {
    var entries: [GratitudeEntry] = []
    
    func createEntry(_ entry: GratitudeEntry) async throws {
        entries.append(entry)
    }
    
    func getEntries(limit: Int) async throws -> [GratitudeEntry] {
        Array(entries.prefix(limit))
    }
    
    func getTodayEntry() async throws -> GratitudeEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }
    
    func getStreak() async throws -> Int { 7 }
    
    func deleteEntry(_ entry: GratitudeEntry) async throws {
        entries.removeAll { $0.id == entry.id }
    }
}
