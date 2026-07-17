import SwiftUI
import Combine

enum AppState: Equatable {
    case loading
    case onboarding
    case authenticated
}

@MainActor
final class AppStateManager: ObservableObject {
    @Published var currentState: AppState = .authenticated
    @Published var isFirstLaunch: Bool = true
    @Published var hasCompletedOnboarding: Bool = false
    @Published var showPrivacyOverlay: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadInitialState()
    }
    
    private func loadInitialState() {
        let hasOnboarded = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = hasOnboarded
        currentState = .authenticated
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
        currentState = .authenticated
    }
    
    func unlock() {
        currentState = .authenticated
    }
    
    func resetApp() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = false
        currentState = .onboarding
    }
}
