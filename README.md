# SoulSpeak

A privacy-first iOS mental wellness companion built with SwiftUI and SwiftData for iOS 17+.

## Overview

SoulSpeak is a comprehensive mental wellness app that prioritizes user privacy above all else. All data stays on-device, protected by AES-256 encryption and biometric authentication.

## Features

- **Journaling** - Rich text entries with mood tagging, encryption, and AI insights
- **Mood Tracking** - Track emotions, triggers, energy, and sleep with visual trends
- **Daily Affirmations** - Curated and custom affirmations with category browsing
- **Breathwork** - Guided breathing exercises (Box, 4-7-8, Energizing)
- **Gratitude** - Daily gratitude practice with streak tracking
- **Rituals** - Customizable daily wellness rituals
- **Growth Dashboard** - Milestones, achievements, and streaks
- **Community** - Anonymous sharing and support
- **Crisis Support** - Local crisis language detection with hotline resources
- **Security** - Biometric lock, AES-256 encryption, privacy overlay

## Privacy & Security

- All data stored locally on-device only
- AES-256-GCM encryption for journal entries
- Face ID / Touch ID authentication
- Privacy overlay on app background
- Zero analytics or tracking
- No cloud sync, no network calls for personal data
- Crisis detection runs entirely on-device

## Tech Stack

- **UI**: SwiftUI (iOS 17+)
- **Persistence**: SwiftData
- **Security**: CryptoKit, LocalAuthentication, Security framework
- **Architecture**: Protocol-oriented services with dependency injection
- **Concurrency**: Swift async/await, actors
- **Package Manager**: Swift Package Manager

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Clone the repository
2. Copy `Secrets.xcconfig.example` to `Secrets.xcconfig`
3. Open the project in Xcode
4. Build and run on simulator or device

## Project Structure

```
SoulSpeak/
├── Package.swift
├── Sources/SoulSpeak/
│   ├── App/                    # App entry point and state management
│   ├── DesignSystem/           # Colors, typography, reusable components
│   ├── Models/                 # SwiftData @Model definitions
│   ├── Security/               # Encryption, biometric, keychain
│   ├── Services/
│   │   ├── Protocols/          # Service interfaces
│   │   └── Mocks/              # Mock implementations for testing
│   ├── Features/               # Feature-organized views
│   └── Resources/              # Assets and static data
├── Tests/SoulSpeakTests/       # Unit tests (38 tests)
└── Documentation/              # Architecture and design docs
```

## Testing

Run tests with:
```bash
swift test
```

38 unit tests covering models, services, crisis detection, and state management.

## Documentation

See the `Documentation/` directory for:
- Architecture overview
- Design system guide
- Data model reference
- Security architecture
- Crisis detection system
- Privacy documentation
- Development roadmap
- API design patterns
- Testing strategy

## License

Private - All rights reserved.

## Crisis Resources

If you or someone you know is in crisis:
- **988 Suicide & Crisis Lifeline**: Call or text 988
- **Crisis Text Line**: Text HOME to 741741
- **Emergency**: Call 911
