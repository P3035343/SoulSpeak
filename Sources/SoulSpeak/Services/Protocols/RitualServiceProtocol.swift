import Foundation

protocol RitualServiceProtocol {
    func createRitual(_ ritual: Ritual) async throws
    func updateRitual(_ ritual: Ritual) async throws
    func deleteRitual(_ ritual: Ritual) async throws
    func getActiveRituals() async throws -> [Ritual]
    func completeRitual(_ ritual: Ritual) async throws
    func getRitualHistory(days: Int) async throws -> [Ritual]
}
