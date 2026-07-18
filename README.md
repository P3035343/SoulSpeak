# SoulSpeak

A spiritual mental wellness iOS app featuring two caring characters who guide users through voice journaling, mood tracking, prayer, and personal growth.

## Characters

- **Dr. Hope** — Main therapist with Gullah-style warmth and spiritual wisdom. Comforting, wise, and deeply caring.
- **Mr. Hope** — Warm greeter who calls the user "Champ" and sets a welcoming tone.

## Screens

| Screen | Description |
|--------|-------------|
| **Welcome** | Mr. Hope animated avatar + "Dr. Hope will see you shortly, Champ" + Start button |
| **Voice Journal** | Record/Stop, real-time waveform animation, Dr. Hope's text feedback, mood selector |
| **Mood Tracker** | Calendar with emotion icons, mood history chart, daily reflection prompt |
| **Analytics** | Weekly stats, journaling streaks, mood trends, progress badges |
| **Prayer/Outro** | Dr. Hope's closing quote, play prayer button, scripture of the day |
| **Settings** | Theme toggle, notifications, mental health resources with GPS locator |

## Tech Stack

- **Platform:** iOS 17+
- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData
- **Audio:** AVFoundation
- **Location:** CoreLocation + MapKit
- **Project:** Native Xcode project (.xcodeproj)

## Project Structure

```
SoulSpeak/
├── SoulSpeak.xcodeproj/
├── SoulSpeak/
│   ├── App/
│   │   ├── SoulSpeakApp.swift
│   │   ├── ContentView.swift
│   │   └── MainTabView.swift
│   ├── Models/
│   │   ├── JournalEntry.swift
│   │   ├── MoodEntry.swift
│   │   └── UserSettings.swift
│   ├── Services/
│   │   ├── AudioPlayerService.swift
│   │   ├── ScriptureService.swift
│   │   └── VoiceRecorderService.swift
│   ├── Theme/
│   │   └── SoulSpeakTheme.swift
│   ├── Views/
│   │   ├── Welcome/WelcomeView.swift
│   │   ├── VoiceJournal/VoiceJournalView.swift
│   │   ├── VoiceJournal/WaveformView.swift
│   │   ├── MoodTracker/MoodTrackerView.swift
│   │   ├── Analytics/AnalyticsView.swift
│   │   ├── Prayer/PrayerOutroView.swift
│   │   └── Settings/SettingsView.swift
│   ├── Assets.xcassets/
│   ├── Resources/
│   └── Info.plist
```

## Assets to Add Manually

Place these files in the project:

### Audio Files (add to Resources/ folder, ensure "Copy to bundle" is checked)
- `dr_hope_intro.mp3` — Dr. Hope's introduction audio
- `mr_hope_greeting.mp3` — Mr. Hope's greeting ("Champ" welcome)
- `dr_hope_prayer.mp3` — Dr. Hope's evening prayer
- `jazz_loop_1.mp3` — Background jazz loop (welcome)
- `jazz_loop_2.mp3` — Background jazz loop (main app)
- `jazz_loop_3.mp3` — Background jazz loop (alternate)

### Image Assets (add to Assets.xcassets)
- `Dr_Hope_Office_Render.jpg` → `dr_hope_office_render` image set
- `Mr_Hope_Office_Render.jpg` → `mr_hope_office_render` image set
- Dr. Hope avatar → `dr_hope` image set
- Mr. Hope avatar → `mr_hope` image set

## Features

- **No Lock Screen** — App goes straight to content, idle timer disabled
- **Animated Talking Avatars** — Characters animate with breathing, head nods, and sound wave indicators
- **Immersive Office Backgrounds** — Custom render images for character offices
- **Gullah-Style Dialogue** — Dr. Hope speaks with warm, culturally-rooted wisdom
- **Real-Time Waveform** — Voice journal shows live audio level visualization
- **SwiftData Persistence** — All journal entries, moods, and settings saved locally
- **GPS Resource Locator** — Find nearby mental health services using MapKit
- **Crisis Hotlines** — Quick access to 988, Crisis Text Line, SAMHSA, NAMI

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Open `SoulSpeak.xcodeproj` in Xcode
2. Add your audio files to the Resources folder
3. Add your image assets to Assets.xcassets
4. Build and run on a device or simulator (iOS 17+)
