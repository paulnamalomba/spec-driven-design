---
name: create-release-listing-summaries
description: Creates user-facing abstract Android and iOS app store release listing summaries (<app>-<version>-listing.md) in the listings repository's app-listings directory from release commit notes (.commits/<version>.md or .commits/<version>.txt).
---

# Skill: Release Listing Summaries Creation

## Overview

This skill standardizes user-facing, abstract App Store and Google Play release listing summary documents (`<app>-<version>-listing.md`) for mobile applications (`<app 1>`, `<app 2>`, etc.), stored in the workspace's central listings repository under `app-listings/`.

The summaries translate internal technical release notes (`.commits/<version>.md` or legacy `.commits/<version>.txt`) into concise, user-centric feature highlights suitable for public app store release notes.

---

## Output Target & Naming

- **Output Directory**: `<listings repo>/app-listings/` in the parent project workspace (e.g., `../<platform>_listings/app-listings/`). Locate the sibling `*/app-listings/` directory in the workspace; never write to the legacy `builds/` directory.
- **File Naming Format**: `<app>-<version>-listing.md`
  - Example Driver: `driver-1.0.52.105-listing.md`
  - Example Rider: `rider-1.0.64.108-listing.md`

---

## Structural Specification

Each generated listing summary Markdown document MUST adhere to the following structure:

```markdown
# <Platform Name> <App> v<Version> release listing summary

Release Date: <Month Day, Year>  
Source Document: <version>.md

---

## Android listing summary (<N> points)

- <Short Feature Title> (new): <Concise user-facing benefit sentence.>
- <Short Feature Title> (improved): <Concise user-facing benefit sentence.>

---

## iOS listing summary (<M> points)

- <Short Feature Title> (new): <Concise user-facing benefit sentence.>
- <Short Feature Title> (improved): <Concise user-facing benefit sentence.>
```

- Set `Source Document` to the exact source filename read (`<version>.md` or `<version>.txt`).
- Set the heading count to `(1 point)` when a platform has exactly 1 bullet, and `(<N> points)` otherwise. Android and iOS counts (`N` and `M`) reflect the actual distinct, user-facing changes for each platform and may differ when changes are platform-specific.
- Every bullet MUST place `(new)` or `(improved)` in brackets immediately before the colon:
  `- <Short Feature Title> (new|improved): <Concise user-facing benefit sentence.>`

---

## Abstraction & Content Guardrails

### 1. Abstract & User-Centric Focus

- Write from the perspective of user benefits, functional enhancements, visual polish, performance improvements, and reliability.
- Use simple, concise, and professional natural language appropriate for public App Store and Google Play "What's New" release notes.
- Only include distinct, user-facing changes from the target release. Do NOT pad bullets to hit an arbitrary count, duplicate the same change across multiple bullets, or include internal-only, test-only, CI/build-only, or admin-only entries.

### 2. Strict Prohibition of Fine-Grained Technical Details

NEVER include low-level code implementation details in listing summaries. Specifically exclude:

- **Widget / Class / Component Names**: Do NOT mention widget, class, or component names. Abstract them to general concepts like "action buttons", "notification coordinator", "countdown timer", or "slide controls".
- **Variable / Payload / Type Names**: Do NOT mention internal types or strings.
- **Code Counts & Quantitative Refactor Metrics**: Do NOT include internal code metrics such as "139 widget surfaces", "227 text scaling declarations", or "100-key cache".
- **Exact Numeric Opacities & Constants**: Do NOT mention specific code values like `0.84`, `0.12`, or `0.15` opacity tokens. Use terms like "harmonized translucent contrast" or "refined border outlines".
- **Internal Scripts & Tooling**: Do NOT reference internal maintenance tools like `<tool name>.py`.
- **Quoted Text Strings / UI Labels**: Avoid quoting exact code string literals (e.g. `"More Info"`, `"Sharing your trip status"`). Describe the functional feature instead.

---

## Execution Protocol

### Step 1: Discover Source Release Notes & Existing Listings

1. Locate the source release note in the target app repository's `.commits/` directory, checking `.commits/<version>.md` first and falling back to legacy `.commits/<version>.txt` if no `.md` note exists.
2. Locate the workspace's `<listings repo>/app-listings/` directory and inspect existing `<app>-*-listing.md` files (especially recent prior releases and any existing file for `<version>`) so nothing from an already-listed release is duplicated.
3. Read the full source release note to extract the release date, version, and distinct user-facing changes (filtering out internal refactors, tests, tooling, and admin-only changes).

### Step 2: Synthesize & Abstract Features

1. Group distinct user-facing changes by broad domain (trip dispatch, real-time tracking, visual design & accessibility, payments/auth, safety/support, performance & reliability) and separate Android-specific, iOS-specific, and shared items.
2. Classify each item as `(new)` (newly introduced capability or safeguard) or `(improved)` (refinement, fix, or enhancement to existing behavior).
3. Distill each distinct change into one concise, abstract user-benefit sentence obeying all abstraction guardrails.

### Step 3: Format Output

1. List the exact count of distinct user-facing bullets per platform (`(1 point)` or `(<N> points)`), with no padding and no duplicate items.
2. Format every bullet strictly as `- <Short Feature Title> (new|improved): <Concise user-facing benefit sentence.>`.
3. Verify the document contains zero technical identifiers, metrics, constants, internal scripts, quoted UI labels, or changes already covered by earlier listings.

### Step 4: Write Listing File

Write the final formatted Markdown file directly to `<listings repo>/app-listings/<app>-<version>-listing.md`.
