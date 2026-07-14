import XCTest
@testable import SoulSpeak

final class CrisisDetectionTests: XCTestCase {
    let service = LocalCrisisDetectionService()
    
    func testNoCrisisDetected() {
        let result = service.detectCrisisLanguage(in: "I had a wonderful day at the park with friends.")
        XCTAssertFalse(result.isCrisisDetected)
        XCTAssertEqual(result.severity, .none)
        XCTAssertTrue(result.matchedKeywords.isEmpty)
    }
    
    func testCriticalCrisisDetected() {
        let result = service.detectCrisisLanguage(in: "I want to end my life")
        XCTAssertTrue(result.isCrisisDetected)
        XCTAssertEqual(result.severity, .critical)
        XCTAssertFalse(result.matchedKeywords.isEmpty)
    }
    
    func testHighSeverityDetected() {
        let result = service.detectCrisisLanguage(in: "I feel like I want to hurt myself")
        XCTAssertTrue(result.isCrisisDetected)
        XCTAssertTrue(result.severity == .high || result.severity == .critical)
    }
    
    func testMediumSeverityDetected() {
        let result = service.detectCrisisLanguage(in: "Everything feels hopeless and worthless")
        XCTAssertTrue(result.isCrisisDetected)
        XCTAssertTrue(result.severity == .medium || result.severity == .high)
    }
    
    func testLowSeverityDetected() {
        let result = service.detectCrisisLanguage(in: "I feel so overwhelmed with everything")
        XCTAssertTrue(result.isCrisisDetected)
        XCTAssertEqual(result.severity, .low)
    }
    
    func testDefaultHotlines() {
        let hotlines = service.getDefaultHotlines()
        XCTAssertFalse(hotlines.isEmpty)
        XCTAssertTrue(hotlines.allSatisfy { $0.isHotline })
        XCTAssertTrue(hotlines.contains { $0.phoneNumber == "988" })
    }
    
    func testSuggestedActionForCritical() {
        let result = service.detectCrisisLanguage(in: "suicide")
        XCTAssertTrue(result.suggestedAction.contains("crisis hotline") || result.suggestedAction.contains("emergency"))
    }
    
    func testCaseInsensitiveDetection() {
        let result = service.detectCrisisLanguage(in: "I feel HOPELESS")
        XCTAssertTrue(result.isCrisisDetected)
    }
}
