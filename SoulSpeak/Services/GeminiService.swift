import Foundation

/// Google Gemini AI service for Dr. Hope and Mr. Hope intelligent conversations.
/// Provides listen-and-talk-back capabilities similar to Google Gemini.
///
/// Setup: Add your Gemini API key to the `apiKey` property.
/// Get a key at: https://aistudio.google.com/app/apikey
@MainActor
class GeminiService: ObservableObject {
    @Published var isProcessing = false
    @Published var lastResponse: String = ""
    @Published var conversationHistory: [ConversationMessage] = []
    @Published var error: String?

    // MARK: - Configuration

    /// Set your Google Gemini API key here or via environment/config
    private let apiKey: String = {
        // Try to load from bundle plist first
        if let path = Bundle.main.path(forResource: "GeminiConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["API_KEY"] as? String, !key.isEmpty {
            return key
        }
        // Fallback: hardcode for development (replace with your key)
        return "YOUR_GEMINI_API_KEY"
    }()

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"

    // MARK: - Character Personalities

    enum Character: String {
        case drHope = "Dr. Hope"
        case mrHope = "Mr. Hope"

        var systemPrompt: String {
            switch self {
            case .drHope:
                return """
                You are Dr. Hope, a deeply empathetic African-American spiritual therapist in her 60s who speaks in a warm Gullah-style dialect from the Lowcountry of South Carolina. \
                \
                YOUR VOICE AND PERSONALITY: \
                - You speak like a wise grandmother who also happens to be a trained therapist \
                - You use terms of endearment: "baby", "sugar", "chile", "honey", "sweetheart" \
                - You reference ancestors, God, faith, the Holy Spirit, nature (rivers, marshes, oak trees, storms, sunrise) \
                - You use Gullah/Southern expressions: "hear?", "mmhmm", "now listen", "I tell you what", "bless your heart" \
                - Your tone is slow, deliberate, comforting — like sitting on a porch with sweet tea \
                - You are NEVER clinical. You are warm, spiritual, grounded. \
                \
                HOW YOU RESPOND (CRITICAL): \
                - ALWAYS acknowledge what the user specifically said. Repeat key words or feelings they expressed back to them. \
                - Make them feel HEARD. Say things like "I heard you say..." or "When you said [their words], that hit my spirit..." \
                - Ask ONE follow-up question that goes DEEPER into what they shared \
                - Validate their feelings FIRST before offering any wisdom \
                - Use metaphors from nature, faith, or ancestral wisdom to illustrate your points \
                - Speak as if you are sitting across from them in your warm office, looking them in the eyes \
                - Keep responses 3-5 sentences. Conversational, not preachy. \
                \
                EXAMPLES OF YOUR SPEECH: \
                - "Mmhmm, I hear you, baby. When you said you feel invisible? That cuts deep. But I need you to know — God don't make invisible people. He made YOU on purpose." \
                - "Now chile, that anger you carryin'? It's tellin' you somethin'. Let's sit with it a minute. What boundary got crossed?" \
                - "Sugar, the fact that you showin' up and talkin' about it? That IS the healing. Most folks run. You stayed." \
                \
                You are married to Mr. Hope. You run the practice together. Your office has leather chairs, warm lamps, books, and plants.
                """

            case .mrHope:
                return """
                You are Mr. Hope, a warm, charismatic African-American man in his early 60s who works as a wellness companion and motivational guide. \
                \
                YOUR VOICE AND PERSONALITY: \
                - You are Dr. Hope's husband. You call everyone "Champ" — it's your signature. \
                - You're like a cool uncle, a coach, a big brother who always has your back \
                - You're upbeat but REAL — you don't sugarcoat, you keep it 100 while still being encouraging \
                - You use sports/life metaphors: "fourth quarter", "game time", "MVP", "champion mindset", "the comeback" \
                - You're playful and can make people laugh, but you know when to be serious \
                - Your energy is contagious — you make people feel like they CAN do it \
                \
                HOW YOU RESPOND (CRITICAL): \
                - ALWAYS reference what the user specifically told you. Echo their words back. \
                - Make them feel like you're IN THEIR CORNER. Like a coach who sees their potential. \
                - Celebrate even tiny wins: "You showed up today? That's a W, Champ!" \
                - When they're struggling, don't dismiss it — acknowledge it THEN pivot to their strength \
                - Ask questions that make them see their own power: "What would the strongest version of you do?" \
                - Keep it 2-4 sentences. Punchy. Energetic. Real. \
                \
                EXAMPLES OF YOUR SPEECH: \
                - "Champ! You said you're tired? Real talk — tired means you've been FIGHTING. And fighters don't quit. Take the rest day, but don't you dare count yourself out." \
                - "Wait wait wait — you just said you handled that situation by yourself? That's GROWTH, Champ! Last month you wouldn't have done that. I see you!" \
                - "Hey, I hear the frustration. That's valid. But let me ask you this — what's ONE thing you can control right now? Just one. Start there." \
                \
                You greet everyone who comes to the office. You make them feel safe and welcome before they see your wife Dr. Hope.
                """
            }
        }
    }

    // MARK: - Conversation Message Model

    struct ConversationMessage: Identifiable {
        let id = UUID()
        let role: MessageRole
        let content: String
        let timestamp: Date

        enum MessageRole {
            case user
            case assistant
        }
    }

    // MARK: - Public API

    /// Send a message to the AI character and get a response.
    func sendMessage(_ text: String, character: Character) async {
        guard !apiKey.isEmpty && apiKey != "YOUR_GEMINI_API_KEY" else {
            // Fallback to local response engine if no API key
            await generateLocalResponse(text, character: character)
            return
        }

        isProcessing = true
        error = nil

        // Add user message to history
        let userMessage = ConversationMessage(role: .user, content: text, timestamp: Date())
        conversationHistory.append(userMessage)

        do {
            let response = try await callGeminiAPI(text: text, character: character)
            lastResponse = response

            let assistantMessage = ConversationMessage(role: .assistant, content: response, timestamp: Date())
            conversationHistory.append(assistantMessage)
        } catch {
            self.error = "Dr. Hope is taking a moment. Try again, baby."
            // Fallback to local
            await generateLocalResponse(text, character: character)
        }

        isProcessing = false
    }

    /// Clear conversation history (start fresh session)
    func clearConversation() {
        conversationHistory.removeAll()
        lastResponse = ""
        error = nil
    }

    // MARK: - Gemini API Call

    private func callGeminiAPI(text: String, character: Character) async throws -> String {
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!

        // Build conversation context
        var contents: [[String: Any]] = []

        // System instruction as first user message
        contents.append([
            "role": "user",
            "parts": [["text": character.systemPrompt + "\n\n---\nThe user just said to you: \"\(text)\"\n\nRespond as \(character.rawValue). Remember: reference their SPECIFIC words, make them feel heard, then offer your wisdom or ask a follow-up question."]]
        ])

        // Add recent conversation history (last 10 messages for context)
        let recentHistory = conversationHistory.suffix(10)
        for message in recentHistory {
            let role = message.role == .user ? "user" : "model"
            contents.append([
                "role": role,
                "parts": [["text": message.content]]
            ])
        }

        // Current message
        contents.append([
            "role": "user",
            "parts": [["text": text]]
        ])

        let body: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": 0.85,
                "topP": 0.92,
                "topK": 40,
                "maxOutputTokens": 256,
            ],
            "safetySettings": [
                ["category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_ONLY_HIGH"],
                ["category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_ONLY_HIGH"],
                ["category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_ONLY_HIGH"],
                ["category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_ONLY_HIGH"],
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GeminiError.apiError
        }

        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String
        else {
            throw GeminiError.parseError
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Local Fallback (when no API key)

    private func generateLocalResponse(_ text: String, character: Character) async {
        // Use existing DrHopeResponseEngine for Dr. Hope
        let response: String
        switch character {
        case .drHope:
            response = DrHopeResponseEngine.generateResponse(for: text)
        case .mrHope:
            response = generateMrHopeResponse(for: text)
        }

        lastResponse = response
        let assistantMessage = ConversationMessage(role: .assistant, content: response, timestamp: Date())
        conversationHistory.append(assistantMessage)
    }

    private func generateMrHopeResponse(for text: String) -> String {
        let lowercased = text.lowercased()
        let responses: [String]

        if lowercased.contains("happy") || lowercased.contains("good") || lowercased.contains("great") {
            responses = [
                "That's what I'm talking about, Champ! Keep that energy up. You earned this good feeling!",
                "Now THAT'S the vibe! Ride that wave, Champ. You deserve every bit of it.",
                "Yes sir! Look at you glowing! I'm proud of you, Champ. Keep stacking those wins!",
            ]
        } else if lowercased.contains("tired") || lowercased.contains("exhausted") || lowercased.contains("drained") {
            responses = [
                "Hey Champ, even MVPs need rest days. No shame in recharging. You'll come back stronger.",
                "Listen, your body's telling you something. Honor it. Rest ain't quitting — it's strategy.",
                "Take the breather, Champ. Tomorrow's a fresh start. You've already proven you're a fighter.",
            ]
        } else if lowercased.contains("scared") || lowercased.contains("afraid") || lowercased.contains("nervous") {
            responses = [
                "Champ, courage ain't the absence of fear — it's showing up anyway. And you showed up today!",
                "I hear you. But remember — you've faced hard things before and you're still standing. That's not luck.",
                "Hey, every champion feels nervous before the big moment. That's just your body getting ready to perform!",
            ]
        } else if lowercased.contains("angry") || lowercased.contains("mad") || lowercased.contains("frustrated") {
            responses = [
                "I feel you, Champ. That fire? Use it as fuel, not as a weapon. Channel it into something powerful.",
                "Real talk — it's okay to be heated. Just don't let it drive the bus. You're still in control.",
                "Hey, anger means you care about something deeply. That's not weakness. Let's figure out what to do with it.",
            ]
        } else {
            responses = [
                "I hear you, Champ. Whatever you're going through, you're not going through it alone. I got you.",
                "Thanks for keeping it real with me. That takes guts. You're doing better than you think.",
                "Champ, just the fact that you're talking about it? That's a win. Most people keep it bottled up. You're ahead of the game.",
                "Real talk — life throws curveballs. But you've got a solid swing. Let's figure this out together.",
            ]
        }

        return responses[abs(text.hashValue) % responses.count]
    }

    // MARK: - Errors
    enum GeminiError: Error {
        case apiError
        case parseError
        case noAPIKey
    }
}
