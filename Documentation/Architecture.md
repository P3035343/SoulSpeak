# SoulSpeak Architecture

## Overview
SoulSpeak follows a clean architecture pattern with clear separation of concerns, built entirely with SwiftUI and SwiftData for iOS 17+.

## Layer Structure

### Presentation Layer (Features/)
- SwiftUI Views organized by feature
- Each feature is self-contained with its own views
- Uses `@EnvironmentObject` for shared state
- Uses `@Query` for SwiftData integration

### Domain Layer (Models/ + Services/Protocols/)
- SwiftData `@Model` classes for persistence
- Protocol-defined service interfaces
- Business logic encapsulated in services

### Data Layer (Services/ + Security/)
- Concrete service implementations
- Local-first data storage via SwiftData
- Encryption via CryptoKit
- Keychain for sensitive data

## Key Design Decisions

1. **Local-First**: All data stored on-device, no cloud sync
2. **Protocol-Oriented**: Services defined by protocols for testability
3. **Privacy-First**: Encryption, biometric auth, privacy overlay
4. **SwiftData**: Modern persistence replacing Core Data
5. **Swift Concurrency**: async/await throughout service layer

## Data Flow
```
View -> @Query (SwiftData) -> Model
View -> Service Protocol -> Concrete Service -> SwiftData ModelContext
```

## Security Architecture
- AES-256-GCM encryption for journal entries
- Keychain storage for encryption keys
- Biometric authentication gate
- Privacy overlay on app backgrounding
- No network calls for personal data
