import SwiftUI

struct RootView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    
    var body: some View {
        ZStack {
            switch appStateManager.currentState {
            case .loading:
                LoadingView()
            case .onboarding:
                OnboardingView()
            case .authenticated:
                MainTabView()
            case .locked:
                BiometricLockView()
            }
            
            if appStateManager.showPrivacyOverlay {
                PrivacyOverlayView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appStateManager.currentState)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            SSColors.background
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(SSColors.primary)
                Text("SoulSpeak")
                    .font(SSTypography.title)
                    .foregroundColor(SSColors.textPrimary)
                ProgressView()
                    .tint(SSColors.primary)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(1)
            
            OfficeLobbyView()
                .tabItem {
                    Label("Office", systemImage: "person.2.fill")
                }
                .tag(2)
            
            MoodTrackingView()
                .tabItem {
                    Label("Mood", systemImage: "heart.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(SSColors.primary)
    }
}

struct BiometricLockView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @StateObject private var biometricAuth = BiometricAuthService()
    
    var body: some View {
        ZStack {
            SSColors.background
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64))
                    .foregroundColor(SSColors.primary)
                Text("SoulSpeak is Locked")
                    .font(SSTypography.title)
                    .foregroundColor(SSColors.textPrimary)
                Text("Authenticate to access your private space")
                    .font(SSTypography.body)
                    .foregroundColor(SSColors.textSecondary)
                SSButton(title: "Unlock", style: .primary) {
                    Task {
                        let success = await biometricAuth.authenticate()
                        if success {
                            appStateManager.unlock()
                        }
                    }
                }
            }
            .padding()
        }
        .task {
            let success = await biometricAuth.authenticate()
            if success {
                appStateManager.unlock()
            }
        }
    }
}
