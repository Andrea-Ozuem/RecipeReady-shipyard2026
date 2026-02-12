# ``RecipeReady``

Transform social media cooking videos from Instagram and TikTok into actionable, step-by-step recipes using AI.

## Overview

RecipeReady is an iOS application designed to bridge the gap between watching delicious food on social media and actually cooking it. By leveraging advanced AI, the app automatically extracts ingredients and cooking instructions from video captions and audio, formatting them into a clean, easy-to-use recipe card.

## Goal

To empower home cooks to effortlessly capture and organize recipes from their favorite content creators, eliminating the friction of manual transcription or screenshooting.

## Purpose

Social media platforms are flooded with inspiring cooking content, but they are not designed for cooking. Recipes are often buried in captions, spoken quickly in videos, or missing entirely. RecipeReady solves this by:
-   **Parsing unstructured data** (captions, audio) into structured recipe formats.
-   **Organizing content** into personal cookbooks.
-   **Providing utility** through shopping lists and cooking modes.

## Solution

A seamless "Share to RecipeReady" experience where users can simply share a video link from Instagram or TikTok. The app handles the rest—extracting the recipe, saving the video, and presenting it in a format optimized for the kitchen.

## Key Features

### Smart Extraction
Powered by Google's Gemini AI, RecipeReady uses a multi-modal approach to ensure high-accuracy extraction:
1.  **Caption Analysis**: Parses the video caption for ingredients and instructions.
2.  **Audio Analysis**: Downloads the video and uses Gemini Multimodal to listen to the narration and extract details not found in the text.
3.  **Intelligent Merging**: Combines data from both sources to create the most complete recipe possible.

### Organization
-   **Cookbooks**: Organize recipes into custom collections (e.g., "Weeknight Dinners", "Desserts").
-   **Static Cookbooks**: Includes curated collections like "Eitan Eats the World".
-   **Favorites**: Quickly access your most-loved recipes.

### Shopping List
-   **Smart Scaling**: Automatically scales ingredient quantities based on your desired serving size.
-   **Checklist**: Interactive grocery list to track what you have and what you need.
-   **Consolidated View**: View ingredients by recipe or as a master list.

### Cooking Experience
-   **Cooking Mode**: A focused, step-by-step view with large text and timers.
-   **Timers**: Built-in timers for cooking steps (e.g., "Simmer for 10 minutes").
-   **Servings Adjustment**: Dynamically adjust ingredient amounts for different party sizes.

### Recipe Sharing
-   **PDF Export**: Share beautifully formatted recipe PDFs with friends and family.
-   **Social Sharing**: Share deep links to recipes or cookbooks.

## Tech Stack

| Component | Technology |
|-----------|------------|
| **iOS App** | Swift, SwiftUI, SwiftData |
| **Architecture** | MVVM |
| **Share Extension** | NSItemProvider, App Groups |
| **AI Processing** | Google Gemini 1.5 Flash (Multimodal) |
| **Web Scraping** | Apify Client |
| **Data Persistence** | SwiftData (CloudKit Sync ready) |
| **Purchasing** | RevenueCat |
| **Video Handling** | AVFoundation |

## Topics

### Planning

- <doc:PRD>

### Getting Started

- ``RecipeReadyApp``
- ``ContentView``
- ``ExtractionManager``

### Services

- ``RecipeExtractionService``
- ``GeminiService``
- ``ApifyService``
- ``AppGroupManager``