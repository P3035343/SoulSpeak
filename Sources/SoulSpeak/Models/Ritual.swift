import Foundation
import SwiftData

@Model
final class Ritual {
    @Attribute(.unique) var id: UUID
    var name: String
    var ritualDescription: String
    var steps: [String]
    var duration: TimeInterval
    var category: String
    var frequency: String
    var isActive: Bool
    var completionCount: Int
    var lastCompletedAt: Date?
    var createdAt: Date
    var reminderTime: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        ritualDescription: String = "",
        steps: [String] = [],
        duration: TimeInterval = 300,
        category: String = "morning",
        frequency: String = "daily",
        isActive: Bool = true,
        reminderTime: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.ritualDescription = ritualDescription
        self.steps = steps
        self.duration = duration
        self.category = category
        self.frequency = frequency
        self.isActive = isActive
        self.completionCount = 0
        self.createdAt = Date()
        self.reminderTime = reminderTime
    }
}
