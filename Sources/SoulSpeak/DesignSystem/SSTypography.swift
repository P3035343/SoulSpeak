import SwiftUI

enum SSTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title, design: .rounded).weight(.semibold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.medium)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    static let callout = Font.system(.callout, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let caption2 = Font.system(.caption2, design: .rounded)
    
    static let journalBody = Font.system(.body, design: .serif)
    static let journalTitle = Font.system(.title2, design: .serif).weight(.medium)
    static let affirmation = Font.system(.title, design: .rounded).weight(.medium).italic()
    static let quote = Font.system(.title3, design: .serif).italic()
    
    static func monospacedBody() -> Font {
        .system(.body, design: .monospaced)
    }
}
