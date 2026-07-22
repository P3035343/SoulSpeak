import SwiftUI

/// Prayer/Outro Screen — Dr. Hope's closing quote, play prayer, scripture of the day
struct PrayerScreen: View {
    @State private var isPlayingPrayer = false
    @State private var breatheAnimation = false
    @StateObject private var audioPlayer = AudioPlayerService.shared

    // Scripture of the day - rotates daily
    private let scriptures = [
        ("Proverbs 3:5-6", "Trust in the Lord with all your heart and lean not on your own understanding."),
        ("Philippians 4:6-7", "Do not be anxious about anything, but in every situation, by prayer and petition, present your requests to God."),
        ("Isaiah 41:10", "So do not fear, for I am with you; do not be dismayed, for I am your God."),
        ("Psalm 46:10", "Be still, and know that I am God."),
        ("Jeremiah 29:11", "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you."),
        ("Matthew 11:28", "Come to me, all you who are weary and burdened, and I will give you rest."),
        ("Romans 8:28", "And we know that in all things God works for the good of those who love him."),
    ]

    private var todaysScripture: (String, String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return scriptures[dayOfYear % scriptures.count]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Calming gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Soft light particles
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(Double.random(in: 0.03...0.08)))
                        .frame(width: CGFloat.random(in: 20...60))
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: breatheAnimation ? CGFloat.random(in: -300...100) : CGFloat.random(in: 0...300)
                        )
                        .animation(.easeInOut(duration: Double.random(in: 4...8)).repeatForever(autoreverses: true).delay(Double(i) * 0.5), value: breatheAnimation)
                }

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 20)

                        // Dr. Hope's closing quote
                        VStack(spacing: 16) {
                            Image("dr_hope")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))

                            Text("\"You showed up today, and that matters more than you know. Rest well, and know you are held.\"")
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal)

                            Text("— Dr. Hope")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        // Play Prayer button
                        Button(action: playPrayer) {
                            HStack(spacing: 12) {
                                Image(systemName: isPlayingPrayer ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 28))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isPlayingPrayer ? "Playing Prayer..." : "Play Closing Prayer")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Dr. Hope's evening blessing")
                                        .font(.system(size: 12))
                                        .opacity(0.7)
                                }
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(18)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)

                        // Scripture of the day
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.yellow.opacity(0.8))
                                Text("Scripture of the Day")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }

                            Text(todaysScripture.1)
                                .font(.system(size: 17, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            Text(todaysScripture.0)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.yellow.opacity(0.7))
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationTitle("Prayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear { breatheAnimation = true }
    }

    private func playPrayer() {
        if isPlayingPrayer {
            audioPlayer.stopVoice()
            isPlayingPrayer = false
        } else {
            audioPlayer.playVoice(fileName: "dr_hope_prayer")
            isPlayingPrayer = true
        }
    }
}
