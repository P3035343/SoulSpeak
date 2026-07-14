import Foundation
import SwiftData

@Model
final class GrowthMilestone {
    @Attribute(.unique) var id: UUID
    var title: String
    var milestoneDescription: String
    var category: String
    var isCompleted: Bool
    var completedAt: Date?
    var targetDate: Date?
    var progress: Double
    var reflectionNote: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        milestoneDescription: String = "",
        category: String = "personal",
        targetDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.milestoneDescription = milestoneDescription
        self.category = category
        self.isCompleted = false
        self.progress = 0.0
        self.createdAt = Date()
        self.targetDate = targetDate
    }
}
