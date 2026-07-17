import SwiftUI

/// The two Hope characters available in the Office Lobby.
enum HopeCharacter: String, CaseIterable, Identifiable {
    case mrHope = "Mr. Hope"
    case drHope = "Dr. Hope"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .mrHope: return "Wellness Companion"
        case .drHope: return "Therapeutic Guide"
        }
    }
    
    var description: String {
        switch self {
        case .mrHope:
            return "A warm, encouraging companion for casual reflection and positive thinking. Think of him as a supportive friend."
        case .drHope:
            return "A structured, thoughtful guide for deeper self-exploration. She helps you uncover patterns and find meaning."
        }
    }
    
    var greeting: String {
        switch self {
        case .mrHope:
            return "Hey there! Good to see you. Pull up a chair — no pressure, no agenda. What's been on your mind lately?"
        case .drHope:
            return "Welcome. I'm glad you're here. Let's take this at your pace. What would you like to explore together today?"
        }
    }
    
    var avatarColor: Color {
        switch self {
        case .mrHope: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .drHope: return Color(red: 0.7, green: 0.4, blue: 0.8)
        }
    }
    
    var avatarIcon: String {
        switch self {
        case .mrHope: return "figure.wave"
        case .drHope: return "figure.mind.and.body"
        }
    }
    
    /// Custom image name in asset catalog (nil = use SF Symbol fallback)
    var avatarImageName: String? {
        switch self {
        case .mrHope: return "mr_hope"
        case .drHope: return nil // Add "dr_hope" when you have the image
        }
    }
    
    var backgroundGradient: LinearGradient {
        switch self {
        case .mrHope:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.5, blue: 0.85), Color(red: 0.4, green: 0.7, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .drHope:
            return LinearGradient(
                colors: [Color(red: 0.55, green: 0.3, blue: 0.75), Color(red: 0.75, green: 0.5, blue: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var conversationPrompts: [String] {
        switch self {
        case .mrHope:
            return [
                "What made you smile today?",
                "Tell me something you're proud of",
                "What's one good thing happening right now?",
                "Let's celebrate a small win",
                "What are you looking forward to?",
                "I just want to vent a little"
            ]
        case .drHope:
            return [
                "I want to explore a feeling",
                "Help me understand a pattern",
                "I'm struggling with something",
                "Let's reflect on my week",
                "I need help processing something",
                "Guide me through a thought exercise"
            ]
        }
    }
    
    /// Responses based on user's chosen prompt
    func respond(to prompt: String) -> String {
        switch self {
        case .mrHope:
            return mrHopeResponse(for: prompt)
        case .drHope:
            return drHopeResponse(for: prompt)
        }
    }
    
    private func mrHopeResponse(for prompt: String) -> String {
        if prompt.contains("smile") {
            return "That's wonderful! Even small moments of joy matter. Your brain actually physically changes when you notice good things — you're literally rewiring yourself for happiness right now. Tell me more about that moment."
        } else if prompt.contains("proud") {
            return "Yes! I love that you're acknowledging your own wins. So many people skip right past them. Whatever it is, big or small, it counts. You showed up and that matters."
        } else if prompt.contains("good thing") {
            return "I'm glad you can see that. Sometimes when everything feels heavy, finding even one good thing is an act of courage. Hold onto that feeling."
        } else if prompt.contains("celebrate") {
            return "Let's do it! No win is too small. Did you drink water today? That counts. Did you get out of bed? That counts too. What's your win?"
        } else if prompt.contains("looking forward") {
            return "Having something to look forward to is so powerful. It doesn't have to be big — even a cup of coffee tomorrow morning counts. What's yours?"
        } else {
            return "I hear you. Sometimes we just need someone to listen without trying to fix things. I'm here. Take your time. There's no rush and no judgment."
        }
    }
    
    private func drHopeResponse(for prompt: String) -> String {
        if prompt.contains("feeling") {
            return "Let's sit with that feeling for a moment. Can you name it? Sometimes putting a word to what we feel gives us a little more control over it. There's no wrong answer here."
        } else if prompt.contains("pattern") {
            return "Noticing patterns is such important work. It means you're paying attention to yourself. What have you observed? When does this tend to happen?"
        } else if prompt.contains("struggling") {
            return "Thank you for being honest about that. Struggling doesn't mean failing — it means you're in the middle of something that matters to you. What does this struggle look like?"
        } else if prompt.contains("week") {
            return "Let's review together. Think about the last seven days — what emotions came up most? Were there any moments that surprised you, good or difficult?"
        } else if prompt.contains("processing") {
            return "Processing takes time, and it's not linear. Let's start where you are right now. What's the thought or event that keeps coming back to you?"
        } else {
            return "I'd like to try something. Close your eyes for a moment. Take one deep breath. Now, without overthinking it — what's the first word that comes to mind about how you feel right now?"
        }
    }
}
