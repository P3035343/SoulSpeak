# SoulSpeak Data Models

## Core Models (SwiftData @Model)

### JournalEntry
Primary journaling model with encryption support.
- Fields: id, title, content, encryptedContent, mood, moodIntensity, tags, dates, isFavorite, isEncrypted, wordCount, promptUsed, aiInsight

### MoodEntry
Mood tracking with triggers and context.
- Fields: id, mood, intensity, note, triggers, activities, energyLevel, sleepQuality, timestamp, weatherCondition, location

### Affirmation
Daily affirmations with categories.
- Fields: id, text, category, isCustom, isFavorite, timesViewed, lastViewedAt, sourceAttribution

### UserProfile
User settings and statistics.
- Fields: id, displayName, avatarImageData, joinDate, theme, notifications, biometric, encryption, categories, streaks, totals

### Ritual
Customizable daily rituals.
- Fields: id, name, description, steps, duration, category, frequency, isActive, completionCount, lastCompletedAt

### GrowthMilestone
Personal growth goals with progress tracking.
- Fields: id, title, description, category, isCompleted, completedAt, targetDate, progress, reflectionNote

### Additional Models
- **GratitudeEntry**: Daily gratitude items with reflection
- **BreathworkSession**: Breathwork exercise tracking
- **CrisisContact**: Emergency contacts and hotlines
- **DailyCheckIn**: Morning check-in data
- **ThemePreference**: Custom theme settings
- **Achievement**: Gamification achievements
- **CommunityPost**: Anonymous community sharing
- **Streak**: Activity streak tracking
- **InsightReport**: AI-generated wellness insights
