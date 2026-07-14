import Foundation

final class MockRitualService: RitualServiceProtocol {
    var rituals: [Ritual] = []
    
    func createRitual(_ ritual: Ritual) async throws {
        rituals.append(ritual)
    }
    
    func updateRitual(_ ritual: Ritual) async throws {}
    
    func deleteRitual(_ ritual: Ritual) async throws {
        rituals.removeAll { $0.id == ritual.id }
    }
    
    func getActiveRituals() async throws -> [Ritual] {
        rituals.filter { $0.isActive }
    }
    
    func completeRitual(_ ritual: Ritual) async throws {
        ritual.completionCount += 1
        ritual.lastCompletedAt = Date()
    }
    
    func getRitualHistory(days: Int) async throws -> [Ritual] {
        rituals
    }
}
