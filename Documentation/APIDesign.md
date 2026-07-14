# SoulSpeak Service API Design

## Protocol-Oriented Architecture

All services are defined through protocols, enabling:
- Easy unit testing with mocks
- Dependency injection
- Future swapping of implementations

## Service Protocols

### JournalServiceProtocol
```swift
func createEntry(_ entry: JournalEntry) async throws
func updateEntry(_ entry: JournalEntry) async throws
func deleteEntry(_ entry: JournalEntry) async throws
func fetchEntries(limit: Int?, offset: Int?) async throws -> [JournalEntry]
func searchEntries(query: String) async throws -> [JournalEntry]
func fetchFavorites() async throws -> [JournalEntry]
func getEntryCount() async throws -> Int
```

### MoodServiceProtocol
```swift
func logMood(_ entry: MoodEntry) async throws
func getMoodHistory(days: Int) async throws -> [MoodEntry]
func getMoodTrend(days: Int) async throws -> String
func getAverageMood(days: Int) async throws -> Double
func getMostCommonTriggers(days: Int) async throws -> [String]
```

### CrisisServiceProtocol
```swift
func detectCrisisLanguage(in text: String) -> CrisisDetectionResult
func getCrisisContacts() async throws -> [CrisisContact]
func addCrisisContact(_ contact: CrisisContact) async throws
func getDefaultHotlines() -> [CrisisContact]
```

## Error Handling
All service methods use Swift's native error handling with typed errors:
- `EncryptionError` for crypto operations
- `KeychainError` for secure storage
- Standard Swift errors for data operations

## Concurrency
- Services use `async/await` for asynchronous operations
- `EncryptionService` is an `actor` for thread safety
- UI state managers are `@MainActor`
