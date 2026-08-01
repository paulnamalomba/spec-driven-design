---
name: create-commit-notes
description: Creates detailed, technical release/commit notes in the .commits directory for ecoride repositories, tracking version progression, technical changes, git diff baseline, code files touched, compatibility, and validation.
---

# Skill: Commit Notes Creation

## Overview

This skill standardizes the creation of technical `.commits` release notes for all repositories across the Ecoride platform (including `ecoride_driver`, `ecoride_rider`, `ecoride`, `ecoride_admin`, and `ecoride_website`).

---

## Repositories & Version Sequences

- **ecoride_driver** (e.g. `1.0.10.26` -> `1.0.10.27` -> ... -> `1.0.21.73`)
- **ecoride_rider** (e.g. `1.0.12.25` -> `1.0.12.26` -> ... -> `1.0.32.74`)
- **ecoride** (e.g. `0.92.7-alpha` -> `0.93.6-alpha` -> ... -> `0.97.4-alpha`)
- **ecoride_admin** (e.g. `0.9.1.2` -> `0.9.2.0` -> ... -> `0.9.7.5` -> `0.9.7.6`)
- **ecoride_website** (e.g. `1.0.2.0` -> `1.0.3.0`)

---

## Execution Protocol

### Step 1: Discover Baseline & Git Diff Scope
1. Locate the `.commits/` directory in the target repository.
2. Determine the previous documented version / release tag (e.g. `0.9.7.5`).
3. Compute the git diff baseline against the previous tag:
   ```bash
   git diff <previous_tag> -- . ':(exclude).commits/**'
   git status --short
   ```
4. Extract the exact file insertions, deletions, modified files, and untracked files.

### Step 2: Content & Technical Depth Requirements
- Notes must be highly technical and detailed, documenting exact function signatures, state hooks, components, API endpoints, DTO interfaces, CSS classes, and architectural rationale.
- Do not abstract or summarize away technical detail; preserve explicit symbol names, line changes, and precise behaviors.
- Match existing `.commits/<version>.txt` styling and layout formatting established in the target repository.

### Step 3: Standard Section Structure
Each release note file follows this structural layout:

1. **Header & Release Metadata:**
   ```text
   Ecoride <Repo> v<Version> Release Notes
   Release Date: <Date>
   ====================================

   MAJOR CHANGES
   =============

   ## [<Version>] - <YYYY-MM-DD>
   ```

2. **Diff Baseline:**
   - Previous documented version and release tag.
   - Release scope command (`git diff <tag> -- . ':(exclude).commits/**'` and `git status --short`).
   - Effective runtime scope (file count, insertions, deletions).
   - Version mapping progression.

3. **Detailed Technical Sections:**
   - Subsections for each major feature added, modified, or refactored.
   - Specific details on state management, API routes, type interfaces, user interface elements, and edge-case handling.

4. **Code Files Touched:**
   - Categorized listing of all modified and newly created files with file paths and domain responsibilities.

5. **Compatibility and Deployment Notes:**
   - Database migrations, API contract compatibility, route paths, environment variables, role checks, and deployment considerations.

6. **Validation Performed:**
   - Empirical build results (`npm run build`, `tsc`, `vite build`), module transformations, ESLint checks, type-checking, and operational verification.

---

## File Naming & Output Location

- Output path: `.commits/<version>.txt` (e.g. `.commits/0.9.7.6.txt`) in the target repository root.
