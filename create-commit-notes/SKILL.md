---
name: create-commit-notes
description: Create Markdown commit and release notes in .commits with source baselines, version progression, changes, compatibility, and actual validation. Supports full technical notes or minimal abstract notes, and independent PETSc, SESKA, frontend, and Ecoride profiles.
---

# Skill: Commit Notes Creation

## Overview

This skill standardizes commit and release notes in `.commits/` while preserving the target repository's own version policy. It supports two distinct note styles:

1. **Full Notes** (default): Exhaustive, code-level engineering release notes documenting git diff baselines, code files touched, exact function signatures, state hooks, DTOs, schemas, compatibility, and execution logs.
2. **Minimal Notes** (optional): High-level, abstract updates designed to completely obscure all code, code file paths, git diff statistics, and raw SQL, aliasing variable and component names into natural language under clear change categories.

Ecoride, PETSc, SESKA, and frontend repositories retain independent identities, monotonic version arithmetic, and note grouping.

---

## Select the Note Mode

Choose the note mode based on the user's prompt or operational context:

- **Full Mode (Default)**: Generate comprehensive, deeply technical notes when creating standard engineering documentation, diff-grounded baselines, or internal audit trails.
- **Minimal Mode (Optional)**: Generate minimal abstract notes when the user specifies minimal mode (e.g. "minimal", "minimal notes", "abstract updates", "high-level notes", or `--minimal`), or when notes must obscure internal implementation details for executive summaries or external releases.
- **Dual Output**: When requested to produce both, output the full notes to the canonical note file (e.g. `.commits/<version>.md`) and the minimal notes to a companion file (e.g. `.commits/<version>.minimal.md`), or include the minimal section as an executive summary.

---

## Select the Repository Profile

Read the target repository's `AGENTS.md`, existing notes, and authoritative version metadata first.

- For `petsc-native-windows`, or a repository explicitly declaring the same PETSc profile, read [PETSc internal versions and build progression](references/petsc-versioning.md). It overrides Ecoride templates and default filename rules. Record `PETSC_INTERNAL_VERSION` in `.commits/<breaking>.<major>.<minor>.md`, preserving every verified build transition.
- For `seskafeabackend`/SESKA, read [SESKA internal versions](references/seska-versioning.md). Its independent `SESKA_INTERNAL_VERSION` starts at historical `1.0.0.17`. Preserve every accepted build transition in the three-part family note.
- For `seskafeafrontend`, read [frontend internal versions and releases](references/frontend-versioning.md). Its four single-digit fields and minor-family release policy are independent of PETSc/SESKA.
- For Ecoride repositories, retain the existing sequences and note conventions below.
- For another repository, follow its declared policy and existing note format.

Writing notes does not authorize a build, counter increase, commit, tag, or push. Record actual evidence and unchanged counters for unbuilt or failed work; never invent a passing build to make a note complete.

---

## Markdown Output and Historical Notes

New notes and new entries use UTF-8 Markdown (`.md`), with real headings, tables, links, and fenced command blocks. Preserve existing `.txt` notes and immutable evidence. Continue an active historical family in one `.md` file that links its frozen `.txt` predecessor and lists earlier accepted transitions; append only to the Markdown continuation.

---

## Execution Protocol

### Step 1: Discover Baseline & Git Diff Scope
1. Locate the `.commits/` directory in the target repository.
2. Determine the previous documented version or release tag (e.g. `0.9.7.5` or `1.4.1`).
3. Compute the git diff baseline against the previous tag:
   ```bash
   git diff <previous_tag> -- . ':(exclude).commits/**'
   git status --short
   ```
4. Extract the exact file insertions, deletions, modified files, and untracked files to ground the notes in verified changes.

### Step 2: Content & Technical Depth Requirements

#### In Full Mode (Default)
- Notes must be highly technical and detailed, documenting exact function signatures, state hooks, components, API endpoints, DTO interfaces, CSS classes, database migrations, and architectural rationale.
- Do not abstract or summarize away technical detail; preserve explicit symbol names, line changes, and precise behaviors.
- Include the complete git diff baseline, code files touched, compatibility notes, and detailed validation logs.

#### In Minimal Mode (Optional)
- Completely obscure all code, code file paths, git diff statistics, and raw SQL.
- Focus strictly on abstract, functional, and behavioral updates.
- **Alias variable and component names into natural language**: Avoid direct unparsed symbols in `PascalCase`, `camelCase`, `snake_case`, or dot-notation. For example, `QrArtifactRasterizer` becomes "QR Artifact Rasterizer", `HalfQR.QrEngine` becomes "HalfQR Engine", and `HalfQR.Cli` becomes "HalfQR CLI".
- Formulate bullet points as active, past-tense statements explaining what capability was introduced, altered, or corrected, and why.
- See [Minimal Notes Specification](references/minimal-notes.md) for full aliasing rules, before/after conversions, and reference templates.

---

## Standard Section Structures

### Structure A: Full Notes (Default Layout)

Use this layout for standard engineering release notes (or the scientific/build layout in [PETSc profile](references/petsc-versioning.md)):

1. **Header & Release Metadata:**
   ```markdown
   # <Product/Repo> v<Version> release notes

   Release date: <YYYY-MM-DD>

   ## [<Version>] - <YYYY-MM-DD>
   ```
2. **Diff Baseline:**
   - Previous documented version and release tag.
   - Release scope command (`git diff <tag> -- . ':(exclude).commits/**'` and `git status --short`).
   - Effective runtime scope (file count, insertions, deletions).
   - Version mapping progression.
3. **Detailed Technical Sections:**
   - Subsections for each major feature added, modified, or refactored.
   - Specific details on state management, API routes, type interfaces, user interface elements, and edge cases.
4. **Code Files Touched:**
   - Categorized listing of all modified and newly created files with file paths and domain responsibilities.
5. **Compatibility and Deployment Notes:**
   - Database migrations, API contract compatibility, route paths, environment variables, role checks, and deployment considerations.
6. **Validation Performed:**
   - Empirical build results (`npm run build`, `tsc`, `cargo test`, `dotnet build`), module transformations, lint checks, and operational verification.

---

### Structure B: Minimal Notes (Optional Layout)

Use this layout when minimal notes are requested:

1. **Header & Release Metadata:**
   ```markdown
   # <Product/Repo> [<Version>] - <YYYY-MM-DD>
   ```
2. **Added:**
   - Active past-tense bullets describing new features, CLI commands, curated assets, or helpers.
   - Example: `Added a verify-render command to HalfQR CLI so draft SVG and final PNG artifacts can be rendered, decoded, and written to disk from the same backend pipeline used by the product.`
3. **Changed:**
   - Active past-tense bullets describing modified workflows, preview logic, or configuration targeting.
   - Example: `Changed the builder preview flow to prefer the server draft once it is available, keeping the on-screen QR closer to the authoritative backend render.`
4. **Fixed:**
   - Active past-tense bullets describing resolved defects, geometry drift, or error handling.
   - Example: `Fixed the local preview matrix geometry to include the same quiet-zone padding used by the backend renderer, so preview placement no longer drifts away from the server-generated QR layout.`
5. **Removed / Deprecated** *(optional, only if applicable)*:
   - Retired capabilities, endpoints, or assets.
6. **Validation:**
   - High-level build and test commands (without machine-specific paths or noisy flags).
   - Abstract, human-readable verification confirmations.
   - Example:
     ```markdown
     dotnet build HalfQR.sln
     npm run build from webapp
     Verified the reported R2 PDF URL decodes successfully through the new CLI for PDF and Link renders without a logo
     Verified the same URL decodes successfully through the new CLI with the curated menu and scan-me preset logos applied
     ```

---

## File Naming & Output Location

- **Ecoride & Standard Repositories**:
  - Full notes: `.commits/<version>.md` (e.g. `.commits/0.9.7.6.md`).
  - Minimal notes (when standalone): `.commits/<version>.md` (or `.commits/<version>.minimal.md` if coexisting with full notes).
- **PETSc, SESKA and Frontend Repositories**:
  - Output file: `.commits/<breaking>.<major>.<minor>.md`. Full four-part internal version transitions and build progression are recorded inside. If minimal notes are requested for a family release, update or summarize the family note using the minimal format while maintaining monotonic counter truth.
