import XCTest
@testable import SoulSpeak

final class AffirmationTests: XCTestCase {
    func testAffirmationCreation() {
        let affirmation = Affirmation(
            text: "I am worthy",
            category: "self-love",
            isCustom: true
        )
        
        XCTAssertEqual(affirmation.text, "I am worthy")
        XCTAssertEqual(affirmation.category, "self-love")
        XCTAssertTrue(affirmation.isCustom)
        XCTAssertFalse(affirmation.isFavorite)
        XCTAssertEqual(affirmation.timesViewed, 0)
    }
    
    func testAffirmationDefaults() {
        let affirmation = Affirmation(text: "Test")
        
        XCTAssertEqual(affirmation.category, "general")
        XCTAssertFalse(affirmation.isCustom)
        XCTAssertFalse(affirmation.isFavorite)
        XCTAssertNil(affirmation.lastViewedAt)
    }
    
    func testAffirmationWithAttribution() {
        let affirmation = Affirmation(
            text: "Be the change",
            sourceAttribution: "Mahatma Gandhi"
        )
        XCTAssertEqual(affirmation.sourceAttribution, "Mahatma Gandhi")
    }
    
    func testAffirmationFavoriteToggle() {
        let affirmation = Affirmation(text: "Test")
        XCTAssertFalse(affirmation.isFavorite)
        affirmation.isFavorite = true
        XCTAssertTrue(affirmation.isFavorite)
    }
}
