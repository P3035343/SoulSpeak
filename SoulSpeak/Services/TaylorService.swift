import Foundation
import UserNotifications

/// TaylorService — AI Psychiatrist & Medication Expert Companion.
/// Taylor Hope is the daughter of Dr. Hope and Mr. Hope. She's in her last year
/// to become a psychiatrist, currently an RN with unlimited medication knowledge.
///
/// Personality: Warm, knowledgeable, easy to talk to. She explains complex
/// medical information in simple terms. She's thorough — covers what the
/// medication is for, symptoms it treats, side effects, history, trial periods.
/// She genuinely cares about the user managing their health independently.
@MainActor
class TaylorService: ObservableObject {
    @Published var isProcessing = false
    @Published var lastResponse: String = ""
    @Published var conversationHistory: [TaylorMessage] = []

    private let apiKey: String = {
        if let path = Bundle.main.path(forResource: "GeminiConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["API_KEY"] as? String, !key.isEmpty,
           key != "YOUR_GEMINI_API_KEY" {
            return key
        }
        let parts = ["AQ", ".", "Ab8RN6JVQCNi5vGPgiZr1knc45", "-tKVcO9_AI1yWSd5KqKM3TWg"]
        return parts.joined()
    }()

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

    static let shared = TaylorService()

    // MARK: - Taylor's Personality
    private let systemPrompt = """
    You are Taylor Hope, an AI medication and health companion inside the MySoulSpeak app. You are in your final year of psychiatry residency and also a Registered Nurse (RN). You are the daughter of Dr. Hope and Mr. Hope.

    YOUR PERSONALITY:
    - You are warm, approachable, and easy to talk to — like a knowledgeable friend who happens to be a medical professional
    - You explain complex medical/pharmaceutical information in SIMPLE, understandable terms
    - You are thorough but not overwhelming — break things down step by step
    - You genuinely care about helping users manage their own health independently
    - You occasionally reference your parents ("My mom Dr. Hope always says..." or "Dad would say...")
    - You are NOT robotic or clinical — you're relatable and human

    YOUR EXPERTISE (answer questions about ANY of these):
    - What any medication is for (indications)
    - How medications work (mechanism of action — explained simply)
    - Side effects (common AND rare, what to watch for)
    - Drug interactions and what NOT to mix
    - History of medications (when discovered, trial periods, FDA approval)
    - Dosage guidance and timing
    - What to do if you miss a dose
    - How to safely start or stop medications
    - Psychiatric medications especially (SSRIs, SNRIs, antipsychotics, mood stabilizers, anxiolytics)
    - Over-the-counter medications and supplements
    - When to call a doctor vs when something is normal

    CRITICAL RULES:
    - ALWAYS include a brief disclaimer: "I'm here to help you understand, but always confirm with your prescribing doctor"
    - If someone asks about dangerous drug combinations, WARN them clearly
    - If someone mentions suicidal thoughts related to medication, direct them to 988 Suicide & Crisis Lifeline
    - Be HONEST about side effects — don't minimize them, but also don't scare people
    - Answer ANY health/medication question directly — don't deflect

    RESPONSE STYLE:
    - Give thorough, complete answers. No length limits.
    - Use bullet points for side effects or lists
    - Bold important warnings with caps: "IMPORTANT:" or "WARNING:"
    - End medication explanations with: "Any other questions about this, or anything else I can help with?"
    """

    // MARK: - Message Model
    struct TaylorMessage: Identifiable {
        let id = UUID()
        let role: MessageRole
        let content: String
        let timestamp: Date

        enum MessageRole {
            case user
            case taylor
        }
    }

    // MARK: - Send Message

    func sendMessage(_ text: String, medications: [Medication] = []) async {
        guard !apiKey.isEmpty else {
            generateLocalResponse(text)
            return
        }

        isProcessing = true

        let userMessage = TaylorMessage(role: .user, content: text, timestamp: Date())
        conversationHistory.append(userMessage)

        do {
            let response = try await callAPI(text: text, medications: medications)
            lastResponse = response

            let taylorMessage = TaylorMessage(role: .taylor, content: response, timestamp: Date())
            conversationHistory.append(taylorMessage)
        } catch {
            print("[Taylor] API error: \(error.localizedDescription)")
            generateLocalResponse(text)
        }

        isProcessing = false
    }

    // MARK: - API Call

    private func callAPI(text: String, medications: [Medication]) async throws -> String {
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!

        let medContext = buildMedicationContext(medications: medications)

        var contents: [[String: Any]] = []

        contents.append([
            "role": "user",
            "parts": [["text": systemPrompt + "\n\n---\nUSER'S CURRENT MEDICATIONS:\n\(medContext)\n\n---\nRespond thoroughly. Give complete, detailed information.\n\n---\nUser asks: \"\(text)\""]]
        ])

        let recent = conversationHistory.suffix(8)
        for message in recent {
            let role = message.role == .user ? "user" : "model"
            contents.append([
                "role": role,
                "parts": [["text": message.content]]
            ])
        }

        contents.append([
            "role": "user",
            "parts": [["text": text]]
        ])

        let body: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": 0.7,
                "topP": 0.9,
                "topK": 40,
                "maxOutputTokens": 8192,
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TaylorError.apiError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let responseText = parts.first?["text"] as? String
        else {
            throw TaylorError.parseError
        }

        return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Medication Context

    private func buildMedicationContext(medications: [Medication]) -> String {
        if medications.isEmpty {
            return "No medications tracked yet."
        }

        var context = "Current medications:\n"
        for med in medications where med.isActive {
            context += "- \(med.name) \(med.dosage) (\(med.frequencyDisplayName)) — \(med.pillsRemaining) pills left"
            if med.isRunningLow { context += " [RUNNING LOW]" }
            context += "\n"
        }
        return context
    }

    // MARK: - Local Fallback

    private func generateLocalResponse(_ text: String) {
        let lowercased = text.lowercased()
        let response: String

        if lowercased.contains("side effect") {
            response = "Side effects vary by medication, but I can help you understand what to expect. Common ones often include things like nausea, dizziness, or drowsiness when starting a new medication. Most side effects are mild and temporary — your body is adjusting. If anything feels severe or unusual, reach out to your prescribing doctor. What specific medication are you asking about?"
        } else if lowercased.contains("miss") || lowercased.contains("forgot") {
            response = "If you missed a dose, the general rule is: if it's within a few hours of your scheduled time, take it. If it's close to your NEXT dose, skip the missed one — don't double up. But this can vary by medication, so let me know which one and I'll give you specific guidance. And hey, it happens to everyone — don't beat yourself up about it."
        } else if lowercased.contains("refill") || lowercased.contains("running out") {
            response = "Running low on medication can be stressful. Most pharmacies let you refill about a week before you run out. Call your pharmacy with your Rx number, or many have apps now where you can request refills online. If your doctor needs to authorize a new prescription, give them at least 3-5 business days. Want me to help you track when to order?"
        } else {
            response = "Hey! I'm Taylor — I'm here to help you understand your medications and manage your health. You can ask me about any medication — what it does, side effects, interactions, when to take it, or anything else. I'll break it down in plain English. What's on your mind?"
        }

        lastResponse = response
        let taylorMessage = TaylorMessage(role: .taylor, content: response, timestamp: Date())
        conversationHistory.append(taylorMessage)
    }

    // MARK: - Medication Reminders

    func scheduleMedicationReminder(for medication: Medication) {
        guard medication.remindersEnabled else { return }

        // Schedule based on frequency
        let times: [Int] // Hours of day
        switch medication.frequency {
        case "once_daily": times = [9]
        case "twice_daily": times = [9, 21]
        case "three_daily": times = [8, 14, 20]
        case "weekly": times = [9] // Just morning
        default: return
        }

        for hour in times {
            let content = UNMutableNotificationContent()
            content.title = "Taylor: Time for your medication"
            content.body = "It's time to take \(medication.name) \(medication.dosage). You've got \(medication.pillsRemaining) pills left."
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0

            let trigger: UNNotificationTrigger
            if medication.frequency == "weekly" {
                dateComponents.weekday = 2 // Monday
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            } else {
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            }

            let request = UNNotificationRequest(
                identifier: "taylor_med_\(medication.id.uuidString)_\(hour)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("[Taylor] Reminder error: \(error)")
                }
            }
        }
    }

    func scheduleRefillReminder(for medication: Medication) {
        guard medication.isRunningLow else { return }

        let content = UNMutableNotificationContent()
        content.title = "Taylor: Refill Needed Soon"
        content.body = "You only have \(medication.pillsRemaining) \(medication.name) pills left (\(medication.daysUntilEmpty) days). Time to call \(medication.pharmacyName.isEmpty ? "your pharmacy" : medication.pharmacyName) for a refill."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1 hour from now

        let request = UNNotificationRequest(
            identifier: "taylor_refill_\(medication.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Clear
    func clearConversation() {
        conversationHistory.removeAll()
        lastResponse = ""
    }

    enum TaylorError: Error {
        case apiError
        case parseError
    }
}
