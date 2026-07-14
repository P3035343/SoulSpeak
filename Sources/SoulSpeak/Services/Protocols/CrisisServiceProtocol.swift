import Foundation

protocol CrisisServiceProtocol {
    func detectCrisisLanguage(in text: String) -> CrisisDetectionResult
    func getCrisisContacts() async throws -> [CrisisContact]
    func addCrisisContact(_ contact: CrisisContact) async throws
    func removeCrisisContact(_ contact: CrisisContact) async throws
    func getDefaultHotlines() -> [CrisisContact]
}

struct CrisisDetectionResult {
    let isCrisisDetected: Bool
    let severity: CrisisSeverity
    let matchedKeywords: [String]
    let suggestedAction: String
}

enum CrisisSeverity: String, CaseIterable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}
