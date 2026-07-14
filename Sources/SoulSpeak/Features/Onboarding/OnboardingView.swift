import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var currentPage = 0
    
    private let pages: [(icon: String, title: String, description: String)] = [
        ("heart.circle.fill", "Welcome to SoulSpeak", "Your private space for self-reflection, growth, and inner peace."),
        ("lock.shield.fill", "Your Privacy Matters", "All your data stays on your device, protected by encryption and biometric security."),
        ("book.fill", "Journal Your Journey", "Express yourself freely with guided prompts and AI-powered insights."),
        ("chart.line.uptrend.xyaxis", "Track Your Growth", "Monitor your mood, build streaks, and celebrate milestones."),
    ]
    
    var body: some View {
        ZStack {
            SSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()
                            Image(systemName: pages[index].icon)
                                .font(.system(size: 80))
                                .foregroundStyle(SSColors.gradientPrimary)
                            
                            Text(pages[index].title)
                                .font(SSTypography.title)
                                .foregroundColor(SSColors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].description)
                                .font(SSTypography.body)
                                .foregroundColor(SSColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        SSButton(title: "Get Started", style: .primary, icon: "arrow.right") {
                            appStateManager.completeOnboarding()
                        }
                    } else {
                        SSButton(title: "Next", style: .primary) {
                            withAnimation { currentPage += 1 }
                        }
                    }
                    
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            appStateManager.completeOnboarding()
                        }
                        .font(SSTypography.callout)
                        .foregroundColor(SSColors.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}
