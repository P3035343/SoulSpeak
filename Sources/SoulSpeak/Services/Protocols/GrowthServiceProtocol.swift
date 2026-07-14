import Foundation

protocol GrowthServiceProtocol {
    func createMilestone(_ milestone: GrowthMilestone) async throws
    func updateMilestone(_ milestone: GrowthMilestone) async throws
    func deleteMilestone(_ milestone: GrowthMilestone) async throws
    func getActiveMilestones() async throws -> [GrowthMilestone]
    func getCompletedMilestones() async throws -> [GrowthMilestone]
    func updateProgress(_ milestone: GrowthMilestone, progress: Double) async throws
}
