import Foundation
import SwiftData

@Model
final class InsightReport {
    @Attribute(.unique) var id: UUID
    var reportType: String
    var title: String
    var summary: String
    var insights: [String]
    var recommendations: [String]
    var periodStart: Date
    var periodEnd: Date
    var generatedAt: Date
    var moodTrend: String?
    var topTriggers: [String]
    var topActivities: [String]
    
    init(
        id: UUID = UUID(),
        reportType: String = "weekly",
        title: String,
        summary: String = "",
        insights: [String] = [],
        recommendations: [String] = [],
        periodStart: Date = Date(),
        periodEnd: Date = Date()
    ) {
        self.id = id
        self.reportType = reportType
        self.title = title
        self.summary = summary
        self.insights = insights
        self.recommendations = recommendations
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.generatedAt = Date()
        self.topTriggers = []
        self.topActivities = []
    }
}
