import Foundation
import SwiftData

@Model
final class CommunityPost {
    @Attribute(.unique) var id: UUID
    var authorDisplayName: String
    var content: String
    var category: String
    var likesCount: Int
    var isAnonymous: Bool
    var tags: [String]
    var createdAt: Date
    var reportCount: Int
    var isHidden: Bool
    
    init(
        id: UUID = UUID(),
        authorDisplayName: String,
        content: String,
        category: String = "share",
        isAnonymous: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.authorDisplayName = authorDisplayName
        self.content = content
        self.category = category
        self.likesCount = 0
        self.isAnonymous = isAnonymous
        self.tags = tags
        self.createdAt = Date()
        self.reportCount = 0
        self.isHidden = false
    }
}
