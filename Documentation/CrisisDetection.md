# Crisis Detection System

## Overview
SoulSpeak includes a local, on-device crisis language detection system that monitors journal entries for signs of distress and provides appropriate resources.

## How It Works
1. User writes journal entry
2. Text is analyzed locally (never transmitted)
3. Keywords matched against severity database
4. Appropriate response triggered based on severity

## Severity Levels

### Critical
- Immediate display of crisis hotlines
- Keywords: suicide, kill myself, end my life, want to die, overdose

### High
- Display crisis resources and encourage outreach
- Keywords: self-harm, cutting, hurt myself, no reason to live, can't go on, burden to everyone

### Medium
- Show wellness resources and coping strategies
- Keywords: hopeless, worthless, give up, nobody cares

### Low
- Consider showing supportive message
- Keywords: alone forever, exhausted, overwhelmed

## Privacy Guarantees
- ALL analysis is performed on-device
- No keywords or detection results are stored
- No data is transmitted to any server
- Users can disable detection in settings

## Default Resources
- 988 Suicide & Crisis Lifeline (24/7)
- Crisis Text Line: Text HOME to 741741
- National Domestic Violence Hotline: 1-800-799-7233

## Important Notes
- This is NOT a replacement for professional help
- Detection is keyword-based and may have false positives/negatives
- Always err on the side of showing resources
