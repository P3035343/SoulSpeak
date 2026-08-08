import SwiftUI
import SceneKit

/// Realistic 3D Vent/Rage Room built with SceneKit.
/// Features: bright industrial room, ragdoll dummy, tires, bottles, TV,
/// physics destruction, haptic feedback, and system sound effects.
///
/// Optional sound files (.mp3) for enhanced audio:
/// - glass_break.mp3, sledgehammer_hit.mp3, punch_impact.mp3
/// - plate_shatter.mp3, wood_break.mp3, spray_sound.mp3
/// (App works without these — uses system sounds as fallback)
struct DestructionRoomView: View {
    let onRelease: () -> Void

    @State private var selectedTool: RageTool = .fists
    @State private var roomDamage: Double = 0
    @State private var hitCount: Int = 0
    @State private var showRelease = false
    @State private var comboCount: Int = 0
    @State private var showCombo = false
    @State private var lastHitTime: Date = Date()
    @StateObject private var sceneManager = RageRoomSceneManager()

    var body: some View {
        ZStack {
            // 3D SceneKit View — the rage room
            SceneView(
                scene: sceneManager.scene,
                pointOfView: sceneManager.cameraNode,
                options: [.allowsCameraControl]
            )
            .ignoresSafeArea()
            .onTapGesture { location in
                performHit()
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        sceneManager.swipeAction(translation: value.translation, tool: selectedTool)
                    }
                    .onEnded { value in
                        performSwipe(value)
                    }
            )

            // HUD Overlay
            VStack {
                // Top bar — damage meter + combo
                HStack {
                    // Damage bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("RAGE: \(Int(roomDamage * 100))%")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }

                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * CGFloat(roomDamage), height: 6)
                            }
                        }
                        .frame(width: 120, height: 6)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.7)))

                    Spacer()

                    // Hit counter + combo
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.yellow)
                            Text("\(hitCount)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }

                        if showCombo && comboCount > 2 {
                            Text("\(comboCount)x COMBO!")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.yellow)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.7)))
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Instruction text (fades after first hit)
                if hitCount == 0 {
                    Text("TAP to smash • SWIPE to throw")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.5)))
                        .transition(.opacity)
                        .padding(.bottom, 10)
                }

                // Tool selector at bottom
                toolSelector

                // Release button (appears at 60% damage)
                if showRelease {
                    Button(action: onRelease) {
                        HStack(spacing: 10) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 18))
                            Text("Release & Let Go")
                                .font(.system(size: 17, weight: .bold, design: .serif))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 36)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.2, green: 0.7, blue: 0.4), Color(red: 0.15, green: 0.55, blue: 0.35)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.green.opacity(0.5), radius: 12, y: 4)
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 10)
                }
            }
        }
        .onAppear {
            sceneManager.setupRoom()
        }
    }

    // MARK: - Actions
    private func performHit() {
        sceneManager.hitObject(with: selectedTool)
        hitCount += 1

        // Combo system
        let now = Date()
        if now.timeIntervalSince(lastHitTime) < 1.0 {
            comboCount += 1
            withAnimation(.spring(response: 0.2)) { showCombo = true }
        } else {
            comboCount = 1
            showCombo = false
        }
        lastHitTime = now

        // Damage increases faster with combos
        let damageAmount = 0.03 + (Double(comboCount) * 0.01)
        roomDamage = min(1.0, roomDamage + damageAmount)

        if roomDamage >= 0.6 && !showRelease {
            withAnimation(.spring()) { showRelease = true }
        }

        // Hide combo text after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if Date().timeIntervalSince(lastHitTime) >= 1.0 {
                withAnimation { showCombo = false }
            }
        }
    }

    private func performSwipe(_ value: DragGesture.Value) {
        sceneManager.endSwipe(tool: selectedTool)
        hitCount += 1
        roomDamage = min(1.0, roomDamage + 0.04)

        if roomDamage >= 0.6 && !showRelease {
            withAnimation(.spring()) { showRelease = true }
        }
    }

    // MARK: - Tool Selector
    private var toolSelector: some View {
        HStack(spacing: 16) {
            ForEach(RageTool.allCases, id: \.self) { tool in
                Button(action: {
                    withAnimation(.spring(response: 0.25)) {
                        selectedTool = tool
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(selectedTool == tool ? tool.color.opacity(0.4) : Color.black.opacity(0.5))
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Circle()
                                        .stroke(selectedTool == tool ? tool.color : Color.white.opacity(0.2), lineWidth: selectedTool == tool ? 3 : 1)
                                )
                                .shadow(color: selectedTool == tool ? tool.color.opacity(0.5) : .clear, radius: 8)

                            Image(systemName: tool.icon)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(selectedTool == tool ? .white : .white.opacity(0.6))
                        }
                        Text(tool.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(selectedTool == tool ? .white : .white.opacity(0.5))
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.bottom, 16)
    }
}

// MARK: - Rage Tool Enum
enum RageTool: String, CaseIterable {
    case fists = "Fists"
    case sledgehammer = "Sledge"
    case bat = "Bat"
    case throwPlates = "Throw"
    case spray = "Spray"

    var icon: String {
        switch self {
        case .fists: return "hand.raised.fill"
        case .sledgehammer: return "hammer.fill"
        case .bat: return "figure.baseball"
        case .throwPlates: return "circle.slash"
        case .spray: return "paintbrush.fill"
        }
    }

    var color: Color {
        switch self {
        case .fists: return .red
        case .sledgehammer: return .orange
        case .bat: return .purple
        case .throwPlates: return .cyan
        case .spray: return .green
        }
    }

    var soundFile: String {
        switch self {
        case .fists: return "punch_impact"
        case .sledgehammer: return "sledgehammer_hit"
        case .bat: return "wood_break"
        case .throwPlates: return "plate_shatter"
        case .spray: return "spray_sound"
        }
    }
}
