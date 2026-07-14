import Foundation

final class LocalCrisisDetectionService: CrisisServiceProtocol {
    private let crisisKeywords: [String: CrisisSeverity] = [
        "suicide": .critical,
        "kill myself": .critical,
        "end my life": .critical,
        "want to die": .critical,
        "self-harm": .high,
        "cutting": .high,
        "hurt myself": .high,
        "overdose": .critical,
        "hopeless": .medium,
        "worthless": .medium,
        "no reason to live": .high,
        "can't go on": .high,
        "give up": .medium,
        "burden to everyone": .high,
        "nobody cares": .medium,
        "alone forever": .low,
        "exhausted": .low,
        "overwhelmed": .low,
    ]
    
    private var crisisContacts: [CrisisContact] = []
    
    func detectCrisisLanguage(in text: String) -> CrisisDetectionResult {
        let lowercasedText = text.lowercased()
        var matchedKeywords: [String] = []
        var highestSeverity: CrisisSeverity = .none
        
        for (keyword, severity) in crisisKeywords {
            if lowercasedText.contains(keyword) {
                matchedKeywords.append(keyword)
                if severityLevel(severity) > severityLevel(highestSeverity) {
                    highestSeverity = severity
                }
            }
        }
        
        let suggestedAction: String
        switch highestSeverity {
        case .none:
            suggestedAction = "No action needed"
        case .low:
            suggestedAction = "Consider showing a supportive message"
        case .medium:
            suggestedAction = "Show wellness resources and coping strategies"
        case .high:
            suggestedAction = "Display crisis resources and encourage reaching out"
        case .critical:
            suggestedAction = "Immediately show crisis hotline numbers and emergency contacts"
        }
        
        return CrisisDetectionResult(
            isCrisisDetected: highestSeverity != .none,
            severity: highestSeverity,
            matchedKeywords: matchedKeywords,
            suggestedAction: suggestedAction
        )
    }
    
    func getCrisisContacts() async throws -> [CrisisContact] {
        var contacts = crisisContacts
        contacts.append(contentsOf: getDefaultHotlines())
        return contacts
    }
    
    func addCrisisContact(_ contact: CrisisContact) async throws {
        crisisContacts.append(contact)
    }
    
    func removeCrisisContact(_ contact: CrisisContact) async throws {
        crisisContacts.removeAll { $0.id == contact.id }
    }
    
    func getDefaultHotlines() -> [CrisisContact] {
        [
            CrisisContact(
                name: "988 Suicide & Crisis Lifeline",
                phoneNumber: "988",
                relationship: "hotline",
                isPrimary: true,
                isHotline: true,
                organizationName: "SAMHSA",
                availableHours: "24/7"
            ),
            CrisisContact(
                name: "Crisis Text Line",
                phoneNumber: "741741",
                relationship: "hotline",
                isHotline: true,
                organizationName: "Crisis Text Line",
                availableHours: "24/7"
            ),
            CrisisContact(
                name: "National Domestic Violence Hotline",
                phoneNumber: "1-800-799-7233",
                relationship: "hotline",
                isHotline: true,
                organizationName: "NDVH",
                availableHours: "24/7"
            ),
        ]
    }
    
    private func severityLevel(_ severity: CrisisSeverity) -> Int {
        switch severity {
        case .none: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
}
