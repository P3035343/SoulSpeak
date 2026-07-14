import Foundation
import SwiftData

@Model
final class Affirmation {
    @Attribute(.unique) var id: UUID
    var text: String
    var category: String
    var isCustom: Bool
    var isFavorite: Bool
    var timesViewed: Int
    var lastViewedAt: Date?
    var createdAt: Date
    var sourceAttribution: String?
    
    init(
        id: UUID = UUID(),
        text: String,
        category: String = "general",
        isCustom: Bool = false,
        isFavorite: Bool = false,
        sourceAttribution: String? = nil
    ) {
        self.id = id
        self.text = text
        self.category = category
        self.isCustom = isCustom
        self.isFavorite = isFavorite
        self.timesViewed = 0
        self.createdAt = Date()
        self.sourceAttribution = sourceAttribution
    }
}
