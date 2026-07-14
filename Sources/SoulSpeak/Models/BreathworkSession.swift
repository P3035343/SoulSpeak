import Foundation
import SwiftData

@Model
final class BreathworkSession {
    @Attribute(.unique) var id: UUID
    var technique: String
    var duration: TimeInterval
    var cyclesCompleted: Int
    var moodBefore: String?
    var moodAfter: String?
    var notes: String?
    var completedAt: Date
    
    init(
        id: UUID = UUID(),
        technique: String = "box",
        duration: TimeInterval = 0,
        cyclesCompleted: Int = 0,
        moodBefore: String? = nil,
        moodAfter: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.technique = technique
        self.duration = duration
        self.cyclesCompleted = cyclesCompleted
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
        self.notes = notes
        self.completedAt = Date()
    }
}
