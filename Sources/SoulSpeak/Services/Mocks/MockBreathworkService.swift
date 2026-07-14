import Foundation

final class MockBreathworkService: BreathworkServiceProtocol {
    func getBreathworkTechniques() -> [BreathworkTechnique] {
        [
            BreathworkTechnique(
                id: "box", name: "Box Breathing",
                description: "Equal duration inhale, hold, exhale, and hold.",
                inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, holdAfterExhaleSeconds: 4,
                recommendedCycles: 4, category: "calm"
            ),
            BreathworkTechnique(
                id: "478", name: "4-7-8 Breathing",
                description: "Calming technique for sleep and anxiety.",
                inhaleSeconds: 4, holdSeconds: 7, exhaleSeconds: 8, holdAfterExhaleSeconds: 0,
                recommendedCycles: 4, category: "sleep"
            ),
            BreathworkTechnique(
                id: "energize", name: "Energizing Breath",
                description: "Quick breaths to increase alertness.",
                inhaleSeconds: 2, holdSeconds: 0, exhaleSeconds: 2, holdAfterExhaleSeconds: 0,
                recommendedCycles: 10, category: "energy"
            ),
        ]
    }
    
    func startSession(technique: String) async throws -> BreathworkSession {
        BreathworkSession(technique: technique)
    }
    
    func completeSession(_ session: BreathworkSession, moodAfter: String?) async throws {
        session.moodAfter = moodAfter
    }
    
    func getSessionHistory(limit: Int) async throws -> [BreathworkSession] { [] }
    func getTotalSessionTime() async throws -> TimeInterval { 3600 }
}
