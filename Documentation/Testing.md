# SoulSpeak Testing Strategy

## Test Structure
Tests are organized in `Tests/SoulSpeakTests/` with the following categories:

### Unit Tests
- **Model Tests**: Verify data model creation, defaults, and behavior
- **Service Tests**: Test mock service implementations
- **Crisis Detection Tests**: Validate keyword detection and severity levels
- **App State Tests**: Verify state machine transitions

### Test Files
1. `JournalEntryTests.swift` - Journal model validation (5 tests)
2. `MoodEntryTests.swift` - Mood entry validation (4 tests)
3. `AffirmationTests.swift` - Affirmation model tests (4 tests)
4. `CrisisDetectionTests.swift` - Crisis language detection (8 tests)
5. `StreakTests.swift` - Streak logic tests (5 tests)
6. `MockServiceTests.swift` - Service protocol tests (7 tests)
7. `AppStateManagerTests.swift` - App state transitions (5 tests)

### Total: 38 tests

## Testing Approach
- Protocol-based services enable easy mocking
- SwiftData in-memory containers for data tests
- @MainActor tests for UI state management
- No external dependencies in tests

## Running Tests
```bash
swift test
```

## Future Testing Plans
- UI Tests with XCUITest
- Snapshot tests for design system
- Performance tests for encryption
- Integration tests with SwiftData
