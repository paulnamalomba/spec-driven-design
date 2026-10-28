# spec-driven-design

[![Skills](https://img.shields.io/badge/skills-47-blue)](#skills)
[![Format](https://img.shields.io/badge/format-SKILL.md-2ea44f)](#package-layout)

My working set of agent skills. Each folder holds a `SKILL.md` that tells a coding agent (Codex, Claude Code, or anything else that reads the format) how to do one job: write an SRS from an existing codebase, audit a subsystem, draft release notes, tidy a Dockerfile, design a dashboard, and so on.

Nothing here runs on its own. There is no app, build, or install step. An agent reads the skill and applies it to some other repository or document.

Most skills were written for Ecoride and Afriflex work. Several still carry those assumptions; see [Project-specific skills](#project-specific-skills) before reusing one elsewhere.

## Contents

- [Skills](#skills)
- [How the skills fit together](#how-the-skills-fit-together)
- [Installing a skill](#installing-a-skill)
- [Writing a good request](#writing-a-good-request)
- [Common chains](#common-chains)
- [Package layout](#package-layout)
- [Repository layout](#repository-layout)
- [Project-specific skills](#project-specific-skills)
- [Third-party skills](#third-party-skills)
- [Writing or changing a skill](#writing-or-changing-a-skill)
- [Ground rules](#ground-rules)
- [Checking the repo](#checking-the-repo)
- [Other files](#other-files)
- [License](#license)
- [Author](#author)

## Skills

### Specifications and architecture

| Skill | Use it when | Output |
| --- | --- | --- |
| [`create-specifications-existing-projects`](create-specifications-existing-projects/SKILL.md) | An existing system needs an SRS based on what its repositories actually do. | An SRS with requirement IDs, source evidence, implementation status, acceptance criteria, security, operations, gaps, and a glossary. |
| [`merge-customer-journeys-into-specifications`](merge-customer-journeys-into-specifications/SKILL.md) | Customer journeys, user flows, or service blueprints need to be merged into an existing SRS. | An updated SRS, a requirements addendum, a journey-to-requirement traceability matrix, or some mix of these. |
| [`create-technical-architecture`](create-technical-architecture/SKILL.md) | Requirements, design analysis, and source code need to become one architecture document. | `docs/architecture/SYSTEM_ARCHITECTURE_AND_DESIGN.md` with diagrams, trade-offs, security, data flow, and operations. |
| [`low-level-systems`](low-level-systems/SKILL.md) | Designing, architecting, or reviewing systems programming, embedded kernels, HPC paths, custom allocators, or hardware/OS interfaces. | Architecture specifications, memory layouts, hot-path analysis, and mechanical sympathy review notes. |
| [`codebase-design`](codebase-design/SKILL.md) | Designing deep modules, interface boundaries, finding deepening seams, or making code more testable and AI-navigable. | Deep-module interface specifications, seam definitions, and boundary design notes. |
| [`whiteboard`](whiteboard/SKILL.md) | Visualizing code, authoring architecture walkthroughs for branches/PRs, drawing on the scratchpad, or researching session history. | Visual diagrams, scratchpad artifacts, and architecture walkthroughs in the Whiteboard interface. |

### Analysis and audits

| Skill | Use it when | Output |
| --- | --- | --- |
| [`code-analysis-recommendations`](analysis-and-recommndations/code-analysis-recommendations/SKILL.md) | A bug, feature, or structural problem needs a close read before anyone edits code. | Two documents: an analysis report and a fixes document written as "replace this with this" and "insert this here" instructions. |
| [`deep-code-and-security-audits`](deep-code-and-security-audits/SKILL.md) | A subsystem needs a security, integration, code quality, and performance review. | Three dated reports in `$outputdir`: `SecurityAudit`, `IntegrationAudit`, `CodeQualityAudit`. |
| [`code-review`](code-review/SKILL.md) | Reviewing changes since a commit, branch, tag, or merge-base along two axes: Standards and Spec adherence. | Side-by-side parallel subagent reports evaluating repository standards compliance and specification matching. |
| [`ux-system-analyzer`](ux-system-analyzer/SKILL.md) | Screenshots and UI source need to be checked against the design system. | Two dated reports under `$outputdir/docs/code/`: the UX analysis and the recommended changes. |
| [`optimize-docker-builds`](optimize-docker-builds/SKILL.md) | Docker builds are slow, contexts are large, dependency restores repeat, or runtime images carry build tools. | Rewritten Dockerfiles, `.dockerignore` files, and Compose/CI build changes, with before/after timings from `scripts/benchmark_docker_build.sh`. |
| [`research`](research/SKILL.md) | A technical question, API fact, or official documentation needs deep primary-source investigation via a background agent. | A single cited Markdown file placed in the repository's notes directory. |

### Frontend and UI design

| Skill | Use it when | Output |
| --- | --- | --- |
| [`impeccable`](impeccable/SKILL.md) | Designing, redesigning, critiquing, or polishing any frontend: sites, product UI, forms, onboarding, empty states. | UI changes driven by sub-commands (`critique`, `audit`, `polish`, `harden`, `animate`, `colorize`, and more), plus `PRODUCT.md` / `DESIGN.md` context files. Ships its own helper agents and a live-browser script. |
| [`design-taste-frontend`](design-taste-frontend/SKILL.md) | Building or redesigning a landing page, portfolio, or editorial site that shouldn't look like a template. | A one-line design read, then the page, checked against a pre-flight list. |
| [`dashboard-design`](dashboard-design/SKILL.md) | Designing or reviewing operations, finance, logistics, seller, or analytics dashboards. | A short design decision list, the dashboard, and evidence that it was checked in the running app at several viewport widths. |
| [`dense-dashboard-design`](dense-dashboard-design/SKILL.md) | Designing information-dense dashboards, admin consoles, complex data tables, KPI blocks, and real-time status indicators. | High-density layout blueprints, data table recipes, KPI grids, and responsive views. |
| [`frontend-design`](frontend-design/SKILL.md) | Directing distinctive, intentional visual design for new or reshaped interfaces that avoid generic or templated defaults. | Aesthetic direction notes, typography and layout decisions, and distinctive UI source implementation. |
| [`stitch-ui-design`](stitch-ui-design/SKILL.md) | Generating or iterating UI layouts and design systems with Google Stitch AI design tool. | Specificity-crafted Stitch prompts, variants, and design-to-code workflows. |
| [`pretty-mermaid`](pretty-mermaid/SKILL.md) | You have Mermaid source, or need a flowchart, sequence, state, class, ER, or XY diagram drawn. | Themed SVG, PNG, or ASCII/Unicode output, rendered locally with the bundled Node scripts. 15 built-in themes. |
| [`bento-board-ui`](bento-board-ui/SKILL.md) | Brand assets or a website need to be showcased as a clean, share-ready bento grid for pitches or case studies. | A single presentation frame composed of raster image tiles and consistent spacing. |
| [`better-interface`](better-interface/SKILL.md) | An entire interface needs a holistic review across hierarchy, spacing, typography, keyboard navigation, and interaction states. | A consolidated, prioritized review verdict with actionable UX improvements. |
| [`desktop-to-mobile`](desktop-to-mobile/SKILL.md) | A selected desktop frame needs to be adapted into a 390px mobile version following responsive best practices. | A new mobile frame placed alongside the untouched desktop frame. |
| [`find-animation-opportunities`](find-animation-opportunities/SKILL.md) | A codebase or UI needs to be swept for tasteful motion opportunities with restraint. | A restrained list (5–7 maximum) of motion recipes with exact durations and easings; no code edits. |
| [`professional-cae-fem-gui-principles`](professional-cae-fem-gui-principles/SKILL.md) | Designing, architecting, or reviewing Dear ImGui desktop apps for FEM/FEA, CAD/CAE tools, or scientific visualization. | Viewport, mesh quality, and workbench interaction specifications (with SESKA FEA suite profile). |
| [`brag`](brag/SKILL.md) | You want to turn the current project website or app into a short, polished, shareable launch video using Hyperframes. | A project-tailored video storyboard and Hyperframes script/code. |

### Docs, releases, and maintenance

| Skill | Use it when | Output |
| --- | --- | --- |
| [`convert-docx-to-md`](convert-docx-to-md/SKILL.md) | A `.docx` has to become Markdown without losing headings, tables, formatting, or images. | A snake_case `.md` file plus a folder of extracted media next to it. |
| [`create-commit-notes`](create-commit-notes/SKILL.md) | A repo needs commit or release notes (full technical notes or optional minimal abstract notes). | `.commits/<version>.md` with full technical sections or minimal abstract updates (Added, Changed, Fixed, Validation). |
| [`create-release-listing-summaries`](create-release-listing-summaries/SKILL.md) | An Ecoride mobile app needs store listing text written from its commit notes. | `builds/<app>-<version>-listing.md` with 5 Android points and 12 iOS points, no low-level code detail. |
| [`create-substream-work-summary`](create-substream-work-summary/SKILL.md) | A piece of parallel work (a "substream") needs a write-up for its target repo and branch. | One file at `docs/work/DDbbYY-substream<NN>-work-to-<reponame>-<branchname>.md`, never duplicated under another name. |
| [`comment-out-non-performant-scalers`](comment-out-non-performant-scalers/SKILL.md) | A Flutter app already scales text at the theme root, and widget-level `fontSize: AppConstants.scaledFontSize(...)` calls should be disabled. | Targeted Dart edits, a ledger of every occurrence, a scoped diff review, then format, analyze, and test runs. |
| [`humanize`](humanize/SKILL.md) | Removing robotic AI writing patterns, ChatGPT filler, and unnatural phrasing from commit messages, PRs, docs, and notes. | Natural, human-written text stripped of AI mannerisms and structural slop. |
| [`docs`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/docs/SKILL.md) | Creating, editing, or collaborating on shared documents (reports, proposals, PRDs, SOPs) via the docs connector. | Structured collaborative documents exportable to Word, PDF, Markdown, or Google Docs. |
| [`docx`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/docx/SKILL.md) | Creating, reading, editing, or manipulating Microsoft Word `.docx` documents or templates. | Updated or generated `.docx` files with preserved formatting, styles, and tracked changes. |
| [`google-workspace`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/google-workspace/SKILL.md) | Creating or editing Google Docs, Sheets, Slides, or Drive files via connector APIs. | Updated Google Workspace files modified directly in Google Drive. |
| [`pdf`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/pdf/SKILL.md) | Extracting text/tables, merging, splitting, watermarking, filling forms, or OCR processing PDF files. | Processed, extracted, or newly generated PDF documents and form data. |
| [`pptx`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/pptx/SKILL.md) | Creating, editing, parsing, or analyzing PowerPoint (`.pptx`/`.potx`) slide decks and speaker notes. | Formatted `.pptx` presentations, slide templates, or extracted deck content. |
| [`xlsx`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/xlsx/SKILL.md) | Creating, reading, cleaning, computing formulas for, or updating Excel (`.xlsx`/`.csv`) spreadsheets. | Spreadsheets with formulas and formatting verified via `openpyxl` or `pandas`. |

### Agent behavior

| Skill | Use it when | Output |
| --- | --- | --- |
| [`caveman`](caveman/SKILL.md) | You want shorter agent replies with all technical detail kept. | No files. Changes how the agent writes until told "stop caveman" or "normal mode". |
| [`chief-of-staff`](chief-of-staff/SKILL.md) | Pursuing a long-running goal across a session by coordinating background subagents and schedules. | Subagent task delegations, context pointers, and strategic schedule management. |
| [`find-skills`](find-skills/SKILL.md) | Discovering and installing relevant skills from agent registries based on user tasks or intent queries. | Recommendations of matching skills, installation instructions, and trigger commands. |
| [`grilling`](grilling/SKILL.md) | Stress-testing a plan, decision, or idea through a relentless interview mapped as a design tree. | Multi-round frontier questions with recommended answers to settle prerequisite decisions. |
| [`grill-me`](grill-me/SKILL.md) | You want a fast shortcut to start a relentless interview (`grilling`) to sharpen a plan. | Interactive stress-testing interview session. |
| [`grill-with-docs`](grill-with-docs/SKILL.md) | Stress-testing a plan while capturing architectural decisions and domain models as you go. | Interview answers plus generated ADRs and glossary documentation. |
| [`implement`](implement/SKILL.md) | Implementing a feature or bug fix from a specification or tickets using TDD and code review loops. | Code changes backed by regular typechecking, tests, and review feedback. |
| [`import-memory`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/import-memory/SKILL.md) | Importing memories exported from another AI assistant (ChatGPT, Gemini) into Claude's memory store. | Conversationally filed memory entries stored using memory tools. |
| [`morning`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/morning/SKILL.md) | You want a calm, single-page morning overview of your schedule and priorities. | A hand-sketched, single-file HTML morning brief artifact or scheduled recurring brief. |
| [`skill-creator`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/skill-creator/SKILL.md) | Creating, editing, benchmarking, or optimizing agent skills and evaluating trigger accuracy. | Validated `SKILL.md` packages, test prompts, and eval benchmark reports. |

## How the skills fit together

Each skill does one job and stops. They're meant to be chained, not merged into one big prompt:

```text
Source repos + business docs + screenshots
                    │
                    ▼
          Discovery and evidence
                    │
         ┌──────────┴──────────┐
         ▼                     ▼
  Existing-system SRS    Code / UX analysis
         │                     │
         ▼                     ▼
  Journey merge          Targeted fixes
         │                     │
         └──────────┬──────────┘
                    ▼
        Technical architecture
                    │
                    ▼
       Approved implementation
                    │
                    ▼
   Validation, audit, release notes
```

Where the lines are drawn:

- SRS skills describe requirements. They don't implement them.
- Audits list risks and fixes. They aren't permission to rewrite the target.
- `code-analysis-recommendations` writes exact edits for someone else to apply later.
- Some skills do edit source: `comment-out-non-performant-scalers` (one exact Dart pattern only), `optimize-docker-builds` (build files only), and the three frontend design skills.
- `create-commit-notes` documents a release. It doesn't commit, tag, or push.

## Installing a skill

Clone the repo and list what's in it:

```bash
git clone https://github.com/paulnamalomba/spec-driven-design.git
cd spec-driven-design
rg --files -g 'SKILL.md' | sort
```

Agents look for skills in their own folder: `~/.codex/skills/<name>/` for Codex, `~/.claude/skills/<name>/` for Claude Code (and AGY via `~/.gemini/config/skills`). Symlink the ones you want rather than copying, so edits here take effect:

```bash
mkdir -p "$HOME/.codex/skills"
ln -s "$PWD/create-technical-architecture" \
  "$HOME/.codex/skills/create-technical-architecture"
```

Or automate symlinking using the shell function `linkreposkills` (in `~/.zshrc`):

```bash
# Link all missing skills from this repo to ~/.codex/skills
linkreposkills

# Link specific skills (backs up existing directories before symlinking)
linkreposkills dense-dashboard-design code-review frontend-design

# Link into repo-scoped <repo>/.codex/skills instead of global
linkreposkills --local
```

`ln -s` fails if the destination already exists. That's on purpose. Look at the installed copy and reconcile it by hand instead of overwriting it (or let `linkreposkills` create timestamped backups).

If you copied instead of linking, the installed version can drift. Compare before trusting it:

```bash
cmp create-technical-architecture/SKILL.md \
  "$HOME/.codex/skills/create-technical-architecture/SKILL.md"
```

`pretty-mermaid` needs `npm install` inside its folder before its render scripts work.

## Writing a good request

Name the skill, point at the inputs, and say where the output goes:

```text
$create-specifications-existing-projects

Inspect ~/Development/example-api, ~/Development/example-web, and
~/Development/example-admin. Write the SRS to
~/Development/example-contracts/docs/specifications/. Treat unbuilt
admin modules as planned gaps and cite a source file for every implemented claim.
```

```text
$merge-customer-journeys-into-specifications

Merge docs/journeys/member-purchase.md into docs/specifications/SRS.md.
Keep existing requirement IDs, add a traceability matrix, and mark
commercial conflicts as Requires Decision.
```

```text
$optimize-docker-builds

The API image takes 6 minutes to rebuild after a one-line change. Look at
api/Dockerfile and docker-compose.yml, time one build first, and don't
change runtime behavior.
```

```text
$create-commit-notes

Create .commits/1.2.0.txt from the previous tag. Include the diff baseline,
untracked release files, compatibility, deployment order, and which
commands passed or failed. Don't commit or push.
```

The useful result is usually a file in the target project, not the chat reply. Read that file and check:

- every claim traces back to a source file or requirement;
- assumptions and open decisions are listed, not buried;
- the list of changed files or recommendations is complete;
- security and privacy effects are covered;
- validation commands and their real results are stated; and
- the file landed where the skill says it should.

## Common chains

### Documenting an existing product

1. `convert-docx-to-md` to turn a Word spec or journey into Markdown.
2. `create-specifications-existing-projects` for a current-state SRS.
3. `merge-customer-journeys-into-specifications` to fold the journeys in.
4. `create-technical-architecture` for the architecture document.
5. `deep-code-and-security-audits` once the work is built.

### Fixing UI drift

1. `ux-system-analyzer` with screenshots and the UI repo.
2. `code-analysis-recommendations` where one problem needs a deeper trace.
3. Approve the recommendations before anyone edits code.
4. `impeccable` (`polish`, `harden`, `audit`) or `dashboard-design` to make and check the changes.
5. Run the target repo's own lint, tests, build, and visual checks.

### Flutter font scaling

1. Confirm the Rider or Driver app scales text at the theme root.
2. Run `comment-out-non-performant-scalers` on the approved folder only.
3. Review the occurrence ledger and the diff.
4. Run the Flutter format check, analyzer, tests, and build.

### Shipping a release

1. Finish and validate the work in the target repo.
2. `create-commit-notes` against a pinned previous version.
3. `create-release-listing-summaries` for the store text (mobile apps).
4. `create-substream-work-summary` if the work ran as a separate substream.
5. Commit, tag, push, and deploy through your normal release process, not the skill.

## Package layout

```text
skill-name/
├── SKILL.md         # required: the instructions
├── agents/          # optional: openai.yaml UI metadata, helper agent definitions
├── references/      # docs the skill loads when needed
├── scripts/         # optional helper scripts
└── assets/          # templates and static files
```

Every `SKILL.md` starts with front matter:

```yaml
---
name: skill-name
description: When this skill should trigger, written so an agent can match it.
---
```

The body covers whatever applies: when to use it, the agent's role and limits, inputs, what to inspect first, what it may and may not change, the steps, output files and names, which references to load, and how to validate and report.

`agents/openai.yaml` holds a display name, short description, and default prompt. It helps discovery but `SKILL.md` wins if they disagree. `impeccable/agents/` also holds `.toml` definitions for its helper agents (documenter, asset producer, finish reviewer, manual edit applier).

Scripts help; they don't override a skill's rules.

## Repository layout

```text
spec-driven-design/
├── analysis-and-recommndations/
│   └── code-analysis-recommendations/   # SKILL.md, assets/, references/, scripts/
├── bento-board-ui/
├── better-interface/
├── brag/                                # assets/, references/, scripts/, slim.md
├── caveman/
├── chief-of-staff/                      # agents/
├── code-review/                         # agents/
├── codebase-design/                     # agents/, DEEPENING.md, DESIGN-IT-TWICE.md
├── comment-out-non-performant-scalers/  # agents/openai.yaml
├── convert-docx-to-md/
├── create-commit-notes/                 # references/
├── create-release-listing-summaries/
├── create-specifications-existing-projects/  # agents/, references/srs-structure.md
├── create-substream-work-summary/
├── create-technical-architecture/
├── dashboard-design/
├── deep-code-and-security-audits/
├── dense-dashboard-design/
├── design-taste-frontend/
├── desktop-to-mobile/
├── find-animation-opportunities/
├── find-skills/                         # symlink
├── frontend-design/
├── grill-me/                            # agents/
├── grill-with-docs/                     # agents/
├── grilling/                            # agents/
├── humanize/
├── impeccable/                          # agents/, reference/, scripts/
├── implement/                           # agents/
├── low-level-systems/
├── merge-customer-journeys-into-specifications/  # agents/, references/
├── optimize-docker-builds/              # agents/, references/patterns.md, scripts/
├── pretty-mermaid/                      # references/, scripts/, docs/, package.json
├── professional-cae-fem-gui-principles/ # references/
├── research/                            # agents/
├── stitch-ui-design/                    # (stitch-design symlink)
├── synced/
│   └── 125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/  # synced Anthropic skills (docs, docx, google-workspace, import-memory, morning, pdf, pptx, skill-creator, xlsx)
├── ux-system-analyzer/
├── whiteboard/                          # symlink
├── guides/
│   └── ssh_public_ip_setup.md
└── README.md
```

`analysis-and-recommndations` is misspelled. It stays that way because installed links point at it.

## Project-specific skills

Not everything here is generic.

| Skill | Assumes |
| --- | --- |
| `code-analysis-recommendations` | Writes to `~/Development/ecoride/docs/ideas/<month>/` with Ecoride naming. |
| `create-commit-notes` | Ecoride, PETSc, SESKA, frontend, or general repos and their `.commits` format (full or minimal mode). |
| `create-release-listing-summaries` | Ecoride mobile apps and the `builds/` folder. |
| `create-substream-work-summary` | The `docs/work/` folder and the `DDbbYY-substream<NN>-…` naming scheme. |
| `comment-out-non-performant-scalers` | A Flutter app with verified theme-root text scaling. |
| `create-specifications-existing-projects` | Generic, with extra notes on Afriflex repo roles. |
| `merge-customer-journeys-into-specifications` | Generic, with detailed Afriflex SACCO/BNPL and USSD rules. |
| `ux-system-analyzer` | Screenshots plus JSX/HTML/CSS/Tailwind source. |
| `create-technical-architecture` | Generic, pitched at the depth of the Ecoride architecture docs. |
| `deep-code-and-security-audits` | Generic. Its "100% coverage" claims only hold if the tools in the target environment can back them. |
| `professional-cae-fem-gui-principles` | Generic Dear ImGui CAE/FEM guidelines, plus a tailored SESKA FEA workbench profile. |

The rest (`convert-docx-to-md`, `optimize-docker-builds`, `impeccable`, `design-taste-frontend`, `dashboard-design`, `dense-dashboard-design`, `frontend-design`, `stitch-ui-design`, `pretty-mermaid`, `caveman`, `bento-board-ui`, `better-interface`, `brag`, `desktop-to-mobile`, `find-animation-opportunities`, `low-level-systems`, `codebase-design`, `whiteboard`, `code-review`, `research`, `grilling`, `grill-me`, `grill-with-docs`, `chief-of-staff`, `implement`, `find-skills`, `humanize`, and the synced skills) don't depend on a particular project.

To adapt a specialised skill, change the name, description, paths, examples, domain rules, and output contract together. A "generic" copy with Ecoride paths still inside is worse than the original.

## Third-party skills

Some skills came from elsewhere and keep their own licenses:

- `pretty-mermaid` is MIT (Beautiful-Mermaid Contributors). See [`pretty-mermaid/LICENSE`](pretty-mermaid/LICENSE).
- `dashboard-design` and `dense-dashboard-design` declare `license: MIT` in their front matter.
- `humanize` declares `license: MIT` in its front matter.
- `impeccable` ships its own scripts and version file (`impeccable/scripts/VERSION`).
- `whiteboard` is dev.fast Whiteboard (`devfast/packages/agent-plugins/pi/skills/whiteboard`).
- Synced skills under `synced/` are synced upstream skills (including Anthropic reference and productivity skills), retaining their respective licenses and manifests.

Check upstream before editing these heavily, or your changes will be hard to merge with new releases.

## Writing or changing a skill

1. Give it one job and a description that says when it should trigger.
2. Say whether it's read-only, writes documents, or edits source.
3. List the inputs, and the conditions that should make it stop.
4. Name the output files and say whether existing files are edited in place.
5. Make the agent look at the target repo before it concludes or edits anything.
6. Link only the references, scripts, and assets the job needs.
7. Ask for validation that fits the job, and honest reporting when it fails.
8. Try it on a real repo that has uncommitted changes.
9. Check that the installed copy matches this one.

Before you commit, check that:

- the folder name matches `name` in the front matter;
- paths to references and scripts are relative to `SKILL.md` and exist;
- output paths can't be confused with this repo;
- a read-only skill can't drift into editing code;
- destructive commands, secrets, and dirty worktrees are handled;
- examples use placeholders, not real credentials or production IDs;
- words like "complete" or "100%" are backed by something measurable;
- validation commands are chosen after looking at the target's toolchain; and
- `agents/openai.yaml`, if present, agrees with `SKILL.md`.

There's no version field or manifest. Git history is the record. If a change breaks a skill's output contract, say so in the commit message and update installed copies.

## Ground rules

These apply to every skill, including the documentation ones:

- Read any `AGENTS.md` (or `CLAUDE.md`) in the target repo first.
- Leave uncommitted changes alone and keep diffs to the task.
- Keep credentials, tokens, keys, production IDs, and personal data out of outputs.
- Client-side checks are UX, not security. Confirm enforcement on the server.
- Cite file paths, requirement sources, or Git baselines where the skill asks for traceability.
- Don't invent APIs, fields, status, test results, citations, or commands.
- If a tool can't prove an audit claim, narrow the claim and say why.
- Don't commit, tag, push, deploy, or open a PR unless the user asks for that separately.

## Checking the repo

There's no linter, test runner, or CI here, so don't report that any passed. What you can check:

```bash
# list skills
rg --files -g 'SKILL.md' | sort

# look at front matter
for file in $(rg --files -g 'SKILL.md'); do sed -n '1,5p' "$file"; done

# whitespace and scope
git diff --check
git status --short
```

Also open every relative link and every `references/`, `scripts/`, `assets/`, or `agents/` path a change adds, and make sure it exists. For `pretty-mermaid`, `npm test` in its folder runs the render smoke test.

## Other files

[`guides/ssh_public_ip_setup.md`](guides/ssh_public_ip_setup.md) is a Linux guide for OpenSSH, firewall rules, router port forwarding, SSH keys, turning off password login, and Fail2ban. It isn't a skill. If you can use a VPN or private network instead of exposing SSH to the internet, do that.

## License

The repo has no top-level license file. Add one before treating these skills as redistributable or taking outside contributions. Third-party skills keep their own licenses (see [above](#third-party-skills)).

## Author

**Paul Namalomba** · [GitHub](https://github.com/paulnamalomba) · [Email](mailto:paul.namalomba-cio@computemore.com) · [LinkedIn](https://www.linkedin.com/in/paulnamalomba/) · [Portfolio](https://paulnamalomba.github.io/)
