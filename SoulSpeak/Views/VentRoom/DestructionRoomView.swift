import SwiftUI

/// Interactive destruction room — user can break, throw, smash, and spray paint.
/// Combines 2D physics (finger swipes) and tap-to-destroy animations.
struct DestructionRoomView: View {
    let onRelease: () -> Void

    @State private var selectedTool: DestructionTool = .fists
    @State private var destroyedItems: Set<String> = []
    @State private var sprayPoints: [SprayPoint] = []
    @State private var shakeAmount: CGFloat = 0
    @State private var roomDamage: Double = 0
    @State private var showToolPicker = true

    enum DestructionTool: String, CaseIterable {
        case fists = "Fists"
        case sledgehammer = "Sledgehammer"
        case plates = "Throw Plates"
        case spray = "Spray Paint"

        var icon: String {
            switch self {
            case .fists: return "hand.raised.fill"
            case .sledgehammer: return "hammer.fill"
            case .plates: return "circle.circle"
            case .spray: return "paintbrush.fill"
            }
        }

        var color: Color {
            switch self {
            case .fists: return .red
            case .sledgehammer: return .orange
            case .plates: return .blue
            case .spray: return .green
            }
        }
    }

    struct SprayPoint: Identifiable {
        let id = UUID()
        let position: CGPoint
        let color: Color
    }

    var body: some View {
        ZStack {
            // Room background
            roomBackground
                .offset(x: shakeAmount)

            // Destructible items
            destructibleItems

            // Spray paint overlay
            sprayPaintOverlay

            // UI overlay
            VStack {
                // Damage meter
                damageHeader

                Spacer()

                // Tool picker
                toolPicker

                // Release button (appears when damage > 50%)
                if roomDamage > 0.5 {
                    releaseButton
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleInteraction(at: value.location)
                }
        )
    }


    // MARK: - Room Background
    private var roomBackground: some View {
        ZStack {
            // Walls
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.2, blue: 0.18),
                    Color(red: 0.2, green: 0.15, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Wall cracks (appear as damage increases)
            if roomDamage > 0.3 {
                ForEach(0..<Int(roomDamage * 5), id: \.self) { i in
                    CrackShape()
                        .stroke(Color.black.opacity(0.4), lineWidth: 2)
                        .frame(width: 80, height: 60)
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -300...200)
                        )
                        .rotationEffect(.degrees(Double.random(in: -30...30)))
                }
            }
        }
    }

    // MARK: - Destructible Items
    private var destructibleItems: some View {
        ZStack {
            // Window
            if !destroyedItems.contains("window") {
                destructibleItem(
                    name: "window",
                    icon: "window.ceiling",
                    position: CGPoint(x: 0, y: -200),
                    size: 80,
                    color: Color(red: 0.6, green: 0.8, blue: 0.95)
                )
            } else {
                brokenItem(icon: "xmark", position: CGPoint(x: 0, y: -200))
            }

            // Plates (shelf)
            if !destroyedItems.contains("plates") {
                destructibleItem(
                    name: "plates",
                    icon: "circle.circle",
                    position: CGPoint(x: -100, y: -80),
                    size: 50,
                    color: .white
                )
            } else {
                scatteredDebris(position: CGPoint(x: -100, y: -80))
            }

            // Furniture (chair)
            if !destroyedItems.contains("furniture") {
                destructibleItem(
                    name: "furniture",
                    icon: "chair.fill",
                    position: CGPoint(x: 100, y: 0),
                    size: 70,
                    color: Color(red: 0.5, green: 0.3, blue: 0.15)
                )
            } else {
                brokenItem(icon: "square.split.diagonal", position: CGPoint(x: 100, y: 0))
            }

            // Punch dummy
            if !destroyedItems.contains("dummy") {
                destructibleItem(
                    name: "dummy",
                    icon: "figure.stand",
                    position: CGPoint(x: -50, y: 80),
                    size: 70,
                    color: Color(red: 0.8, green: 0.3, blue: 0.3)
                )
            } else {
                brokenItem(icon: "figure.fall", position: CGPoint(x: -50, y: 80))
            }

            // Wall section (for sledgehammer)
            if !destroyedItems.contains("wall") {
                destructibleItem(
                    name: "wall",
                    icon: "square.grid.3x3.fill",
                    position: CGPoint(x: 80, y: -120),
                    size: 60,
                    color: Color(red: 0.6, green: 0.5, blue: 0.45)
                )
            } else {
                brokenItem(icon: "square.grid.3x3.topleft.filled", position: CGPoint(x: 80, y: -120))
            }
        }
    }


    private func destructibleItem(name: String, icon: String, position: CGPoint, size: CGFloat, color: Color) -> some View {
        Button(action: { destroyItem(name) }) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: size + 20, height: size + 20)

                Image(systemName: icon)
                    .font(.system(size: size * 0.5))
                    .foregroundColor(color)
            }
        }
        .offset(x: position.x, y: position.y)
    }

    private func brokenItem(icon: String, position: CGPoint) -> some View {
        Image(systemName: icon)
            .font(.system(size: 30))
            .foregroundColor(.red.opacity(0.5))
            .offset(x: position.x, y: position.y)
    }

    private func scatteredDebris(position: CGPoint) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<4, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .offset(x: position.x, y: position.y + 20)
    }

    // MARK: - Spray Paint Overlay
    private var sprayPaintOverlay: some View {
        Canvas { context, size in
            for point in sprayPoints {
                let rect = CGRect(x: point.position.x - 10, y: point.position.y - 10, width: 20, height: 20)
                context.fill(Circle().path(in: rect), with: .color(point.color.opacity(0.7)))
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Damage Header
    private var damageHeader: some View {
        HStack {
            Text("Destruction: \(Int(roomDamage * 100))%")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.red.opacity(0.8))

            Spacer()

            Text(selectedTool.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(selectedTool.color.opacity(0.3)))
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    // MARK: - Tool Picker
    private var toolPicker: some View {
        HStack(spacing: 16) {
            ForEach(DestructionTool.allCases, id: \.self) { tool in
                Button(action: { selectedTool = tool }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(selectedTool == tool ? tool.color.opacity(0.3) : Color.white.opacity(0.08))
                                .frame(width: 52, height: 52)

                            Image(systemName: tool.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedTool == tool ? tool.color : .white.opacity(0.5))
                        }
                        Text(tool.rawValue)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
        )
        .padding(.bottom, 16)
    }


    // MARK: - Release Button
    private var releaseButton: some View {
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
                    .shadow(color: Color.green.opacity(0.3), radius: 10, y: 4)
            )
        }
        .padding(.bottom, 30)
    }

    // MARK: - Interaction
    private func handleInteraction(at point: CGPoint) {
        switch selectedTool {
        case .spray:
            let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
            let sprayPoint = SprayPoint(position: point, color: colors.randomElement()!)
            sprayPoints.append(sprayPoint)
            roomDamage = min(1.0, roomDamage + 0.002)

        case .fists, .sledgehammer, .plates:
            // Shake effect
            withAnimation(.default) {
                shakeAmount = CGFloat.random(in: -5...5)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { shakeAmount = 0 }
            }

        }
    }

    private func destroyItem(_ name: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            destroyedItems.insert(name)
            roomDamage = min(1.0, roomDamage + 0.2)
        }

        // Screen shake
        withAnimation(.default) {
            shakeAmount = CGFloat.random(in: -8...8)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring()) { shakeAmount = 0 }
        }
    }
}

// MARK: - Crack Shape
struct CrackShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY

        path.move(to: CGPoint(x: midX - 20, y: midY))
        path.addLine(to: CGPoint(x: midX - 5, y: midY - 10))
        path.addLine(to: CGPoint(x: midX + 5, y: midY + 5))
        path.addLine(to: CGPoint(x: midX + 20, y: midY - 5))

        path.move(to: CGPoint(x: midX - 5, y: midY - 10))
        path.addLine(to: CGPoint(x: midX - 15, y: midY - 20))

        path.move(to: CGPoint(x: midX + 5, y: midY + 5))
        path.addLine(to: CGPoint(x: midX + 10, y: midY + 20))

        return path
    }
}
