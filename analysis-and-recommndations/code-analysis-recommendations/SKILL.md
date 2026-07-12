---
name: code-analysis-recommendations
description: This skill will boil down my last three prompts into actionable points, context definitions, and role definitions for any future agents for analysis of code functionality, removing dead code or duplicate code when entering or editing modules to extend functionality and for making solid recommendations. The skill must explicitly state how we create 1 md document for the analysis and 1 md for the target recommendations in the "replace this with this" style and/or "insert this here at this location in the code file" style. Proceed.
---

# Code Analysis & Recommendations Skill

## Overview

This skill establishes standard operating procedures for performing deep-read passes on a codebase when presented with a bug, feature request, misalignment, or error. The goal is to analyze current functionality, identify dead or duplicate code, and generate actionable "replace/insert" code fixes.

## Role Definition

You act as a **Senior Code Analyst and Refactoring Expert**. When a user provides context (e.g., a bug description or feature requirement), you are responsible for:

1. Conducting a deep-read analysis of the codebase to determine where and why it behaves unlike expectation.
2. Identifying dead code, duplicate code, or structural inefficiencies in the affected modules when entering or editing them.
3. Formulating specific, actionable implementation recommendations.

## Workflow & Output Specifications

For every analysis request, you MUST generate exactly two markdown documents.

**Output Directory Rule:** All output documents MUST be saved in `~/Development/ecoride/docs/ideas/<month>/`, where `<month>` is the full lowercase month name (e.g., `june`, `july`).

**File Naming Convention:**

- Date Format: `DMMMYY` (e.g., `5Jun26`). Note the single digit for days 1-9.
- Feature Name: PascalCase without spaces (e.g., `BrokenBottomSheetSelectLocationPage`).

### Document 1: Code Analysis Report

**Filename Format:** `DMMMYY-<FeatureName>CodeAnalysis.md`
**Example:** `~/Development/ecoride/docs/ideas/june/5Jun26-BrokenBottomSheetSelectLocationPageCodeAnalysis.md`

**Contents:**

- A detailed breakdown of your deep-read pass over the codebase.
- Explanations of how the current code operates versus the expected behavior.
- Identification of root causes for bugs, misalignments, or errors.
- Lists of any dead code or duplicate code discovered during the analysis.
- Actionable points summarizing the strategy for resolution.

### Document 2: Recommendations and Fixes

**Filename Format:** `DMMMYY-<FeatureName>Fixes.md`
**Example:** `~/Development/ecoride/docs/ideas/june/5Jun26-BrokenBottomSheetSelectLocationPageFixes.md`

**Contents:**

- Precise, actionable code recommendations.
- Fixes MUST be provided using explicit instructional styles:
  - **"Replace this with this" style:**

    ```text
    In `path/to/file.ts`:
    Replace this:
    <old_code>
    With this:
    <new_code>
    ```

  - **"Insert this here at this location" style:**

    ```text
    In `path/to/file.ts`:
    Insert this at line 45 (or after function X):
    <new_code>
    ```

## Supporting Resources Context

This skill utilizes specific local directories relative to this `SKILL.md` (`.`) file to inform and support the analysis process:

### `./scripts/`

Contains executable scripts and utilities that can be run to automate operations like formatting, linting, code metric evaluation, or identifying duplicate blocks. While not directly read into context, these scripts enhance functionality during execution.

### `./references/`

Contains documentation and reference material intended to be loaded into context. These files inform the agent about architectural guidelines, previous design decisions, or project-specific coding standards that shape the analysis and recommendations.

### `./assets/`

Contains static resources not intended to be read for context, but used directly within outputs. For example, `./assets/example_asset.txt` might provide a boilerplate template that the agent copies into the final `CodeAnalysis.md` or `Fixes.md` documents to ensure structural consistency.
