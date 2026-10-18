---
name: create-commit-notes
description: Create Markdown commit and release notes in .commits with source baselines, version progression, changes, compatibility, and actual validation. Supports Ecoride and independent PETSc, SESKA and frontend version profiles.
---

# Skill: Commit Notes Creation

## Overview

This skill standardizes technical `.commits` notes while preserving the target repository's own version policy. Ecoride, PETSc, SESKA and the frontend retain independent identities and note grouping.

## Select the repository profile

Read the target repository's `AGENTS.md`, existing notes, and authoritative version metadata first.

- For `petsc-native-windows`, or a repository explicitly declaring the same PETSc profile, read [PETSc internal versions and build progression](references/petsc-versioning.md). It overrides the Ecoride-specific templates and default filename rule below. Record the four-part `PETSC_INTERNAL_VERSION` in `.commits/<breaking>.<major>.<minor>.md`, preserving every verified build-number transition.
- For `seskafeabackend`/SESKA, read [SESKA internal versions](references/seska-versioning.md). Its independent `SESKA_INTERNAL_VERSION` starts at the user's historical `1.0.0.17`, not PETSc's seed. Preserve every accepted build transition in the three-part family note.
- For `seskafeafrontend`, read [frontend internal versions and releases](references/frontend-versioning.md). Its four single-digit fields and minor-family release policy are independent of PETSc/SESKA.
- For Ecoride repositories, retain the existing sequences and note conventions below. Do not impose PETSc's 3.27 internal family, bounded counters, or note grouping on them.
- For another repository, follow its declared policy and existing note format. Do not infer its version from a dependency or copy an unrelated product's release header.

Writing notes does not authorize a build, counter increase, commit, tag, or push. Record actual evidence and unchanged counters for unbuilt or failed work; never invent a passing build to make the note complete.

## Markdown output and historical notes

New notes and new entries use UTF-8 Markdown (`.md`), with real headings, tables, links and fenced command blocks. Do not wrap an entire note in a text code block or use ASCII underline headings. Preserve existing `.txt` notes and immutable evidence. Continue an active historical family in one `.md` file that links its frozen `.txt` predecessor and lists the earlier accepted transitions; append only to the Markdown continuation. Do not maintain two active copies or rewrite historical artifact paths/hashes.

Before migrating a repository whose acceptance/release tools require `.txt`, update its owned note-path readers to prefer `.md` with historical `.txt` read compatibility and its appenders to write Markdown. Preserve that repository's version arithmetic, remote, tag namespace and permission rules. This format migration does not change raw test logs, licences or solver outputs.

---

## Ecoride Repositories & Version Sequences

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
- Match the selected profile's note filename and the styling established in the target repository. PETSc notes use a three-part release-family filename and a complete fourth-field build progression inside it.

### Step 3: Standard Section Structure
Use this default layout for Ecoride. The PETSc profile defines its own scientific/build sections and progression records.

1. **Header & Release Metadata:**
   ```markdown
   # Ecoride <Repo> v<Version> release notes

   Release date: <Date>

   ## [<Version>] - <YYYY-MM-DD>

   ### Changes

   ### Validation

   ### Artifacts and remaining limits
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

- Default Ecoride output: `.commits/<version>.md` (e.g. `.commits/0.9.7.6.md`) in the target repository root.
- PETSc, SESKA and frontend output: `.commits/<breaking>.<major>.<minor>.md`, with full four-part versions and build transitions inside. Apply the selected profile's independent rules.
