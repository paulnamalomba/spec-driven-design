---
name: create-release-listing-summaries
description: Creates user-facing abstract Android (5 points) and iOS (12 points) app store release listing summaries (<app>-<version>-listing.md) in the builds directory based on release commit notes (.commits/<version>.txt).
---

# Skill: Release Listing Summaries Creation

## Overview

This skill standardizes the generation of user-facing, abstract App Store and Google Play release listing summary documents (`<app>-<version>-listing.md`) for Ecoride mobile applications (`ecoride_driver`, `ecoride_rider`, etc.) stored in the central `builds/` directory.

The summaries translate internal technical release notes (`.commits/<version>.txt`) or Git diff baselines into polished, high-level, user-centric feature highlights suitable for public app store release notes.

---

## Output Target & Naming

- **Output Directory**: `builds/` (at the root of the ecoride project workspace, e.g., `/Users/kabwe/Development/ecoride_project/builds/`)
- **File Naming Format**: `<app>-<version>-listing.md`
  - Example Driver: `driver-1.0.28.80-listing.md`
  - Example Rider: `rider-1.0.38.80-listing.md`

---

## Structural Specification

Each generated listing summary Markdown document MUST adhere to the following structure:

```markdown
# Ecoride <App> v<Version> Release Listing Summary

Release Date: <Month Day, Year>  
Source Document: <version>.txt

---

## Android Listing Summary (5 Points)

- Point 1
- Point 2
- Point 3
- Point 4
- Point 5

---

## iOS Listing Summary (12 Points)

- Point 1
- Point 2
- Point 3
- Point 4
- Point 5
- Point 6
- Point 7
- Point 8
- Point 9
- Point 10
- Point 11
- Point 12
```

---

## Abstraction & Content Guardrails

### 1. Abstract & User-Centric Focus
- Write from the perspective of user benefits, functional enhancements, visual polish, performance improvements, and reliability.
- Use simple, concise, and professional natural language appropriate for public App Store and Google Play "What's New" release notes.

### 2. Strict Prohibition of Fine-Grained Technical Details
NEVER include low-level code implementation details in listing summaries. Specifically exclude:
- **Widget / Class / Component Names**: Do NOT mention names like `EcorideButtonClear`, `DispatchOpenCoordinator`, `OfferDeadlineCountdown`, `EcorideSlideButton`, etc. Abstract them to general concepts like "action buttons", "notification coordinator", "countdown timer", or "slide controls".
- **Variable / Payload / Type Names**: Do NOT mention internal types or strings like `ride_dispatch_offer`, `DispatchOpenIntent`, `offerExpiresAt`, or `claimNotificationSoundReminder`.
- **Code Counts & Quantitative Refactor Metrics**: Do NOT include internal code metrics such as "139 widget surfaces", "227 text scaling declarations", or "100-key cache".
- **Exact Numeric Opacities & Constants**: Do NOT mention specific code values like `0.84`, `0.12`, or `0.15` opacity tokens. Use terms like "harmonized translucent contrast" or "refined border outlines".
- **Internal Scripts & Tooling**: Do NOT reference internal maintenance tools like `replace_alpha_values.py`.
- **Quoted Text Strings / UI Labels**: Avoid quoting exact code string literals (e.g. `"More Info"`, `"Sharing your trip status"`). Describe the functional feature instead.

---

## Execution Protocol

### Step 1: Discover Source Release Notes
1. Locate the source release note file in the target repository's `.commits/` directory (e.g., `ecoride_driver/.commits/1.0.28.80.txt` or `ecoride_rider/.commits/1.0.38.80.txt`).
2. Read the full release note document to identify major changes, UI redesigns, dispatch logic, safety features, performance tweaks, and accessibility improvements.
3. Extract the release date and version numbers.

### Step 2: Synthesize & Abstract Features
1. Categorize changes into broad user-facing domains:
   - Trip Booking & Dispatch Notifications
   - Real-time Tracking & State Synchronization
   - Visual Design, Typography & System Contrast
   - Payment, Auth & Registration Workflows
   - Safety, Support & Guided Tours
   - App Performance & Reliability
2. Transform each technical detail into an abstract summary bullet highlighting user value.

### Step 3: Format Output
1. Format exactly **5 Android points** focusing on core app updates.
2. Format exactly **12 iOS points** expanding on detailed user features, visual refinements, design consistency, and stability enhancements.
3. Ensure bullet points follow the format `- Title: Description sentence.`

### Step 4: Write Listing File
Write the final formatted markdown file directly to `builds/<app>-<version>-listing.md`.
