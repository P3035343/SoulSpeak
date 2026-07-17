import SwiftUI

/// First-person conversation scene with a Hope character.
/// Simulates a real therapy/coaching session with animated dialogue.
struct ConversationView: View {
    let character: HopeCharacter
    let onExit: () -> Void
    
    @State private var messages: [ChatMessage] = []
    @State private var showPrompts = true
    @State private var isTyping = false
    @State private var avatarMood: AvatarMood = .neutral
    @State private var backgroundBreathing = false
    
    enum AvatarMood {
        case neutral, listening, speaking, encouraging
        
        var icon: String {
            switch self {
            case .neutral: return "face.smiling"
            case .listening: return "ear"
            case .speaking: return "mouth"
            case .encouraging: return "hands.clap"
            }
        }
    }
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isFromCharacter: Bool
        let timestamp: Date
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with avatar
            conversationHeader
            
            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                character: character
                            )
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }
                        
                        if isTyping {
                            TypingIndicator(color: character.avatarColor)
                                .id("typing")
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id ?? "typing", anchor: .bottom)
                    }
                }
            }
            
            // Prompt buttons or typing area
            if showPrompts {
                promptSelector
            }
        }
        .background(
            // Subtle animated background
            LinearGradient(
                colors: [
                    character.avatarColor.opacity(backgroundBreathing ? 0.05 : 0.02),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            // Character greeting with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                addCharacterMessage(character.greeting)
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                backgroundBreathing = true
            }
        }
    }
    
    // MARK: - Header
    private var conversationHeader: some View {
        HStack(spacing: 12) {
            // Mini avatar
            ZStack {
                Circle()
                    .fill(character.backgroundGradient)
                    .frame(width: 44, height: 44)
                Image(systemName: character.avatarIcon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(character.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 6, height: 6)
                    Text(isTyping ? "Typing..." : "Active now")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onExit) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Prompt Selector
    private var promptSelector: some View {
        VStack(spacing: 8) {
            Divider()
            
            Text("What would you like to talk about?")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(character.conversationPrompts, id: \.self) { prompt in
                        Button(action: { selectPrompt(prompt) }) {
                            Text(prompt)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(character.avatarColor)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(
                                    Capsule()
                                        .fill(character.avatarColor.opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(character.avatarColor.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Actions
    private func selectPrompt(_ prompt: String) {
        // Add user message
        let userMessage = ChatMessage(text: prompt, isFromCharacter: false, timestamp: Date())
        withAnimation(.spring(response: 0.3)) {
            messages.append(userMessage)
            showPrompts = false
        }
        
        // Show typing indicator
        withAnimation(.easeIn(duration: 0.3)) {
            isTyping = true
            avatarMood = .listening
        }
        
        // Character responds after delay (simulating thinking)
        let responseDelay = Double.random(in: 1.5...3.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
            let response = character.respond(to: prompt)
            addCharacterMessage(response)
            
            // Show prompts again after response
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showPrompts = true
                }
            }
        }
    }
    
    private func addCharacterMessage(_ text: String) {
        withAnimation(.easeIn(duration: 0.2)) {
            isTyping = false
            avatarMood = .speaking
        }
        
        let message = ChatMessage(text: text, isFromCharacter: true, timestamp: Date())
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            messages.append(message)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            avatarMood = .neutral
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ConversationView.ChatMessage
    let character: HopeCharacter
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromCharacter {
                // Character avatar mini
                if let imageName = character.avatarImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(character.backgroundGradient)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: character.avatarIcon)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        )
                }
            } else {
                Spacer(minLength: 60)
            }
            
            Text(message.text)
                .font(.system(size: 15, design: .rounded))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    message.isFromCharacter
                        ? AnyShapeStyle(Color(red: 0.95, green: 0.95, blue: 0.97))
                        : AnyShapeStyle(character.avatarColor.opacity(0.15))
                )
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            
            if !message.isFromCharacter {
                // User avatar
                Circle()
                    .fill(Color(red: 0.9, green: 0.9, blue: 0.92))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    )
            } else {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    let color: Color
    @State private var dotScale: [CGFloat] = [0.5, 0.5, 0.5]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 28, height: 28)
            
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(color.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .scaleEffect(dotScale[index])
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            Spacer()
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(Double(i) * 0.2)) {
                    dotScale[i] = 1.0
                }
            }
        }
    }
}
