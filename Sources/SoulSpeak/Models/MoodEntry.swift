import Foundation
import SwiftData

@Model
final class MoodEntry {
    @Attribute(.unique) var id: UUID
    var mood: String
    var intensity: Int
    var note: String?
    var triggers: [String]
    var activities: [String]
    var energyLevel: Int
    var sleepQuality: Int?
    var timestamp: Date
    var weatherCondition: String?
    var location: String?
    
    init(
        id: UUID = UUID(),
        mood: String,
        intensity: Int = 5,
        note: String? = nil,
        triggers: [String] = [],
        activities: [String] = [],
        energyLevel: Int = 5,
        sleepQuality: Int? = nil,
        weatherCondition: String? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.mood = mood
        self.intensity = intensity
        self.note = note
        self.triggers = triggers
        self.activities = activities
        self.energyLevel = energyLevel
        self.sleepQuality = sleepQuality
        self.timestamp = Date()
        self.weatherCondition = weatherCondition
        self.location = location
    }
}
