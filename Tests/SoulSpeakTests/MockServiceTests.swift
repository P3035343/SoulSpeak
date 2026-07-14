import XCTest
@testable import SoulSpeak

final class MockServiceTests: XCTestCase {
    func testMockJournalServiceCreate() async throws {
        let service = MockJournalService()
        let entry = JournalEntry(title: "Test", content: "Content")
        try await service.createEntry(entry)
        
        let entries = try await service.fetchEntries(limit: nil, offset: nil)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.title, "Test")
    }
    
    func testMockJournalServiceDelete() async throws {
        let service = MockJournalService()
        let entry = JournalEntry(title: "Delete Me", content: "Content")
        try await service.createEntry(entry)
        try await service.deleteEntry(entry)
        
        let count = try await service.getEntryCount()
        XCTAssertEqual(count, 0)
    }
    
    func testMockJournalServiceSearch() async throws {
        let service = MockJournalService()
        try await service.createEntry(JournalEntry(title: "Apple", content: "I love apples"))
        try await service.createEntry(JournalEntry(title: "Banana", content: "Bananas are great"))
        
        let results = try await service.searchEntries(query: "apple")
        XCTAssertEqual(results.count, 1)
    }
    
    func testMockMoodServiceLog() async throws {
        let service = MockMoodService()
        let entry = MoodEntry(mood: "happy", intensity: 8)
        try await service.logMood(entry)
        
        let history = try await service.getMoodHistory(days: 7)
        XCTAssertEqual(history.count, 1)
    }
    
    func testMockAffirmationServiceDaily() async throws {
        let service = MockAffirmationService()
        let daily = try await service.getDailyAffirmation()
        XCTAssertFalse(daily.text.isEmpty)
    }
    
    func testMockGrowthServiceProgress() async throws {
        let service = MockGrowthService()
        let milestone = GrowthMilestone(title: "Read 10 books")
        try await service.createMilestone(milestone)
        try await service.updateProgress(milestone, progress: 0.5)
        
        XCTAssertEqual(milestone.progress, 0.5)
        XCTAssertFalse(milestone.isCompleted)
    }
    
    func testMockGrowthServiceComplete() async throws {
        let service = MockGrowthService()
        let milestone = GrowthMilestone(title: "Complete course")
        try await service.createMilestone(milestone)
        try await service.updateProgress(milestone, progress: 1.0)
        
        XCTAssertTrue(milestone.isCompleted)
        XCTAssertNotNil(milestone.completedAt)
    }
}
