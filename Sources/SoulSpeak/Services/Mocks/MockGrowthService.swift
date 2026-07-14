import Foundation

final class MockGrowthService: GrowthServiceProtocol {
    var milestones: [GrowthMilestone] = []
    
    func createMilestone(_ milestone: GrowthMilestone) async throws {
        milestones.append(milestone)
    }
    
    func updateMilestone(_ milestone: GrowthMilestone) async throws {}
    
    func deleteMilestone(_ milestone: GrowthMilestone) async throws {
        milestones.removeAll { $0.id == milestone.id }
    }
    
    func getActiveMilestones() async throws -> [GrowthMilestone] {
        milestones.filter { !$0.isCompleted }
    }
    
    func getCompletedMilestones() async throws -> [GrowthMilestone] {
        milestones.filter { $0.isCompleted }
    }
    
    func updateProgress(_ milestone: GrowthMilestone, progress: Double) async throws {
        milestone.progress = progress
        if progress >= 1.0 {
            milestone.isCompleted = true
            milestone.completedAt = Date()
        }
    }
}
