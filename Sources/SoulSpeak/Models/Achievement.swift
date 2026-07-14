import Foundation
import SwiftData

@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var title: String
    var achievementDescription: String
    var iconName: String
    var category: String
    var isUnlocked: Bool
    var unlockedAt: Date?
    var progress: Double
    var requiredCount: Int
    var currentCount: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        achievementDescription: String = "",
        iconName: String = "star.fill",
        category: String = "general",
        requiredCount: Int = 1
    ) {
        self.id = id
        self.title = title
        self.achievementDescription = achievementDescription
        self.iconName = iconName
        self.category = category
        self.isUnlocked = false
        self.progress = 0.0
        self.requiredCount = requiredCount
        self.currentCount = 0
    }
}
