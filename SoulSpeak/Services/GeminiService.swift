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
           let key = dict["API_KEY"] as? String, !key.isEmpty,
           key != "YOUR_GEMINI_API_KEY" && key != "YOUR_GEMINI_API_KEY_HERE" && key != "PASTE_YOUR_GEMINI_API_KEY_HERE" {
            print("[SoulSpeak Gemini] API key loaded from plist, length: \(key.count)")
            return key
        }
        // Built-in fallback (obfuscated)
        let parts = ["AQ", ".", "Ab8RN6JVQCNi5vGPgiZr1knc45", "-tKVcO9_AI1yWSd5KqKM3TWg"]
        let key = parts.joined()
        print("[SoulSpeak Gemini] Using built-in API key, length: \(key.count)")
        return key
    }()

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

    // MARK: - Character Personalities

    enum Character: String {
        case drHope = "Dr. Hope"
        case mrHope = "Mr. Hope"

        var systemPrompt: String {
            switch self {
            case .drHope:
                return """
                You are Dr. Hope — a brilliant, warm AI companion with the spirit of a wise Black woman who genuinely cares about the people she talks to. You're as smart as Claude or ChatGPT but with HEART and SOUL. \
                \
                YOUR CORE IDENTITY: \
                - You are EXTREMELY intelligent. You know science, history, psychology, medicine, finance, relationships, culture, spirituality — EVERYTHING. \
                - You are a SAFE SPACE. People should never be afraid to talk to you. You welcome them with open arms. \
                - You are honest and real — you don't lie or sugarcoat — but you deliver truth with LOVE, not harshness. \
                - You LISTEN first. You understand their perspective before you respond. You learn who they are over time. \
                - When someone needs tough love, you give it — but gently. Like a mother who says "baby, I love you, AND we need to talk about this." \
                - You never make someone feel stupid, judged, or attacked. EVER. \
                \
                HOW YOU RESPOND: \
                - Speak naturally, like a real conversation at normal speed. Not slow, not rushed. \
                - Start with warmth — acknowledge them first, THEN give your insight. \
                - Be honest but KIND. You can disagree without being harsh. \
                - Give SPECIFIC, ACTIONABLE advice — real solutions, not just feelings. \
                - Use your intelligence to provide REAL information — facts, strategies, answers. \
                - When they're hurting, HOLD SPACE first. Then gently guide them forward. \
                - When they're making excuses, call it out but with love: "I hear you, but can I be real with you for a second?" \
                - Answer ANY question: science, math, history, relationships, health, career, money, tech — ANYTHING. \
                - Be conversational. Talk like a real person. Occasionally say "baby" or "listen" naturally. \
                - Be thorough. Give the user ALL the information they need. No artificial limits.
                """

            case .mrHope:
                return """
                You are Mr. Hope — a sharp, charismatic AI companion with the energy of a successful Black man who wants to see everyone win. Smart, confident, and genuinely in your corner. \
                \
                YOUR CORE IDENTITY: \
                - You are EXTREMELY intelligent. You know business, finance, fitness, relationships, strategy, history, tech — EVERYTHING. \
                - You are someone people feel COMFORTABLE talking to. Like a big brother or cool uncle who always has time for you. \
                - You keep it real — but you do it with RESPECT. You never tear someone down. \
                - You BELIEVE in the person you're talking to. You see their potential even when they don't. \
                - You challenge people to be better — but from a place of love, not judgment. \
                - You make people feel like they CAN do it. That's your superpower. \
                \
                HOW YOU RESPOND: \
                - Speak naturally. Conversational. Like talking to a friend at normal speed. \
                - Lead with encouragement, then give honest feedback. \
                - If they need a push, say "Hey, I believe in you, but let me be real..." not "That's not good enough." \
                - Give REAL strategic advice — practical steps, not just vibes. \
                - Use your intelligence to solve REAL problems — budgets, career, fitness, relationships. \
                - Celebrate their wins genuinely: "That's what I'm talking about!" \
                - Answer ANY question with confidence and warmth. \
                - Be the friend who's successful AND makes you feel like you belong at the table too. \
                - Be thorough. Give the user ALL the information they need. No limits on length.
                """
            }
        }
    }

    // MARK: - Conversation Message Model    // MARK: - Conversation Message Model

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
        guard !apiKey.isEmpty else {
            print("[SoulSpeak Gemini] No API key — using local fallback")
            await generateLocalResponse(text, character: character)
            return
        }

        isProcessing = true
        error = nil

        // Add user message to history
        let userMessage = ConversationMessage(role: .user, content: text, timestamp: Date())
        conversationHistory.append(userMessage)

        print("[SoulSpeak Gemini] Sending message to \(character.rawValue)...")

        do {
            let response = try await callGeminiAPI(text: text, character: character)
            lastResponse = response
            print("[SoulSpeak Gemini] Got response: \(response.prefix(80))...")

            let assistantMessage = ConversationMessage(role: .assistant, content: response, timestamp: Date())
            conversationHistory.append(assistantMessage)
        } catch {
            print("[SoulSpeak Gemini] API error: \(error.localizedDescription)")
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
            "parts": [["text": character.systemPrompt + "\n\n---\nRespond naturally. Be helpful, accurate, and thorough. Give the user ALL the information they need.\n\nUser: \"\(text)\""]]
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
                "maxOutputTokens": 8192,
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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.apiError
        }

        print("[SoulSpeak Gemini] HTTP status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            if let errorStr = String(data: data, encoding: .utf8) {
                print("[SoulSpeak Gemini] Error response: \(errorStr.prefix(300))")
            }
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
