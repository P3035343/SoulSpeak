import Foundation

protocol BreathworkServiceProtocol {
    func getBreathworkTechniques() -> [BreathworkTechnique]
    func startSession(technique: String) async throws -> BreathworkSession
    func completeSession(_ session: BreathworkSession, moodAfter: String?) async throws
    func getSessionHistory(limit: Int) async throws -> [BreathworkSession]
    func getTotalSessionTime() async throws -> TimeInterval
}

struct BreathworkTechnique: Identifiable {
    let id: String
    let name: String
    let description: String
    let inhaleSeconds: Double
    let holdSeconds: Double
    let exhaleSeconds: Double
    let holdAfterExhaleSeconds: Double
    let recommendedCycles: Int
    let category: String
}
