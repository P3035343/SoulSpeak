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
                .frame(width: 260, height: 170)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.3, green: 0.18, blue: 0.1), lineWidth: 10)
                )
                .shadow(color: burning ? Color.orange.opacity(0.5) : Color.clear, radius: 30)

            if burning {
                // Glowing base
                Ellipse()
                    .fill(Color.orange.opacity(0.6))
                    .frame(width: 160, height: 40)
                    .blur(radius: 12)
                    .offset(y: 50)

                // Main fire body
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange, Color.red, Color(red: 0.4, green: 0, blue: 0)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 120, height: 110)
                    .blur(radius: 8)
                    .offset(y: -5)
                    .scaleEffect(x: burning ? 1.05 : 0.95, y: burning ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: burning)

                // Bright core
                Ellipse()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 50, height: 30)
                    .blur(radius: 10)
                    .offset(y: 30)

                // Flickering tips
                ForEach(0..<5, id: \.self) { i in
                    Capsule()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: CGFloat(6 + i * 2), height: CGFloat(30 + i * 10))
                        .blur(radius: 3)
                        .offset(x: CGFloat(i * 15 - 30), y: CGFloat(-20 - i * 8))
                        .scaleEffect(y: burning ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.3 + Double(i) * 0.1)
                                .repeatForever(autoreverses: true),
                            value: burning
                        )
                }

                // Sparks
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(Color.yellow.opacity(0.9))
                        .frame(width: 3)
                        .offset(
                            x: CGFloat.random(in: -50...50),
                            y: burning ? CGFloat(-60 - i * 10) : 20
                        )
                        .opacity(burning ? 0 : 0.8)
                        .animation(
                            .easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.3),
                            value: burning
                        )
                }
            } else {
                // Cold — faint glow
                Ellipse()
                    .fill(Color.red.opacity(showFireplace ? 0.1 : 0))
                    .frame(width: 80, height: 30)
                    .blur(radius: 8)
                    .offset(y: 50)
            }
        }
        .frame(height: 200)
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
