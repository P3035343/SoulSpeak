# Audio Files

Place the following audio files in this folder, then add them to the Xcode project
(drag into the project navigator, check "Copy items if needed" and "Add to target: SoulSpeak").

## Required Audio Files

| File Name | Description |
|-----------|-------------|
| `dr_hope_intro.mp3` | Dr. Hope's introduction/welcome audio |
| `mr_hope_greeting.mp3` | Mr. Hope's "Champ" greeting on welcome screen |
| `dr_hope_prayer.mp3` | Dr. Hope's evening prayer audio |
| `jazz_loop_1.mp3` | Jazz background loop for welcome screen |
| `jazz_loop_2.mp3` | Jazz background loop for main app |
| `jazz_loop_3.mp3` | Jazz background loop (alternate) |

## How the code references them

The code uses simple string names without extensions:
- `audioPlayer.playVoice(fileName: "dr_hope_intro")`
- `audioPlayer.playVoice(fileName: "mr_hope_greeting")`
- `audioPlayer.playPrayer(fileName: "dr_hope_prayer")`
- `audioPlayer.playBackgroundMusic(fileName: "jazz_loop_1")`
- `audioPlayer.playBackgroundMusic(fileName: "jazz_loop_2")`
- `audioPlayer.playBackgroundMusic(fileName: "jazz_loop_3")`

All files are expected to be `.mp3` format in the app bundle.
