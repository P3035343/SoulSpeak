import XCTest
@testable import SoulSpeak

final class MoodEntryTests: XCTestCase {
    func testMoodEntryCreation() {
        let entry = MoodEntry(
            mood: "happy",
            intensity: 8,
            note: "Great day!",
            triggers: ["exercise", "sunshine"],
            energyLevel: 9
        )
        
        XCTAssertEqual(entry.mood, "happy")
        XCTAssertEqual(entry.intensity, 8)
        XCTAssertEqual(entry.note, "Great day!")
        XCTAssertEqual(entry.triggers, ["exercise", "sunshine"])
        XCTAssertEqual(entry.energyLevel, 9)
    }
    
    func testMoodEntryDefaults() {
        let entry = MoodEntry(mood: "neutral")
        
        XCTAssertEqual(entry.intensity, 5)
        XCTAssertNil(entry.note)
        XCTAssertTrue(entry.triggers.isEmpty)
        XCTAssertEqual(entry.energyLevel, 5)
        XCTAssertNil(entry.sleepQuality)
    }
    
    func testMoodEntryWithSleepQuality() {
        let entry = MoodEntry(mood: "tired", sleepQuality: 3)
        XCTAssertEqual(entry.sleepQuality, 3)
    }
    
    func testMoodEntryTimestamp() {
        let entry = MoodEntry(mood: "calm")
        XCTAssertNotNil(entry.timestamp)
        let timeDifference = abs(entry.timestamp.timeIntervalSinceNow)
        XCTAssertLessThan(timeDifference, 1.0)
    }
}
