import Foundation
import SwiftData

@Model
final class Streak {
    @Attribute(.unique) var id: UUID
    var type: String
    var currentCount: Int
    var longestCount: Int
    var lastActivityDate: Date
    var startDate: Date
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        type: String = "journal",
        currentCount: Int = 0,
        longestCount: Int = 0
    ) {
        self.id = id
        self.type = type
        self.currentCount = currentCount
        self.longestCount = longestCount
        self.lastActivityDate = Date()
        self.startDate = Date()
        self.isActive = true
    }
    
    func incrementStreak() {
        currentCount += 1
        if currentCount > longestCount {
            longestCount = currentCount
        }
        lastActivityDate = Date()
    }
    
    func resetStreak() {
        currentCount = 0
        isActive = false
    }
}
