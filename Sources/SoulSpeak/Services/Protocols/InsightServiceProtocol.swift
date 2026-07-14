import Foundation

protocol InsightServiceProtocol {
    func generateWeeklyInsight() async throws -> InsightReport
    func generateMonthlyInsight() async throws -> InsightReport
    func getInsightHistory() async throws -> [InsightReport]
    func getLatestInsight() async throws -> InsightReport?
}
