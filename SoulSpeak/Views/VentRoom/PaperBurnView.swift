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
            // Fireplace brick frame
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.12, green: 0.06, blue: 0.03))
                .frame(width: 280, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.35, green: 0.2, blue: 0.1), lineWidth: 8)
                )
                .shadow(color: burning ? Color(red: 0.9, green: 0.4, blue: 0.1).opacity(0.4) : Color.clear, radius: 20)

            // Fire when burning
            if burning {
                // Realistic multi-layer fire
                ZStack {
                    // Base red glow
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.9, green: 0.2, blue: 0.0).opacity(0.8),
                                    Color(red: 0.6, green: 0.1, blue: 0.0).opacity(0.4),
                                    Color.clear
                                ],
                                center: .bottom,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 180, height: 100)
                        .offset(y: 30)

                    // Flame layer 1 - main flames
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { i in
                            realisticFlame(
                                width: CGFloat.random(in: 12...22),
                                maxHeight: CGFloat.random(in: 50...90),
                                delay: Double(i) * 0.08,
                                color1: Color(red: 1.0, green: 0.9, blue: 0.3),
                                color2: Color(red: 1.0, green: 0.5, blue: 0.0),
                                color3: Color(red: 0.8, green: 0.15, blue: 0.0)
                            )
                        }
                    }
                    .offset(y: -10)

                    // Flame layer 2 - inner bright flames
                    HStack(spacing: 10) {
                        ForEach(0..<4, id: \.self) { i in
                            realisticFlame(
                                width: CGFloat.random(in: 8...14),
                                maxHeight: CGFloat.random(in: 60...100),
                                delay: Double(i) * 0.12 + 0.05,
                                color1: Color(red: 1.0, green: 1.0, blue: 0.8),
                                color2: Color(red: 1.0, green: 0.8, blue: 0.2),
                                color3: Color(red: 1.0, green: 0.4, blue: 0.0)
                            )
                        }
                    }
                    .offset(y: -20)

                    // Embers/sparks floating up
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(Color(red: 1.0, green: CGFloat.random(in: 0.4...0.8), blue: 0.0))
                            .frame(width: CGFloat.random(in: 2...5))
                            .offset(
                                x: CGFloat.random(in: -60...60),
                                y: emberOffset(index: i)
                            )
                            .opacity(emberOpacity(index: i))
                    }

                    // Smoke wisps at top
                    ForEach(0..<3, id: \.self) { i in
                        Ellipse()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: CGFloat.random(in: 20...40), height: CGFloat.random(in: 10...20))
                            .offset(x: CGFloat.random(in: -30...30), y: -70 - CGFloat(i) * 15)
                            .blur(radius: 4)
                    }
                }
                .frame(width: 240, height: 160)
            } else {
                // Cold fireplace - embers
                Circle()
                    .fill(Color(red: 0.9, green: 0.3, blue: 0.1).opacity(showFireplace ? 0.15 : 0))
                    .frame(width: 80, height: 40)
                    .offset(y: 50)
                    .blur(radius: 5)
            }
        }
        .frame(height: 220)
    }

    // MARK: - Realistic Flame Shape
    private func realisticFlame(width: CGFloat, maxHeight: CGFloat, delay: Double, color1: Color, color2: Color, color3: Color) -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [color1, color2, color3, Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: width, height: burning ? maxHeight : 5)
            .animation(
                .easeInOut(duration: 0.3 + delay)
                    .repeatForever(autoreverses: true),
                value: burning
            )
            .blur(radius: 1.5)
            .rotationEffect(.degrees(Double.random(in: -8...8)))
    }

    private func emberOffset(index: Int) -> CGFloat {
        burning ? CGFloat(-40 - index * 12) : 40
    }

    private func emberOpacity(index: Int) -> Double {
        burning ? Double.random(in: 0.3...0.8) : 0
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
