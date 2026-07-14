import Foundation
import SwiftData

@Model
final class GratitudeEntry {
    @Attribute(.unique) var id: UUID
    var items: [String]
    var reflection: String?
    var mood: String?
    var date: Date
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        items: [String] = [],
        reflection: String? = nil,
        mood: String? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.items = items
        self.reflection = reflection
        self.mood = mood
        self.date = date
        self.createdAt = Date()
    }
}
