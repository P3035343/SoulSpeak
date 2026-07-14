import Foundation

protocol JournalServiceProtocol {
    func createEntry(_ entry: JournalEntry) async throws
    func updateEntry(_ entry: JournalEntry) async throws
    func deleteEntry(_ entry: JournalEntry) async throws
    func fetchEntries(limit: Int?, offset: Int?) async throws -> [JournalEntry]
    func searchEntries(query: String) async throws -> [JournalEntry]
    func fetchFavorites() async throws -> [JournalEntry]
    func getEntryCount() async throws -> Int
}
