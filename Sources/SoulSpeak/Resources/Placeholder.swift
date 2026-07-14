import Foundation

// This file ensures the Resources directory is included in the Swift package.
// Add asset catalogs, localization files, and other resources to this directory.

enum SoulSpeakResources {
    static let bundleIdentifier = "com.soulspeak.app"
    
    static let defaultAffirmations: [String] = [
        "I am worthy of love and belonging.",
        "I choose peace over worry.",
        "I am growing stronger every day.",
        "My feelings are valid and important.",
        "I deserve rest and self-care.",
        "I am enough, just as I am.",
        "I release what no longer serves me.",
        "I am capable of creating positive change.",
        "I honor my journey and trust the process.",
        "I am surrounded by love and support.",
        "I choose to focus on what I can control.",
        "I am resilient and can handle challenges.",
        "I give myself permission to feel joy.",
        "I am creating the life I desire.",
        "I trust my intuition to guide me.",
    ]
    
    static let moodEmojis: [String: String] = [
        "happy": "😊",
        "calm": "😌",
        "neutral": "😐",
        "sad": "😢",
        "anxious": "😰",
        "angry": "😡",
        "grateful": "🙏",
        "energetic": "⚡",
        "stressed": "😫",
        "hopeful": "🌟",
    ]
    
    static let journalPrompts: [String] = [
        "What made you smile today?",
        "What are you most grateful for right now?",
        "Describe a challenge you overcame recently.",
        "What would your ideal day look like?",
        "Write a letter to your future self.",
        "What boundary do you need to set?",
        "What does self-love mean to you today?",
        "Describe a moment of peace you experienced.",
        "What are you ready to release?",
        "What gives you hope for tomorrow?",
    ]
}
