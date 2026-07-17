import SwiftUI

/// Immersive scenery backgrounds for journaling.
/// User selects a relaxing environment while they write.
struct JournalSceneryView: View {
    @Binding var selectedScenery: SceneryType
    @StateObject private var audioPlayer = AudioPlayerService.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(SceneryType.allCases, id: \.self) { scenery in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedScenery = scenery
                        }
                        // Play ambient sound for this scenery
                        audioPlayer.playAmbient(fileName: scenery.ambientFileName)
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                scenery.backgroundView
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                
                                if selectedScenery == scenery {
                                    Circle()
                                        .stroke(SSColors.primary, lineWidth: 3)
                                        .frame(width: 76, height: 76)
                                }
                            }
                            
                            Text(scenery.displayName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(selectedScenery == scenery ? SSColors.primary : .secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

/// Available scenery environments for relaxation.
enum SceneryType: String, CaseIterable {
    case ocean = "Ocean"
    case forest = "Forest"
    case sunset = "Sunset"
    case rain = "Rain"
    case mountains = "Mountains"
    case night = "Night Sky"
    case garden = "Garden"
    case fireplace = "Fireplace"
    
    var displayName: String { rawValue }
    
    var ambientFileName: String {
        switch self {
        case .ocean: return "ambient_ocean"
        case .forest: return "ambient_forest"
        case .sunset: return "ambient_sunset"
        case .rain: return "ambient_rain"
        case .mountains: return "ambient_wind"
        case .night: return "ambient_night"
        case .garden: return "ambient_birds"
        case .fireplace: return "ambient_fire"
        }
    }
    
    var musicFileName: String {
        switch self {
        case .ocean: return "music_calm"
        case .forest: return "music_nature"
        case .sunset: return "music_peaceful"
        case .rain: return "music_piano"
        case .mountains: return "music_meditation"
        case .night: return "music_sleep"
        case .garden: return "music_gentle"
        case .fireplace: return "music_cozy"
        }
    }
    
    /// Animated gradient background for each scenery
    @ViewBuilder
    var backgroundView: some View {
        switch self {
        case .ocean:
            LinearGradient(colors: [Color(red: 0.1, green: 0.4, blue: 0.7), Color(red: 0.2, green: 0.6, blue: 0.9)], startPoint: .top, endPoint: .bottom)
        case .forest:
            LinearGradient(colors: [Color(red: 0.1, green: 0.4, blue: 0.2), Color(red: 0.2, green: 0.6, blue: 0.3)], startPoint: .top, endPoint: .bottom)
        case .sunset:
            LinearGradient(colors: [Color(red: 0.9, green: 0.4, blue: 0.2), Color(red: 0.95, green: 0.7, blue: 0.3)], startPoint: .top, endPoint: .bottom)
        case .rain:
            LinearGradient(colors: [Color(red: 0.3, green: 0.35, blue: 0.4), Color(red: 0.5, green: 0.55, blue: 0.6)], startPoint: .top, endPoint: .bottom)
        case .mountains:
            LinearGradient(colors: [Color(red: 0.5, green: 0.6, blue: 0.8), Color(red: 0.7, green: 0.8, blue: 0.9)], startPoint: .top, endPoint: .bottom)
        case .night:
            LinearGradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.1, green: 0.1, blue: 0.3)], startPoint: .top, endPoint: .bottom)
        case .garden:
            LinearGradient(colors: [Color(red: 0.5, green: 0.8, blue: 0.4), Color(red: 0.7, green: 0.9, blue: 0.5)], startPoint: .top, endPoint: .bottom)
        case .fireplace:
            LinearGradient(colors: [Color(red: 0.6, green: 0.3, blue: 0.1), Color(red: 0.9, green: 0.5, blue: 0.2)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    /// Full-screen animated background
    @ViewBuilder
    var fullBackground: some View {
        ZStack {
            backgroundView.ignoresSafeArea()
            
            // Animated particles for atmosphere
            SceneryParticles(type: self)
        }
    }
}

/// Animated particles that create atmosphere for each scenery type.
struct SceneryParticles: View {
    let type: SceneryType
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.05...0.2)))
                    .frame(width: CGFloat.random(in: 2...8))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: animate ? CGFloat.random(in: -300...300) : CGFloat.random(in: -300...300)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...7))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
