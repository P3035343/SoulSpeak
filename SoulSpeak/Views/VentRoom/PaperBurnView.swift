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
    @State private var fireIntensity: CGFloat = 0
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
            // Fireplace opening
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.15, green: 0.08, blue: 0.05))
                .frame(width: 280, height: 180)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.4, green: 0.25, blue: 0.15), lineWidth: 6)
                )

            // Fire
            if burning {
                VStack(spacing: 0) {
                    // Flames
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { i in
                            fireFlame(delay: Double(i) * 0.1, height: 30 + CGFloat(i % 3) * 15)
                        }
                    }
                    .offset(y: 20)
                }
            }

            // Embers (always show subtle glow)
            Circle()
                .fill(Color(red: 0.9, green: 0.3, blue: 0.1).opacity(showFireplace ? 0.2 : 0))
                .frame(width: 100, height: 50)
                .offset(y: 40)
        }
        .frame(height: 200)
    }

    private func fireFlame(delay: Double, height: CGFloat) -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.8, blue: 0.1),
                        Color(red: 1.0, green: 0.4, blue: 0.1),
                        Color(red: 0.8, green: 0.2, blue: 0.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 14, height: height * fireIntensity)
            .offset(y: -fireIntensity * 10)
            .animation(
                .easeInOut(duration: 0.4 + delay)
                    .repeatForever(autoreverses: true),
                value: fireIntensity
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
            withAnimation(.easeInOut(duration: 1.0)) {
                fireIntensity = 1.0
            }
        }

        // Finish after burning
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onFinished()
        }
    }
}
