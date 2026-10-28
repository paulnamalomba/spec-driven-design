# Minimal Commit and Release Notes Specification

Use this reference when generating **minimal** commit or release notes (`create-commit-notes` in minimal mode).

Minimal notes provide clean, human-readable, abstract updates tailored for executive reviews, cross-functional stakeholders, and public release communications. They completely obscure internal code mechanics, raw file trees, diff numbers, and SQL statements while preserving clear architectural, functional, and operational truth.

---

## 1. Core Principles of Minimal Notes

1. **Zero Code Exposure**: Never output raw code snippets, syntax blocks, AST nodes, or internal expressions.
2. **Zero Code File Paths**: Do not reference source file paths, directory layouts, or file extensions (e.g. no `src/HalfQR.QrEngine/Rasterizer.cs`, `AppConstants.dart`, or `schema.sql`). Omit any "Code Files Touched" section.
3. **Zero Git Diff Statistics**: Omit line diff metrics (`+140 -25`), git hashes, patch hunks, or diff baseline tables.
4. **Zero Raw SQL / Database DDL**: Obscure all raw queries (`SELECT`, `INSERT`, `ALTER TABLE`, foreign keys, migrations). Describe data and schema updates in terms of functional domain capabilities.
5. **Mandatory Natural-Language Aliasing**: Never emit direct unparsed variable names, types, or symbols in `PascalCase`, `camelCase`, `snake_case`, or dot-separated namespace syntax. Translate every code identifier into clear, idiomatic English.
6. **Active, Outcome-Oriented Phrasing**: Each bullet must be an active, past-tense sentence explaining **what** was done and **why** (the user or system benefit).
7. **Empirical Validation**: Provide concise, clean build commands and clear human-readable verification statements describing verified outcomes.

---

## 2. Natural-Language Aliasing Rules

When writing minimal notes, parse and convert every technical identifier into its natural language equivalent:

| Technical Symbol / Pattern | Rule | Aliased Natural Language |
| --- | --- | --- |
| `HalfQR.QrEngine` | Namespace / Module | `HalfQR Engine` |
| `HalfQR.Cli` | CLI Project / Binary | `HalfQR CLI` |
| `QrArtifactRasterizer` | Class / Type (`PascalCase`) | `QR Artifact Rasterizer` |
| `PdfQrPayloadGenerator` | Class / Type (`PascalCase`) | `PDF QR Payload Generator` |
| `quietZonePadding` | Variable / Property (`camelCase`) | `quiet-zone padding` |
| `is_preset_watermark_enabled` | Flag / Variable (`snake_case`) | `preset watermark configuration` or `preset watermark flag` |
| `useBuilderPreview` | Hook / Function | `builder preview hook` or `builder preview flow` |
| `verify-render` | Subcommand | `verify-render command` |
| `ALTER TABLE qr_presets ADD COLUMN is_transparent BOOLEAN;` | SQL / Schema modification | `Updated database schema to support transparent watermark presets` |
| `src/HalfQR.QrEngine/Rasterizer.cs` | File Path | Obscured completely; describe subsystem: `in the HalfQR Engine` |
| `status_code == 422` | Error code check | `validation-style error response` |
| `auth_token_secret` | Secret / Config variable | `authentication token configuration` |

### General Aliasing Guidelines:
- **Acronyms & Standards**: Keep recognized standard acronyms capitalized and accessible (e.g. `SVG`, `PNG`, `QR`, `PDF`, `CLI`, `API`, `URL`, `R2`, `SDK`, `MPI`, `SQL`).
- **Composite Names**: Insert spaces between compound words in PascalCase/camelCase identifiers (e.g. `RenderPipeline` -> `render pipeline`, `PaymentWebhookHandler` -> `Payment Webhook Handler`).
- **Dot Syntax**: Drop intermediate namespaces or replace dots with descriptive words (e.g. `HalfQR.QrEngine.Rasterizer` -> `QR rasterizer in HalfQR Engine`).
- **Context over Syntax**: Focus on what the component *does* in domain terms rather than how it is declared in code.

---

## 3. Minimal Notes Structure

Every minimal note contains these concise sections:

### 3.1 Header & Version Metadata
```markdown
# <Product or Repository Name> [<Version>] - <YYYY-MM-DD>
```
*(For PETSc, SESKA, or frontend release families, preserve the family heading, e.g. `# PETSc Native Windows [3.27.0] - 2026-10-28`)*.

### 3.2 Change Categories
Use standard change categories. Omit any category that has no items for the release:

- **Added**: New features, CLI commands, curated assets, shared helpers, and capabilities.
- **Changed**: Modifications to existing workflows, preview logic, priority fallbacks, configurations, or UI presentation.
- **Fixed**: Bug fixes, geometric alignment drift, error message clarifications, crash resolutions, and edge-case handling.
- **Removed** *(or **Deprecated**)*: Retired features, deprecated endpoints, or obsolete assets.

### 3.3 Validation
High-level build commands and human-readable verification confirmations:
- Standard build commands without machine-specific paths or noisy verbose flags (e.g. `dotnet build HalfQR.sln`, `npm run build from webapp`, `flutter test`).
- High-level statements explaining verified functional behavior and operational guarantees.

---

## 4. Reference Example

Below is the authoritative reference template for minimal notes:

```markdown
# HalfQR [1.4.2] - 2026-10-28

Added
- Added a verify-render command to HalfQR CLI so draft SVG and final PNG artifacts can be rendered, decoded, and written to disk from the same backend pipeline used by the product.
- Added curated transparent SVG preset watermark assets for Scan Me, Link, Menu, and WhatsApp so preset logos no longer depend on brittle raster background removal.
- Added a shared QR Artifact Rasterizer helper in HalfQR Engine so SVG-to-PNG conversion is reusable across render validation and production rendering flows.

Fixed
- Fixed the local preview matrix geometry to include the same quiet-zone padding used by the backend renderer, so preview placement no longer drifts away from the server-generated QR layout.
- Fixed the preset watermark path that could produce opaque or blackout center logos by switching the builder to transparent SVG presets.
- Fixed draft render failures surfacing as opaque server errors by returning a validation-style message when payload encoding cannot be completed.

Changed
- Changed the builder preview flow to prefer the server draft once it is available, keeping the on-screen QR closer to the authoritative backend render.
- Changed the preview summary to show whether the builder is currently targeting a local API or the hosted API, removing ambiguity during render debugging.

Validation
- dotnet build HalfQR.sln
- npm run build from webapp
- Verified the reported R2 PDF URL decodes successfully through the new CLI for PDF and Link renders without a logo
- Verified the same URL decodes successfully through the new CLI with the curated menu and scan-me preset logos applied
```

---

## 5. Comparison: Full Notes vs. Minimal Notes

To understand the transformation required when switching from Full to Minimal mode, compare how the same technical change is documented:

| Dimension | Full Notes Mode (Default) | Minimal Notes Mode (Optional) |
| --- | --- | --- |
| **Audience** | Core engineers, code reviewers, compliance auditors | Executive stakeholders, product managers, release announcements |
| **File Paths** | Lists explicit paths (`src/QrEngine/QrArtifactRasterizer.cs`) | Completely omitted (no file paths) |
| **Git Diff Baseline** | `git diff 1.4.1 -- .` (+312, -45 across 8 files) | Completely omitted (no diff tables or metrics) |
| **Variable Names** | Raw code tokens (`quietZonePadding`, `HalfQR.QrEngine`) | Natural language aliases (`quiet-zone padding`, `HalfQR Engine`) |
| **SQL & Migrations** | Raw SQL: `ALTER TABLE presets ADD COLUMN is_transparent BOOLEAN;` | Natural update: `Updated database schema to support transparent watermark presets` |
| **Validation Details** | Full compiler output, CLI exit codes, raw assertion dumps | High-level build commands and verified functional bullet statements |
| **Structure** | Diff Baseline, Detailed Technical Sections, Code Files Touched, Compatibility & Deployment, Validation Performed | Added, Changed, Fixed, [Removed], Validation |

---

## 6. Interaction with Repository Profiles

Regardless of whether notes are written in **Full** or **Minimal** mode:
1. **Version progression rules remain binding**: Minimal notes do NOT relax counter increments, candidate reservations, or zero-advance rules on failed/unbuilt work.
2. **Monotonic progression**: A minimal note cannot invent a passing build. If a build did not qualify, the minimal note records that no version advance occurred.
3. **Repository note conventions**:
   - For Ecoride repositories: writes to `.commits/<version>.md` (or `.commits/<version>.minimal.md` if both modes are generated).
   - For PETSc, SESKA, and frontend repositories: minimal notes fit within the three-part family file `.commits/<breaking>.<major>.<minor>.md` or a requested standalone minimal summary, while honoring the authoritative counter.
