import XCTest
@testable import SoulSpeak

@MainActor
final class AppStateManagerTests: XCTestCase {
    func testInitialState() {
        let manager = AppStateManager()
        // First launch should show onboarding
        XCTAssertTrue(manager.currentState == .onboarding || manager.currentState == .locked)
    }
    
    func testCompleteOnboarding() {
        let manager = AppStateManager()
        manager.completeOnboarding()
        XCTAssertTrue(manager.hasCompletedOnboarding)
        XCTAssertEqual(manager.currentState, .authenticated)
    }
    
    func testLockAndUnlock() {
        let manager = AppStateManager()
        manager.completeOnboarding()
        manager.lock()
        XCTAssertEqual(manager.currentState, .locked)
        manager.unlock()
        XCTAssertEqual(manager.currentState, .authenticated)
    }
    
    func testResetApp() {
        let manager = AppStateManager()
        manager.completeOnboarding()
        manager.resetApp()
        XCTAssertFalse(manager.hasCompletedOnboarding)
        XCTAssertEqual(manager.currentState, .onboarding)
    }
    
    func testPrivacyOverlayDefault() {
        let manager = AppStateManager()
        XCTAssertFalse(manager.showPrivacyOverlay)
    }
}
