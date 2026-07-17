import SwiftUI

struct RootView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    
    var body: some View {
        ZStack {
            switch appStateManager.currentState {
            case .loading:
                MainTabView()
            case .onboarding:
                MainTabView()
            case .authenticated:
                MainTabView()
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
