---
name: create-substream-work-summary
description: Generates standardized technical substream work summary markdown files in the docs/work directory following the exact DDbbYY-substream<NN>-work-to-<reponame>-<branchname>.md naming convention without duplicate files.
---

# Skill: Substream Work Summary Generator

## Overview

This skill standardizes the creation of technical substream work summary documents across all repositories (e.g. `afriflex`, `afriflex-webapp`, `afriflex-admin`, `afriflex-contracts`, `afriflex-ussd`).

---

## File Naming & Output Protocol

When invoked, the skill requires a **Substream Number** (integer `N` >= 1).

### Formatting Rules:
1. **Date (`DDbbYY`)**: 2-digit day, 3-letter lowercase month abbreviation, 2-digit year (e.g. `07aug26` for August 7, 2026).
2. **Substream Tag (`substream<NN>`)**: Substream number with leading zero if less than 10 (e.g. `substream01`, `substream02`, `substream12`).
3. **Repo Name (`<reponame>`)**: Name of the target repository folder or git root (e.g. `afriflex-webapp`, `afriflex-admin`, `afriflex`).
4. **Branch Name (`<branchname>`)**: Active git branch returned by `git branch --show-current` (e.g. `main`, `dev`, `feature-sacco`).

### Strict Target Save Path:
```text
docs/work/DDbbYY-substream<NN>-work-to-<reponame>-<branchname>.md
```
*(e.g. `docs/work/07aug26-substream01-work-to-afriflex-webapp-main.md`)*

> [!IMPORTANT]
> **No Duplicates Policy**: Save ONLY to the single canonical file name `docs/work/DDbbYY-substream<NN>-work-to-<reponame>-<branchname>.md`. Do NOT generate alternative or duplicate filenames.

---

## Execution Protocol

### Step 1: Discover Environment & Git Baseline
1. Determine active repository name and directory root (`pwd` / basename).
2. Query active branch name:
   ```bash
   git branch --show-current
   ```
3. Capture git status and uncommitted / committed diff for the substream:
   ```bash
   git status --short
   git diff
   ```
4. Capture the complete tracked patch for every path in the touched-files matrix:
   ```bash
   git diff --full-index --binary HEAD -- <path-1> <path-2> ...
   ```
5. For every untracked touched file, append its complete addition patch:
   ```bash
   git diff --no-index --full-index --binary /dev/null <untracked-file>
   ```
   `git diff --no-index` normally exits `1` when differences exist; that exit is
   expected and does not mean generation failed.
6. Verify the finished Markdown contains one `diff --git` entry for every
   touched source/config/test file and contains no placeholder such as `...`,
   `diff summary`, or `reproduce with` in place of code.

### Step 2: Structure & Technical Detail Requirements
Each substream work document must follow this standard markdown structure:

1. **Document Title & Metadata Table**:
   - Substream ID, Date, Target Repo, Active Branch, Author/Agent, Verification Status.
2. **Executive Summary**:
   - High-level overview of features, API integrations, UI components, and architectural refactoring performed.
3. **Detailed Technical Breakdown**:
   - Explanations of modified functions, new state hooks, input formatters, exception mappings, and styling keyframes.
4. **Touched Files Matrix**:
   - Table of created and modified files with full relative paths and descriptions.
5. **Git Diff Baseline**:
   - Full, verbatim, line-by-line code diff formatted inside a fenced `diff`
     block.
   - This is a durable code-review and future-reference artifact. The fenced
     block MUST contain the actual `diff --git`, `index`, `---`, `+++`, hunk
     headers, context, additions, and deletions for every file in the substream.
   - Include new/untracked files as complete `/dev/null` additions because
     ordinary `git diff` omits them.
   - Never substitute `git diff --stat`, a file/count table, conceptual
     before/after prose, representative hunks, ellipses, a reproduction command,
     or a reference to another document for the required full diff.
   - When a dirty working tree contains other work, scope the diff to every path
     listed in the substream's touched-files matrix. Preserve overlapping hunks
     in full and explain that overlap; do not silently omit lines from a shared
     file.
6. **Empirical Build & Verification Results**:
   - Command line verification output (`npm run build`, `dotnet test`, etc.).

---

## Output Directory Setup
Ensure `docs/work` directory exists before writing:
```bash
mkdir -p docs/work
```
