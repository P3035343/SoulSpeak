import Foundation
import SwiftData

@Model
final class ThemePreference {
    @Attribute(.unique) var id: UUID
    var themeName: String
    var primaryColorHex: String
    var secondaryColorHex: String
    var backgroundColorHex: String
    var fontFamily: String
    var isActive: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        themeName: String = "Default",
        primaryColorHex: String = "#6B4EAB",
        secondaryColorHex: String = "#9B7ED8",
        backgroundColorHex: String = "#F8F6FF",
        fontFamily: String = "rounded",
        isActive: Bool = false
    ) {
        self.id = id
        self.themeName = themeName
        self.primaryColorHex = primaryColorHex
        self.secondaryColorHex = secondaryColorHex
        self.backgroundColorHex = backgroundColorHex
        self.fontFamily = fontFamily
        self.isActive = isActive
        self.createdAt = Date()
    }
}
