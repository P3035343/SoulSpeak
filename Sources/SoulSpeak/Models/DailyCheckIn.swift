import Foundation
import SwiftData

@Model
final class DailyCheckIn {
    @Attribute(.unique) var id: UUID
    var date: Date
    var overallMood: String
    var energyLevel: Int
    var sleepHours: Double?
    var gratitudeItems: [String]
    var intentions: [String]
    var affirmationOfDay: String?
    var isCompleted: Bool
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        overallMood: String = "neutral",
        energyLevel: Int = 5,
        sleepHours: Double? = nil,
        gratitudeItems: [String] = [],
        intentions: [String] = []
    ) {
        self.id = id
        self.date = date
        self.overallMood = overallMood
        self.energyLevel = energyLevel
        self.sleepHours = sleepHours
        self.gratitudeItems = gratitudeItems
        self.intentions = intentions
        self.isCompleted = false
    }
}
