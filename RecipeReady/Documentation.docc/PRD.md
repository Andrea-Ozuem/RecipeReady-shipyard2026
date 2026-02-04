# Product Requirements Document

@Metadata {
    @PageKind(article)
    @PageColor(orange)
}

Recipe Extraction from Shared Video Feature for iOS MVP.

## Overview

**Project:** RecipeReady App – iOS MVP  
**Feature:** Share Extension → Audio/Caption Extraction → Recipe Generation  
**Target Platform:** iOS (initially Instagram & TikTok only)  
**Owner:** andrea  
**Date:** 2026-01-31

### Objective

Allow users to share a recipe video from Instagram or TikTok directly into the app, automatically extracting:
- Ingredients
- Cooking instructions
- Recipe metadata (time, servings, external links)

**Goal:** Generate structured recipes in editable form without requiring manual typing.

**Primary User Benefits:**
- Save time
- Capture recipe ideas from videos instantly
- Build user-friendly, editable recipe collection

---

## User Stories

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US-01 | Share a Reel from Instagram/TikTok so the app can extract a recipe | App appears in Share Sheet, accepts video, triggers extraction |
| US-02 | Ingredients appear automatically | Ingredients parsed from caption/audio in editable list |
| US-03 | Cooking steps extracted automatically | Audio-based steps converted to ordered instructions |
| US-04 | Link to original recipe if in caption | External link captured and displayed |
| US-05 | Edit and confirm extracted recipes | User can adjust ingredients, steps, notes before saving |

---

## Feature Scope

### In-Scope (MVP)

- iOS Share Extension to receive shared URLs
- Caption extraction via Apify API (Instagram/TikTok scraping)
- AI-powered recipe extraction:
  - **If caption contains ingredients AND cooking instructions** → Use Gemini AI to format into structured recipe
  - **If caption lacks recipe content** → Fall back to audio transcription from url
- Audio transcription via Apple Speech → Parse with Gemini
- Structured recipe JSON displayed in main app
- Editable recipe interface in main app
- Temporary storage in App Group container
- Cleanup of temporary files after processing

### Pending / TBD

- **Audio download from URL** — Currently audio extraction only works for direct video shares. Need to investigate how to download video/audio from Instagram/TikTok URL (Apify may provide `videoUrl` or `audioUrl`)

### Out-of-Scope (V2+)

- TikTok/Instagram URL scraping outside Share Sheet
- Music/sound separation for ASR

---

## Technical Architecture

### iOS App Components

#### Share Extension
- Receives shared URLs from Instagram/TikTok
- Fetches caption via **Apify API** (Instagram/TikTok scraper)
- For direct video shares: extracts audio using `AVFoundation`
- Saves payload (caption, audio, source URL) in App Group container

#### Main App
- Detects pending extraction from Share Extension
- Executes 2-step extraction pipeline:
  1. **Caption → Gemini** (parse recipe from caption text)
  2. **Audio → Apple Speech → Gemini** (fallback if no recipe in caption)
- Displays structured recipe for editing before saving

### External Services (No Backend Required)

| Service | Purpose | Cost |
|---------|---------|------|
| **Apify** | Scrape Instagram/TikTok captions | Pay-per-use (~$5/1000 videos) |
| **Gemini AI** | Parse recipe from text | Free tier (15 req/min, 1M tokens/day) |
| **Apple Speech** | On-device audio transcription | Free (built into iOS) |

### Recipe Response Format

```json
{
  "title": "Classic Tomato Pasta",
  "ingredients": [
    {"name": "olive oil", "amount": "2 tbsp"}
  ],
  "steps": [
    {"order": 1, "instruction": "Heat olive oil in pan."}
  ],
  "source_link": "https://instagram.com/p/xxx",
  "confidence_score": 0.87
}
```

---

## Detailed Extraction Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    EXTRACTION PIPELINE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. SHARE EXTENSION                                         │
│     └─→ User shares Instagram/TikTok URL                    │
│     └─→ Apify API fetches post data (caption, videoUrl)     │
│     └─→ Save payload to App Group Container                 │
│     └─→ Open main app via URL scheme                        │
│                                                             │
│  2. MAIN APP: CAPTION ANALYSIS                              │
│     └─→ Send caption to Gemini AI with prompt:              │
│         "Does this contain a recipe with ingredients        │
│          AND cooking instructions?"                         │
│     └─→ IF YES: Format into structured recipe → ✅ DONE     │
│     └─→ IF NO: Proceed to Step 3                            │
│                                                             │
│  3. AUDIO FALLBACK (TBD - pending audio download impl)      │
│     └─→ Download audio from videoUrl (Apify provides this)  │
│     └─→ Transcribe via Apple Speech Framework               │
│     └─→ Send transcript to Gemini AI                        │
│     └─→ Format into structured recipe → ✅ DONE             │
│                                                             │
│  4. DISPLAY & EDIT                                          │
│     └─→ Show parsed recipe in editable UI                   │
│     └─→ User confirms/edits/saves                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Decision Points

| Condition | Action |
|-----------|--------|
| Caption has ingredients + steps | Gemini formats → Done |
| Caption is vague / no recipe | Fall back to audio |
| No audio available | Show "No recipe detected" + manual entry |
| Audio is music-heavy | Low confidence flag + allow edit |

---

## User Flow

1. User taps **Share → RecipeReady** from Instagram/TikTok
2. Share Extension receives URL and fetches caption via Apify
3. Payload (caption + source URL) saved to App Group container
4. Main app opens and detects pending extraction
5. **Step 1:** Send caption to Gemini AI for recipe parsing
6. If recipe found → Display for editing
7. If no recipe → **Step 2:** Transcribe audio via Apple Speech → Send to Gemini
8. User reviews, edits, and saves recipe

---

## Technical Details

### Audio Extraction (iOS)

| Aspect | Detail |
|--------|--------|
| Framework | `AVFoundation` |
| Export Format | `.m4a` (mono, 16kHz) |
| Storage | App Group container |
| Cleanup | Delete after processing or user cancels |

### Apple Speech Transcription

| Aspect | Detail |
|--------|--------|
| Framework | `Speech` (SFSpeechRecognizer) |
| Input | Audio file URL (.m4a, .wav) |
| Output | Plain text transcript |
| Cost | Free (on-device) |
| Requirement | `NSSpeechRecognitionUsageDescription` in Info.plist |

### Gemini AI Parsing

| Aspect | Detail |
|--------|--------|
| Model | Gemini 1.5 Flash (free tier) |
| Input | Caption text or audio transcript |
| Output | Structured recipe JSON |
| Prompt | System prompt for recipe extraction |
| Rate Limit | 15 req/min, 1M tokens/day |

**Prompt Strategy:**
- Instruct to extract only explicit recipe content
- Avoid hallucination—return empty if no recipe found
- Confidence score based on clarity of source text

---

## Error Handling

| Case | Handling |
|------|----------|
| No URL detected | Show "Please share a video from Instagram or TikTok" |
| Apify fails | Show error, allow retry |
| Silent video / no recipe in caption | Fallback to audio transcription |
| Music-heavy audio | Flag low confidence, allow user edit |
| No recipe found at all | Show "No recipe detected" with manual entry option |
| Gemini rate limit | Queue request or show "Try again in a moment" |

---

## MVP Success Metrics

- **90%** of recipes have ingredients correctly parsed
- **85%** of cooking steps correctly parsed
- **< 5 seconds** average processing time per Reel
- **95%** user can edit and save recipe successfully
- **Zero** App Store rejections for Share Extension usage

---

## Milestones / Timeline

| Milestone | Duration | Notes |
|-----------|----------|-------|
| ✅ Xcode project & Share Extension | Done | App Group enabled |
| ✅ Apify caption extraction | Done | Instagram/TikTok supported |
| ⏳ Gemini AI integration | 0.5 day | Recipe parsing from text |
| ⏳ Apple Speech transcription | 0.5 day | Fallback audio → text |
| ⏳ Extraction pipeline orchestration | 0.5 day | Caption → Audio fallback |
| ⏳ Recipe UI & editing | 1 day | Display parsed recipe |
| ⏳ Testing & cleanup | 0.5 day | Edge cases |

**Total: ~3 days remaining for MVP**

---

## App Store Considerations

> [!Important]
> Explicitly document that: "The app only processes videos that users explicitly share to the app. Media is transient and not stored permanently."

- Avoid any scraping or background video downloading
- Only process user-shared content
