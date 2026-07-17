import SwiftUI
import Combine

enum AppState: Equatable {
    case loading
    case onboarding
    case authenticated
    case locked
}

@MainActor
final class AppStateManager: ObservableObject {
    @Published var currentState: AppState = .loading
    @Published var isFirstLaunch: Bool = true
    @Published var hasCompletedOnboarding: Bool = false
    @Published var showPrivacyOverlay: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadInitialState()
        setupNotificationObservers()
    }
    
    private func loadInitialState() {
        let hasOnboarded = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = hasOnboarded
        
        if hasOnboarded {
            currentState = .authenticated
        } else {
            currentState = .onboarding
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.showPrivacyOverlay = true
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.showPrivacyOverlay = false
            }
            .store(in: &cancellables)
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
        currentState = .authenticated
    }
    
    func unlock() {
        currentState = .authenticated
    }
    
    func lock() {
        currentState = .locked
    }
    
    func resetApp() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = false
        currentState = .onboarding
    }
}
