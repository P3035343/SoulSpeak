import Foundation
import SwiftData

@Model
final class JournalEntry {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var encryptedContent: Data?
    var mood: String
    var moodIntensity: Int
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var isEncrypted: Bool
    var wordCount: Int
    var promptUsed: String?
    var aiInsight: String?
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        mood: String = "neutral",
        moodIntensity: Int = 5,
        tags: [String] = [],
        isFavorite: Bool = false,
        isEncrypted: Bool = false,
        promptUsed: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.mood = mood
        self.moodIntensity = moodIntensity
        self.tags = tags
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = isFavorite
        self.isEncrypted = isEncrypted
        self.wordCount = content.split(separator: " ").count
        self.promptUsed = promptUsed
    }
}
