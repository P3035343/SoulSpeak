import Foundation

final class MockInsightService: InsightServiceProtocol {
    func generateWeeklyInsight() async throws -> InsightReport {
        InsightReport(
            reportType: "weekly",
            title: "Your Weekly Insight",
            summary: "You had a productive week with consistent journaling.",
            insights: ["Mood improved 15% this week", "Most active on weekday mornings"],
            recommendations: ["Try morning breathwork", "Continue your gratitude practice"]
        )
    }
    
    func generateMonthlyInsight() async throws -> InsightReport {
        InsightReport(
            reportType: "monthly",
            title: "Monthly Reflection",
            summary: "A month of growth and self-discovery.",
            insights: ["Journaling streak of 21 days", "Mood stability increased"],
            recommendations: ["Set a new growth milestone", "Explore new affirmation categories"]
        )
    }
    
    func getInsightHistory() async throws -> [InsightReport] { [] }
    func getLatestInsight() async throws -> InsightReport? { nil }
}
