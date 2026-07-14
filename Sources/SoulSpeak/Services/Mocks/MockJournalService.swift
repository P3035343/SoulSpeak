import Foundation

final class MockJournalService: JournalServiceProtocol {
    var entries: [JournalEntry] = []
    
    func createEntry(_ entry: JournalEntry) async throws {
        entries.append(entry)
    }
    
    func updateEntry(_ entry: JournalEntry) async throws {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) async throws {
        entries.removeAll { $0.id == entry.id }
    }
    
    func fetchEntries(limit: Int?, offset: Int?) async throws -> [JournalEntry] {
        let start = offset ?? 0
        let end = min(start + (limit ?? entries.count), entries.count)
        return Array(entries[start..<end])
    }
    
    func searchEntries(query: String) async throws -> [JournalEntry] {
        entries.filter { $0.content.localizedCaseInsensitiveContains(query) }
    }
    
    func fetchFavorites() async throws -> [JournalEntry] {
        entries.filter { $0.isFavorite }
    }
    
    func getEntryCount() async throws -> Int {
        entries.count
    }
}
