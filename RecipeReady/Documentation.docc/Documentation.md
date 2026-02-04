# ``RecipeReady``

Transform cooking videos into step-by-step recipes.

## Overview

RecipeReady is an iOS app that allows users to share recipe videos from Instagram and TikTok, automatically extracting ingredients and cooking instructions using AI-powered parsing.

### Smart Import Flow

The app uses a 2-step fallback approach for recipe extraction:

1. **Caption Parsing** — Extracts caption via Apify → Parses with Gemini AI
2. **Audio Transcription** — Falls back to Apple Speech → Parses with Gemini AI

### Tech Stack

| Component | Technology |
|-----------|------------|
| iOS App | Swift, SwiftUI |
| Share Extension | NSItemProvider, App Groups |
| Caption Scraping | Apify API |
| Audio Extraction | AVFoundation |
| Speech-to-Text | Apple Speech Framework |
| Recipe Parsing | Gemini AI (free tier) |

## Topics

### Planning

- <doc:PRD>

### Getting Started

- ``RecipeReadyApp``
- ``ContentView``
- ``ExtractionManager``

### Services

- ``ApifyService``
- ``RecipeExtractionService``
- ``AppGroupManager``