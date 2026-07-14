import XCTest
@testable import SoulSpeak

final class StreakTests: XCTestCase {
    func testStreakCreation() {
        let streak = Streak(type: "journal")
        XCTAssertEqual(streak.type, "journal")
        XCTAssertEqual(streak.currentCount, 0)
        XCTAssertEqual(streak.longestCount, 0)
        XCTAssertTrue(streak.isActive)
    }
    
    func testStreakIncrement() {
        let streak = Streak(type: "journal")
        streak.incrementStreak()
        XCTAssertEqual(streak.currentCount, 1)
        XCTAssertEqual(streak.longestCount, 1)
    }
    
    func testStreakMultipleIncrements() {
        let streak = Streak(type: "journal")
        streak.incrementStreak()
        streak.incrementStreak()
        streak.incrementStreak()
        XCTAssertEqual(streak.currentCount, 3)
        XCTAssertEqual(streak.longestCount, 3)
    }
    
    func testStreakReset() {
        let streak = Streak(type: "journal", currentCount: 5, longestCount: 5)
        streak.resetStreak()
        XCTAssertEqual(streak.currentCount, 0)
        XCTAssertFalse(streak.isActive)
        XCTAssertEqual(streak.longestCount, 5)
    }
    
    func testStreakLongestPreservedAfterReset() {
        let streak = Streak(type: "mood", currentCount: 10, longestCount: 10)
        streak.resetStreak()
        streak.incrementStreak()
        streak.incrementStreak()
        XCTAssertEqual(streak.currentCount, 2)
        XCTAssertEqual(streak.longestCount, 10)
    }
}
