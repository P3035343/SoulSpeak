import SwiftUI

struct BreathworkView: View {
    @State private var selectedTechnique: BreathworkTechnique?
    @State private var isSessionActive = false
    @State private var currentPhase: BreathPhase = .inhale
    @State private var cyclesCompleted = 0
    @State private var timer: Timer?
    @State private var progress: Double = 0
    
    private let service = MockBreathworkService()
    
    enum BreathPhase: String {
        case inhale = "Breathe In"
        case hold = "Hold"
        case exhale = "Breathe Out"
        case holdAfterExhale = "Rest"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SSColors.background.ignoresSafeArea()
                
                if isSessionActive, let technique = selectedTechnique {
                    activeSessionView(technique: technique)
                } else {
                    techniqueSelectionView
                }
            }
            .navigationTitle("Breathwork")
        }
    }
    
    private var techniqueSelectionView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Choose a technique")
                    .font(SSTypography.title3)
                    .foregroundColor(SSColors.textPrimary)
                
                ForEach(service.getBreathworkTechniques(), id: \.id) { technique in
                    SSCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(technique.name)
                                .font(SSTypography.headline)
                            Text(technique.description)
                                .font(SSTypography.body)
                                .foregroundColor(SSColors.textSecondary)
                            HStack {
                                Label("\(Int(technique.inhaleSeconds))s in", systemImage: "arrow.down")
                                if technique.holdSeconds > 0 {
                                    Label("\(Int(technique.holdSeconds))s hold", systemImage: "pause")
                                }
                                Label("\(Int(technique.exhaleSeconds))s out", systemImage: "arrow.up")
                            }
                            .font(SSTypography.caption)
                            .foregroundColor(SSColors.textSecondary)
                            
                            SSButton(title: "Start", style: .primary) {
                                selectedTechnique = technique
                                isSessionActive = true
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func activeSessionView(technique: BreathworkTechnique) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(SSColors.primary.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(SSColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)
                
                VStack(spacing: 8) {
                    Text(currentPhase.rawValue)
                        .font(SSTypography.title2)
                        .foregroundColor(SSColors.textPrimary)
                    Text("Cycle \(cyclesCompleted + 1)/\(technique.recommendedCycles)")
                        .font(SSTypography.caption)
                        .foregroundColor(SSColors.textSecondary)
                }
            }
            
            Spacer()
            
            SSButton(title: "End Session", style: .outline) {
                endSession()
            }
            .padding(.horizontal, 48)
        }
        .padding()
    }
    
    private func endSession() {
        timer?.invalidate()
        timer = nil
        isSessionActive = false
        cyclesCompleted = 0
        progress = 0
    }
}
