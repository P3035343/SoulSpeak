import Foundation

protocol GratitudeServiceProtocol {
    func createEntry(_ entry: GratitudeEntry) async throws
    func getEntries(limit: Int) async throws -> [GratitudeEntry]
    func getTodayEntry() async throws -> GratitudeEntry?
    func getStreak() async throws -> Int
    func deleteEntry(_ entry: GratitudeEntry) async throws
}
