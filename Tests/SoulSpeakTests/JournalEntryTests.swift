import XCTest
@testable import SoulSpeak

final class JournalEntryTests: XCTestCase {
    func testJournalEntryCreation() {
        let entry = JournalEntry(
            title: "Test Entry",
            content: "This is a test journal entry with some content.",
            mood: "happy",
            moodIntensity: 8,
            tags: ["test", "first"]
        )
        
        XCTAssertEqual(entry.title, "Test Entry")
        XCTAssertEqual(entry.mood, "happy")
        XCTAssertEqual(entry.moodIntensity, 8)
        XCTAssertEqual(entry.tags, ["test", "first"])
        XCTAssertFalse(entry.isFavorite)
        XCTAssertFalse(entry.isEncrypted)
        XCTAssertEqual(entry.wordCount, 9)
    }
    
    func testJournalEntryDefaults() {
        let entry = JournalEntry()
        
        XCTAssertEqual(entry.title, "")
        XCTAssertEqual(entry.content, "")
        XCTAssertEqual(entry.mood, "neutral")
        XCTAssertEqual(entry.moodIntensity, 5)
        XCTAssertTrue(entry.tags.isEmpty)
        XCTAssertFalse(entry.isFavorite)
        XCTAssertFalse(entry.isEncrypted)
        XCTAssertEqual(entry.wordCount, 0)
    }
    
    func testJournalEntryWordCount() {
        let entry = JournalEntry(content: "one two three four five")
        XCTAssertEqual(entry.wordCount, 5)
    }
    
    func testJournalEntryWithEncryption() {
        let entry = JournalEntry(
            title: "Secret",
            content: "Private thoughts",
            isEncrypted: true
        )
        XCTAssertTrue(entry.isEncrypted)
    }
    
    func testJournalEntryFavorite() {
        let entry = JournalEntry(isFavorite: true)
        XCTAssertTrue(entry.isFavorite)
    }
}
