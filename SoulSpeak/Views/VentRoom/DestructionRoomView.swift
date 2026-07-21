import SwiftUI
import SceneKit

/// Realistic 3D Vent/Rage Room built with SceneKit.
/// Features: 3D room with physics, destructible objects (plates, walls, dummy),
/// tools (sledgehammer, boxing gloves), realistic sound effects, and haptic feedback.
///
/// 3D Model files expected (.usdz format) — add to project bundle:
/// - sledgehammer.usdz
/// - punching_bag.usdz
/// - boxing_gloves.usdz
/// - plate.usdz
/// - room.usdz (optional — will generate programmatically if missing)
///
/// Sound files expected (.mp3):
/// - glass_break.mp3
/// - sledgehammer_hit.mp3
/// - punch_impact.mp3
/// - wall_crack.mp3
/// - plate_shatter.mp3
/// - wood_break.mp3
/// - spray_sound.mp3
struct DestructionRoomView: View {
    let onRelease: () -> Void

    @State private var selectedTool: RageTool = .fists
    @State private var roomDamage: Double = 0
    @State private var hitCount: Int = 0
    @State private var showRelease = false
    @StateObject private var sceneManager = RageRoomSceneManager()

    var body: some View {
        ZStack {
            // 3D SceneKit View — the actual room
            SceneView(
                scene: sceneManager.scene,
                pointOfView: sceneManager.cameraNode,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .ignoresSafeArea()
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        sceneManager.hitObject(with: selectedTool)
                        hitCount += 1
                        roomDamage = min(1.0, roomDamage + 0.05)
                        if roomDamage >= 0.6 { showRelease = true }
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sceneManager.swipeAction(translation: value.translation, tool: selectedTool)
                    }
                    .onEnded { _ in
                        sceneManager.endSwipe(tool: selectedTool)
                        hitCount += 1
                        roomDamage = min(1.0, roomDamage + 0.03)
                        if roomDamage >= 0.6 { showRelease = true }
                    }
            )

            // HUD Overlay
            VStack {
                // Top bar — damage meter
                HStack {
                    // Damage percentage
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("\(Int(roomDamage * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.6)))

                    Spacer()

                    // Hit counter
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                        Text("\(hitCount)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.6)))
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Tool selector at bottom
                toolSelector

                // Release button
                if showRelease {
                    Button(action: onRelease) {
                        HStack(spacing: 10) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 18))
                            Text("Release")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.2, green: 0.7, blue: 0.4), Color(red: 0.15, green: 0.55, blue: 0.35)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.green.opacity(0.4), radius: 10, y: 4)
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

    // MARK: - Tool Selector
    private var toolSelector: some View {
        HStack(spacing: 20) {
            ForEach(RageTool.allCases, id: \.self) { tool in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTool = tool
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(selectedTool == tool ? tool.color.opacity(0.3) : Color.black.opacity(0.4))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .stroke(selectedTool == tool ? tool.color : Color.white.opacity(0.2), lineWidth: 2)
                                )

                            Image(systemName: tool.icon)
                                .font(.system(size: 22))
                                .foregroundColor(selectedTool == tool ? tool.color : .white.opacity(0.6))
                        }
                        Text(tool.rawValue)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(selectedTool == tool ? .white : .white.opacity(0.5))
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
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
    case throwPlates = "Plates"
    case spray = "Spray"
    case bat = "Bat"

    var icon: String {
        switch self {
        case .fists: return "hand.raised.fill"
        case .sledgehammer: return "hammer.fill"
        case .throwPlates: return "circle.slash"
        case .spray: return "paintbrush.fill"
        case .bat: return "figure.baseball"
        }
    }

    var color: Color {
        switch self {
        case .fists: return .red
        case .sledgehammer: return .orange
        case .throwPlates: return .cyan
        case .spray: return .green
        case .bat: return .purple
        }
    }

    var soundFile: String {
        switch self {
        case .fists: return "punch_impact"
        case .sledgehammer: return "sledgehammer_hit"
        case .throwPlates: return "plate_shatter"
        case .spray: return "spray_sound"
        case .bat: return "wood_break"
        }
    }
}
