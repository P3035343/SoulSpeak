# SoulSpeak Privacy Documentation

## Core Privacy Principles

### 1. Local-First Architecture
All user data is stored exclusively on the user's device. There are no cloud services, no remote databases, and no data synchronization.

### 2. Zero Knowledge
The development team has zero access to user data. We cannot read journals, view moods, or access any personal information.

### 3. No Tracking
- No analytics SDKs
- No advertising identifiers
- No usage telemetry
- No crash reporting that includes personal data

### 4. Encryption at Rest
- Optional AES-256-GCM encryption for journal entries
- Encryption keys stored in iOS Keychain
- Keys never leave the device

### 5. Biometric Protection
- Face ID / Touch ID required to access app
- App content hidden on task switcher
- Auto-lock on background transition

## Data Handling

### What We Store
- Journal entries (locally, optionally encrypted)
- Mood entries (locally)
- Affirmations (locally)
- User preferences (locally)
- Achievement data (locally)

### What We DON'T Store
- Location data (never collected)
- Contact information (crisis contacts stored locally only)
- Usage analytics
- Advertising data
- Biometric data (handled by iOS, not our app)

## User Rights
- Export all data at any time
- Delete all data permanently
- No account required
- No email or phone number collected
