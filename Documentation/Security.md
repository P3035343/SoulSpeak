# SoulSpeak Security Architecture

## Encryption
- **Algorithm**: AES-256-GCM via Apple CryptoKit
- **Key Storage**: iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **Scope**: Journal entry content (opt-in per entry)
- **Implementation**: `EncryptionService` actor for thread safety

## Authentication
- **Biometric**: Face ID / Touch ID / Optic ID via LocalAuthentication
- **Fallback**: Device passcode
- **Auto-lock**: App locks on background transition
- **Implementation**: `BiometricAuthService`

## Privacy Protection
- **Privacy Overlay**: Opaque screen shown when app enters background
- **No Analytics**: Zero tracking or telemetry
- **No Cloud Sync**: All data remains on-device
- **No Network**: Personal data never transmitted

## Keychain Usage
- Encryption keys
- API keys (if any external services added)
- User tokens
- Biometric secrets

## Crisis Detection Privacy
- **Local Only**: All text analysis happens on-device
- **No Logging**: Crisis keywords are not stored or transmitted
- **User Control**: Users can disable detection in settings

## Data Deletion
- Full data wipe available in Settings
- Individual entry deletion
- Keychain cleanup on reset
