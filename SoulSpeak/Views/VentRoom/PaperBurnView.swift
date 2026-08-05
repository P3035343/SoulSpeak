import SwiftUI

/// Recording transforms into paper → user places it in the fireplace → it burns away.
struct PaperBurnView: View {
    let onFinished: () -> Void

    @State private var paperOffset: CGFloat = 0
    @State private var paperRotation: Double = 0
    @State private var paperScale: CGFloat = 1.0
    @State private var paperOpacity: Double = 1.0
    @State private var showFireplace = false
    @State private var burning = false
    @State private var showInstruction = true
    @State private var paperPlaced = false

    var body: some View {
        ZStack {
            // Dark room
            Color(red: 0.06, green: 0.04, blue: 0.04)
                .ignoresSafeArea()

            // Fireplace at bottom
            VStack {
                Spacer()
                fireplaceView
            }
            .ignoresSafeArea()

            // The paper (draggable)
            if !paperPlaced {
                paperView
                    .offset(y: paperOffset)
                    .rotationEffect(.degrees(paperRotation))
                    .scaleEffect(paperScale)
                    .opacity(paperOpacity)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                paperOffset = value.translation.height
                                paperRotation = Double(value.translation.width) * 0.1
                            }
                            .onEnded { value in
                                // If dragged down far enough, place in fireplace
                                if value.translation.height > 200 {
                                    placePaperInFire()
                                } else {
                                    withAnimation(.spring()) {
                                        paperOffset = 0
                                        paperRotation = 0
                                    }
                                }
                            }
                    )
            }

            // Instruction
            if showInstruction {
                VStack {
                    Spacer()
                        .frame(height: 100)

                    Text("Drag the paper into the fireplace")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.5))
                        )

                    Image(systemName: "arrow.down")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 8)

                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                showFireplace = true
            }
        }
    }

    // MARK: - Paper View
    private var paperView: some View {
        VStack(spacing: 8) {
            // Paper with "handwriting" lines
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.95, green: 0.92, blue: 0.85))
                    .frame(width: 200, height: 260)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

                // Handwriting lines
                VStack(spacing: 12) {
                    ForEach(0..<10, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(red: 0.3, green: 0.3, blue: 0.4).opacity(0.4))
                            .frame(width: CGFloat.random(in: 80...160), height: 2)
                            .offset(x: CGFloat.random(in: -20...20))
                    }
                }

                // "Your words" label
                VStack {
                    HStack {
                        Text("Your words")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(12)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Fireplace
    private var fireplaceView: some View {
        ZStack {
            // Brick fireplace frame
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.08, green: 0.04, blue: 0.02))
                .frame(width: 280, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.4, green: 0.22, blue: 0.12), lineWidth: 12)
                )
                .shadow(color: burning ? Color.orange.opacity(0.6) : Color.clear, radius: 40)

            if burning {
                // Deep ember base
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.red.opacity(0.9), Color.orange.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 90
                        )
                    )
                    .frame(width: 200, height: 60)
                    .offset(y: 60)

                // Main fire body - layered for depth
                ZStack {
                    // Outer flame (red/dark)
                    fireFlame(width: 140, height: 130, colors: [Color.red, Color(red: 0.8, green: 0.2, blue: 0)], blur: 12, yOffset: 0, animDelay: 0)

                    // Middle flame (orange)
                    fireFlame(width: 100, height: 110, colors: [Color.orange, Color(red: 1, green: 0.5, blue: 0)], blur: 8, yOffset: 5, animDelay: 0.1)

                    // Inner flame (yellow)
                    fireFlame(width: 60, height: 80, colors: [Color.yellow, Color.orange], blur: 6, yOffset: 15, animDelay: 0.2)

                    // White-hot core
                    Ellipse()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 30, height: 20)
                        .blur(radius: 8)
                        .offset(y: 45)

                    // Flickering flame tips
                    ForEach(0..<7, id: \.self) { i in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.9), Color.orange.opacity(0.6), Color.red.opacity(0)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: CGFloat(4 + i % 3 * 2), height: CGFloat(20 + i * 8))
                            .blur(radius: 2)
                            .offset(x: CGFloat(i * 18 - 54), y: CGFloat(-30 - i * 5))
                            .scaleEffect(y: burning ? CGFloat.random(in: 0.8...1.3) : 0.5)
                            .animation(
                                .easeInOut(duration: 0.2 + Double(i) * 0.08)
                                    .repeatForever(autoreverses: true),
                                value: burning
                            )
                    }
                }

                // Rising sparks/embers
                ForEach(0..<10, id: \.self) { i in
                    Circle()
                        .fill(Color.yellow.opacity(Double.random(in: 0.5...1.0)))
                        .frame(width: CGFloat.random(in: 2...4))
                        .offset(
                            x: CGFloat.random(in: -60...60),
                            y: burning ? CGFloat(-80 - i * 12) : 30
                        )
                        .opacity(burning ? 0 : 1)
                        .animation(
                            .easeOut(duration: Double.random(in: 1.0...2.5))
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.25),
                            value: burning
                        )
                }

                // Smoke wisps
                ForEach(0..<3, id: \.self) { i in
                    Ellipse()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 30, height: 40)
                        .blur(radius: 10)
                        .offset(
                            x: CGFloat(i * 20 - 20),
                            y: burning ? CGFloat(-100 - i * 20) : -20
                        )
                        .opacity(burning ? 0 : 0.4)
                        .animation(
                            .easeOut(duration: 3.0)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.5),
                            value: burning
                        )
                }
            } else {
                // Cold — faint ember glow
                Ellipse()
                    .fill(Color.red.opacity(showFireplace ? 0.15 : 0))
                    .frame(width: 100, height: 40)
                    .blur(radius: 10)
                    .offset(y: 60)
            }
        }
        .frame(height: 240)
    }

    // Helper for layered flame shapes
    private func fireFlame(width: CGFloat, height: CGFloat, colors: [Color], blur: CGFloat, yOffset: CGFloat, animDelay: Double) -> some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: colors + [colors.last!.opacity(0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: width, height: height)
            .blur(radius: blur)
            .offset(y: yOffset)
            .scaleEffect(x: burning ? CGFloat.random(in: 0.95...1.05) : 0.9, y: burning ? 1.08 : 0.92)
            .animation(
                .easeInOut(duration: 0.35 + animDelay)
                    .repeatForever(autoreverses: true),
                value: burning
            )
    }

    // MARK: - Actions
    private func placePaperInFire() {
        paperPlaced = true
        showInstruction = false

        // Animate paper dropping into fire
        withAnimation(.easeIn(duration: 0.5)) {
            paperOffset = 300
            paperScale = 0.5
            paperOpacity = 0
        }

        // Start fire
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            burning = true
        }

        // Finish after burning
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onFinished()
        }
    }
}
