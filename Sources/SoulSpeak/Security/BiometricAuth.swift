import Foundation
import LocalAuthentication

@MainActor
final class BiometricAuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var biometricType: LABiometryType = .none
    @Published var errorMessage: String?
    
    private let context = LAContext()
    
    init() {
        checkBiometricAvailability()
    }
    
    func checkBiometricAvailability() {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
            errorMessage = error?.localizedDescription
        }
    }
    
    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Passcode"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = error?.localizedDescription ?? "Biometric authentication unavailable"
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock SoulSpeak to access your private journal"
            )
            isAuthenticated = success
            return success
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            return false
        }
    }
    
    func deauthenticate() {
        isAuthenticated = false
    }
    
    var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometric"
        }
    }
}
