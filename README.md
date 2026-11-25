# spec-driven-design

[![Skills](https://img.shields.io/badge/skills-55-blue)](#skills)
[![Plugins](https://img.shields.io/badge/plugins-2-purple)](#plugins)
[![Format](https://img.shields.io/badge/format-SKILL.md-2ea44f)](#package-layout)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)

Agent skills and plugins for spec-first software work: requirements, architecture, audits, UI design, release notes.

- Each skill is a folder with a `SKILL.md`. A coding agent (Claude Code, Codex, Antigravity, or any tool that reads the format) loads it and does one job.
- Nothing here runs by itself and there is nothing to build or install. The agent applies a skill to some other repo or document.
- Some skills still assume a specific project layout. Check [Project-specific skills](#project-specific-skills) before you reuse one.
- MIT licensed. Third-party skills keep their own terms ([details](#third-party-sources)).

## Contents

- [spec-driven-design](#spec-driven-design)
  - [Contents](#contents)
  - [Quick start](#quick-start)
  - [How the skills fit together](#how-the-skills-fit-together)
  - [Skills](#skills)
    - [Specifications and architecture](#specifications-and-architecture)
    - [Analysis, review, and audits](#analysis-review-and-audits)
    - [Frontend and UI design](#frontend-and-ui-design)
    - [Docs, releases, and office files](#docs-releases-and-office-files)
    - [Planning and agent behaviour](#planning-and-agent-behaviour)
    - [Language standards](#language-standards)
      - [Local symlinks](#local-symlinks)
  - [Plugins](#plugins)
    - [multi-opinion](#multi-opinion)
    - [awesome-design-skills](#awesome-design-skills)
    - [Installing a plugin](#installing-a-plugin)
    - [Adding a plugin](#adding-a-plugin)
  - [Writing a good request](#writing-a-good-request)
  - [Common chains](#common-chains)
    - [Documenting an existing product](#documenting-an-existing-product)
    - [Fixing UI drift](#fixing-ui-drift)
    - [Shipping a release](#shipping-a-release)
    - [Running work through issues and PRs](#running-work-through-issues-and-prs)
  - [Package layout](#package-layout)
  - [Repository layout](#repository-layout)
  - [Project-specific skills](#project-specific-skills)
  - [Third-party sources](#third-party-sources)
  - [Writing or changing a skill](#writing-or-changing-a-skill)
  - [Ground rules](#ground-rules)
  - [Checking the repo](#checking-the-repo)
  - [License](#license)
  - [Author](#author)

---

## Quick start

```bash
git clone --recurse-submodules https://github.com/paulnamalomba/spec-driven-design.git
cd spec-driven-design
rg --files -g 'SKILL.md' | sort
```

- `--recurse-submodules` pulls the [`awesome-design-skills`](#awesome-design-skills) upstream. Already cloned? Run `git submodule update --init`.
- Symlink each skill so edits here reach every agent.

| Agent | Skills folder |
| --- | --- |
| Claude Code | `~/.claude/skills/<name>/` |
| Codex | `~/.codex/skills/<name>/` |
| Antigravity | `~/.gemini/config/skills/<name>/` |

```bash
mkdir -p "$HOME/.claude/skills"
ln -s "$PWD/create-technical-architecture" \
  "$HOME/.claude/skills/create-technical-architecture"
```

- `ln -s` fails if the target exists. That is deliberate: compare the installed copy and reconcile by hand.
- Copied instead of linked? Check for drift with `cmp <skill>/SKILL.md ~/.claude/skills/<skill>/SKILL.md`.
- `pretty-mermaid` needs `npm install` in its folder before its render scripts work.
- Plugins install differently. See [Plugins](#plugins).

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/install-wiring-dark.svg">
  <img alt="Skill folders are symlinked into each agent's skills directory; plugin folders are installed from a marketplace. Both reach Claude Code, Codex, and Antigravity." src="docs/diagrams/install-wiring-light.svg">
</picture>

## How the skills fit together

Each skill does one job and stops. Chain them, one skill per step.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/skill-chain-dark.svg">
  <img alt="Inputs feed discovery. Discovery splits into an existing-system SRS and code or UX analysis. The SRS takes a journey merge; analysis yields approved fixes. Both feed the technical architecture, then approved implementation, then review, audit, and release notes." src="docs/diagrams/skill-chain-light.svg">
</picture>

Boundaries:

- SRS skills describe requirements. They don't implement them.
- Audits list risks and fixes. They are not permission to rewrite the target.
- `code-analysis-recommendations` writes exact edits for someone else to apply.
- Skills that do edit source: `optimize-docker-builds` (build files only), `impeccable`, `design-taste-frontend-v2`, `dashboard-design`, `implement`.
- `create-commit-notes` documents a release. It doesn't commit, tag, or push.

## Skills

Diagram sources live in [`docs/diagrams/`](docs/diagrams/) as `.mmd` files, rendered with [`pretty-mermaid`](pretty-mermaid/SKILL.md).

### Specifications and architecture

| Skill | Use it when | Produces |
| --- | --- | --- |
| [`create-specifications-existing-projects`](create-specifications-existing-projects/SKILL.md) | An existing system needs an SRS built from what its repos actually do. | SRS with requirement IDs, source evidence, status, acceptance criteria, gaps, glossary. |
| [`merge-customer-journeys-into-specifications`](merge-customer-journeys-into-specifications/SKILL.md) | Journeys, user flows, or service blueprints must land in an existing SRS. | Updated SRS, addendum, or journey-to-requirement traceability matrix. |
| [`create-technical-architecture`](create-technical-architecture/SKILL.md) | Requirements, design analysis, and code need one architecture doc. | `docs/architecture/SYSTEM_ARCHITECTURE_AND_DESIGN.md` with diagrams, trade-offs, security, data flow. |
| [`codebase-design`](codebase-design/SKILL.md) | Designing deep modules, picking seams, making code testable and agent-navigable. | Interface specs, seam definitions, boundary notes. |
| [`low-level-systems`](low-level-systems/SKILL.md) | Systems, embedded, HPC, custom allocators, OS/hardware interfaces. | Memory layouts, hot-path analysis, mechanical-sympathy review. |
| [`whiteboard`](whiteboard/SKILL.md) | Explaining a branch or PR visually, or digging through session history. | Whiteboard diagrams and walkthroughs. Local symlink; see [note](#local-symlinks). |

### Analysis, review, and audits

| Skill | Use it when | Produces |
| --- | --- | --- |
| [`code-analysis-recommendations`](code-analysis-recommendations/SKILL.md) | A bug, feature, or structural problem needs a close read before edits. | Analysis report plus a fixes doc in "replace this with this" form. |
| [`code-review`](code-review/SKILL.md) | Reviewing changes since a commit, branch, tag, or merge-base. | Parallel Standards and Spec reports, side by side. |
| [`deep-code-and-security-audits`](deep-code-and-security-audits/SKILL.md) | A subsystem needs security, integration, quality, and performance review. | Dated `SecurityAudit`, `IntegrationAudit`, `CodeQualityAudit` reports in `$outputdir`. |
| [`ux-system-analyzer`](ux-system-analyzer/SKILL.md) | Screenshots and UI source need checking against the design system. | UX analysis and change list under `$outputdir/docs/code/`. |
| [`web-design-guidelines`](web-design-guidelines/SKILL.md) | UI code needs an accessibility and Web Interface Guidelines pass. | Findings against the guidelines. |
| [`optimize-docker-builds`](optimize-docker-builds/SKILL.md) | Builds are slow, contexts large, or runtime images carry build tools. | Rewritten Dockerfiles, `.dockerignore`, Compose/CI changes, before/after timings. |
| [`research`](research/SKILL.md) | A question needs answering from primary sources. | One cited Markdown file in the repo. |

### Frontend and UI design

| Skill | Use it when | Produces |
| --- | --- | --- |
| [`impeccable`](impeccable/SKILL.md) | Designing, critiquing, or polishing any frontend. | UI changes via sub-commands (`critique`, `audit`, `polish`, `harden`, `animate`, …) plus `PRODUCT.md` / `DESIGN.md`. |
| [`design-taste-frontend-v2`](design-taste-frontend-v2/SKILL.md) | Building a company, product, or SaaS site that must not look templated. | The site, checked in a real browser by its own checker and finish gate. |
| [`design-taste-frontend-v1`](design-taste-frontend-v1/SKILL.md) | Same job, older and lighter version. | A one-line design read, the page, a pre-flight check. |
| [`frontend-design`](frontend-design/SKILL.md) | New or reshaped UI needs a clear aesthetic direction. | Typography, layout, and visual decisions in code. |
| [`dashboard-design`](dashboard-design/SKILL.md) | Ops, finance, logistics, seller, or analytics dashboards. | Decision list, the dashboard, multi-viewport checks in the running app. |
| [`dense-dashboard-design`](dense-dashboard-design/SKILL.md) | Admin panels, dense tables, KPI tiles, real-time status. | App-shell layouts, table recipes, KPI grids. |
| [`better-interface`](better-interface/SKILL.md) | A whole interface needs a review of hierarchy, spacing, type, keyboard, states. | Prioritised review verdict. |
| [`find-animation-opportunities`](find-animation-opportunities/SKILL.md) | Looking for places motion would help. Read-only. | 5–7 motion recipes with exact durations and easings. |
| [`desktop-to-mobile`](desktop-to-mobile/SKILL.md) | A desktop frame needs a 390 px mobile version. | New mobile frame beside the untouched desktop one. |
| [`bento-board-ui`](bento-board-ui/SKILL.md) | Brand assets or a site need a share-ready bento board. | One presentation frame of image tiles. |
| [`stitch-ui-design`](stitch-ui-design/SKILL.md) | Generating UI in Google Stitch. Alias: `stitch-design`. | Stitch prompts, variants, design-to-code steps. |
| [`pretty-mermaid`](pretty-mermaid/SKILL.md) | Drawing or rendering Mermaid diagrams. | Themed SVG, PNG, or ASCII/Unicode. 15 themes, rendered locally. |
| [`professional-cae-fem-gui-principles`](professional-cae-fem-gui-principles/SKILL.md) | Dear ImGui apps for FEM/FEA, CAD/CAE, scientific visualisation. | Viewport, mesh, and workbench specs, plus a SESKA profile. |
| [`brag`](brag/SKILL.md) | Turning a project site into a short launch video. | Hyperframes storyboard and script. |

### Docs, releases, and office files

| Skill | Use it when | Produces |
| --- | --- | --- |
| [`create-commit-notes`](create-commit-notes/SKILL.md) | A repo needs commit or release notes, full or minimal. | `.commits/<version>.md` (Added, Changed, Fixed, Validation, …). |
| [`create-commit-notes-markdown`](create-commit-notes-markdown/SKILL.md) | Same job, with per-app version profiles. | `.commits/<version>.md`. |
| [`create-release-listing-summaries`](create-release-listing-summaries/SKILL.md) | A mobile app needs store listing text from its commit notes. | `builds/<app>-<version>-listing.md`: 5 Android points, 12 iOS points. |
| [`create-substream-work-summary`](create-substream-work-summary/SKILL.md) | A parallel work stream needs a write-up for its target repo and branch. | `docs/work/DDbbYY-substream<NN>-work-to-<repo>-<branch>.md`, never duplicated. |
| [`convert-docx-to-md`](convert-docx-to-md/SKILL.md) | A `.docx` must become Markdown without losing structure. | snake_case `.md` plus an extracted media folder. |
| [`boq-print-standardise`](boq-print-standardise/SKILL.md) | A Bill of Quantities workbook needs one layout and print setup. | Uniform columns, Arial 10, "Page No. X/Y" footers, A4, clean totals chain. |
| [`humanize`](humanize/SKILL.md) | Commit messages, PRs, or docs read like AI output. | Rewritten text without AI writing patterns. |
| [`docs`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/docs/SKILL.md) | Shared, editable documents via the docs connector. | Docs exportable to Word, PDF, Markdown, Google Docs. |
| [`docx`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/docx/SKILL.md) | Reading or editing Word files. | `.docx` with styles and tracked changes kept. |
| [`pdf`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/pdf/SKILL.md) | Extracting, merging, splitting, filling, or OCR on PDFs. | Processed PDFs and form data. |
| [`pptx`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/pptx/SKILL.md) | Building or parsing slide decks. | `.pptx` decks or extracted content. |
| [`xlsx`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/xlsx/SKILL.md) | Spreadsheets as input or output. | Workbooks with verified formulas. |
| [`google-workspace`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/google-workspace/SKILL.md) | Creating or editing Google Docs, Sheets, Slides. | Files changed in Drive. |

### Planning and agent behaviour

| Skill | Use it when | Produces |
| --- | --- | --- |
| [`planning-and-task-breakdown`](planning-and-task-breakdown/SKILL.md) | A spec needs to become ordered, sized tasks. | Task list with dependencies and parallel tracks. |
| [`issue-and-pr-based-development`](issue-and-pr-based-development/SKILL.md) | Humans and agents work through a board, issues, and PRs. | Issues, board items, `<owner>/<work>` branches, PRs with `Closes #<n>`. Never merges or releases. |
| [`implement`](implement/SKILL.md) | Building from a spec or tickets with TDD and review loops. | Code with typecheck and test runs. |
| [`chief-of-staff`](chief-of-staff/SKILL.md) | Driving a long goal across one session with subagents. | Delegations, context pointers, schedules. |
| [`grilling`](grilling/SKILL.md) | Stress-testing a plan or decision. | Rounds of questions with recommended answers. |
| [`grill-me`](grill-me/SKILL.md) | Shortcut into `grilling`. | Interview session. |
| [`grill-with-docs`](grill-with-docs/SKILL.md) | Grilling that also records decisions. | Answers plus ADRs and a glossary. |
| [`writing-for-agents`](writing-for-agents/SKILL.md) | Writing a skill, `AGENTS.md`, or `CLAUDE.md`. | Tighter agent-facing docs. |
| [`caveman`](caveman/SKILL.md) | Shorter agent replies, same technical detail. | No files. Changes reply style until "stop caveman". |
| [`skill-creator`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/skill-creator/SKILL.md) | Creating, testing, or benchmarking skills. | `SKILL.md` packages, test prompts, eval reports. |
| [`import-memory`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/import-memory/SKILL.md) | Moving memories from another assistant into Claude. | Memory entries. |
| [`morning`](synced/125118c9-8c32-4a11-ab92-dd0810b788c4_f2201e45-d812-4437-acae-677a92bda627/morning/SKILL.md) | A one-page morning brief. | HTML brief, optionally recurring. |

### Language standards

| Skill | Use it when | Produces |
| --- | --- | --- |
| [`csharp-coding-standards`](csharp-coding-standards/SKILL.md) | Writing modern C# 12+. | Records, pattern matching, value objects, `Span<T>`, API design. |
| [`csharp-concurrency-patterns`](csharp-concurrency-patterns/SKILL.md) | Picking a .NET concurrency model. | async/await, Channels, or Akka.NET, chosen per workload. |
| [`csharp-type-design-performance`](csharp-type-design-performance/SKILL.md) | Designing .NET types for speed. | Sealed classes, readonly structs, right-sized collections. |

#### Local symlinks

- `whiteboard` points at an absolute path in a local dev.fast install. It resolves on the author's machine only; clones get a dangling link.
- `stitch-design` is a relative alias for `stitch-ui-design` and works anywhere.

## Plugins

Plugins bundle several skills behind one install. Each plugin folder carries a manifest per agent:

- `.claude-plugin/plugin.json` and `marketplace.json` for Claude Code
- `.codex-plugin/plugin.json` for Codex
- `.antigravity-plugin/plugin.json` for Antigravity

| Plugin | Source | Skills | License | Category |
| --- | --- | --- | --- | --- |
| [`multi-opinion`](my-plugins/multi-opinion/) | Mine | 3 | MIT (this repo) | Orchestration |
| [`awesome-design-skills`](external-plugins/awesome-design-skills/) | [bergside/awesome-design-skills](https://github.com/bergside/awesome-design-skills) (git submodule) | 67 | MIT (Bergside) | Design |

### multi-opinion

Runs a "council": several models review or research the same task in parallel, then the orchestrator checks their findings against the code.

- Trigger: say `multi-opinion`.
- One skill per host agent, each with its own delegate mix:
  - [`base`](my-plugins/multi-opinion/skills/base/SKILL.md): Claude host. Claude plus Gemini delegates via `/antigravity:research` and `/antigravity:handoff`.
  - [`codex`](my-plugins/multi-opinion/skills/codex/SKILL.md): Codex host. Gemini and GPT delegates.
  - [`gemini`](my-plugins/multi-opinion/skills/gemini/SKILL.md): Antigravity host. Two Gemini delegates.
- Uses `chief-of-staff` to start delegates in parallel.
- Reviews stay read-only. Each delegate scores out of 10 per round.
- Missing provider: it reports the gap. It never swaps in another model.
- With an open PR, scores go into the PR description as a "Council review" table.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/multi-opinion-dark.svg">
  <img alt="Sequence: user sends a multi-opinion request; the orchestrator fixes known issues and runs checks, starts delegates in parallel, receives findings and scores, verifies findings against the code, requests a fresh review after fixes, receives round scores, and returns a summary with the council table." src="docs/diagrams/multi-opinion-light.svg">
</picture>

### awesome-design-skills

67 design-system skills from Bergside (`agentic`, `brutalism`, `glassmorphism`, `material`, `shadcn`, `retro`, …). Each ships a `SKILL.md` for agents and a `DESIGN.md` for people.

- Upstream lives in `external-plugins/awesome-design-skills/upstream` (submodule).
- `skills/` is a symlink to `upstream/skills`, so the manifests stay ours and the content stays theirs.
- Update: `git submodule update --remote external-plugins/awesome-design-skills/upstream`.
- Preview the styles at [typeui.sh/design-skills](https://typeui.sh/design-skills).

### Installing a plugin

Claude Code (inside a session):

```text
/plugin marketplace add ./my-plugins/multi-opinion
/plugin install multi-opinion@multi-opinion

/plugin marketplace add ./external-plugins/awesome-design-skills
/plugin install awesome-design-skills@awesome-design-skills
```

Antigravity:

```bash
agy plugin install ./my-plugins/multi-opinion
agy plugin install ./external-plugins/awesome-design-skills
agy plugin validate ./my-plugins/multi-opinion   # manifest check
```

Codex reads a repo marketplace from `.agents/plugins/marketplace.json`.

```json
{
  "name": "spec-driven-design",
  "plugins": [
    {
      "name": "awesome-design-skills",
      "source": { "source": "local", "path": "./external-plugins/awesome-design-skills" },
      "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
      "category": "Design"
    },
    {
      "name": "multi-opinion",
      "source": { "source": "local", "path": "./my-plugins/multi-opinion" },
      "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
      "category": "Orchestration"
    }
  ]
}
```

Then enable them in `.codex/config.toml`:

```toml
[plugins."awesome-design-skills@spec-driven-design"]
enabled = true
[plugins."multi-opinion@spec-driven-design"]
enabled = true
```

### Adding a plugin

- Your own: `my-plugins/<name>/` with `skills/<skill>/SKILL.md` and the three manifest folders.
- Someone else's: add the repo as a submodule under `external-plugins/<name>/upstream`, symlink `skills` to it, and write the manifests next to it.
- Register it in `.agents/plugins/marketplace.json` for Codex.
- Validate with `agy plugin validate <dir>`.
- Add a row to the [plugin table](#plugins).

## Writing a good request

Name the skill, point at the inputs, say where the output goes:

```text
$create-specifications-existing-projects

Inspect ~/Development/example-api, ~/Development/example-web, and
~/Development/example-admin. Write the SRS to
~/Development/example-contracts/docs/specifications/. Treat unbuilt
admin modules as planned gaps and cite a source file for every implemented claim.
```

```text
$optimize-docker-builds

The API image takes 6 minutes to rebuild after a one-line change. Look at
api/Dockerfile and docker-compose.yml, time one build first, and don't
change runtime behaviour.
```

```text
$create-commit-notes

Create .commits/1.2.0.md from the previous tag. Include the diff baseline,
untracked release files, compatibility, deployment order, and which
commands passed or failed. Don't commit or push.
```

The real output is usually a file in the target project. Read it and check:

- every claim traces to a source file or requirement
- assumptions and open decisions are listed, not buried
- the change or recommendation list is complete
- security and privacy effects are covered
- validation commands and their actual results are stated
- the file landed where the skill says it should

## Common chains

### Documenting an existing product

1. `convert-docx-to-md`: Word specs and journeys to Markdown.
2. `create-specifications-existing-projects`: current-state SRS.
3. `merge-customer-journeys-into-specifications`: fold in the journeys.
4. `create-technical-architecture`: architecture doc.
5. `deep-code-and-security-audits`: once the work is built.

### Fixing UI drift

1. `ux-system-analyzer`: screenshots plus the UI repo.
2. `code-analysis-recommendations`: deeper trace where needed.
3. Approve the recommendations before anyone edits code.
4. `impeccable` (`polish`, `harden`, `audit`) or `dashboard-design`: make and check the changes.
5. Run the target repo's own lint, tests, build, and visual checks.

### Shipping a release

1. Finish and validate the work in the target repo.
2. `create-commit-notes` against a pinned previous version.
3. `create-release-listing-summaries` for store text (mobile apps).
4. `create-substream-work-summary` if the work ran as a substream.
5. Commit, tag, push, and deploy through your normal process, not the skill.

### Running work through issues and PRs

1. `planning-and-task-breakdown`, with the tracker as the target.
2. `issue-and-pr-based-development`: issues, board items, agent briefs.
3. `implement` in each agent worktree. Commits stay local.
4. `code-review` on each branch before the orchestrator pushes and opens the PR.
5. `multi-opinion` for a second (and third) model's read on risky PRs.
6. The owner reviews and merges. Notes and tags follow.

## Package layout

```text
skill-name/
├── SKILL.md         # required: the instructions
├── agents/          # optional: openai.yaml UI metadata, helper agent definitions
├── references/      # docs loaded on demand
├── scripts/         # optional helpers
└── assets/          # templates and static files
```

Every `SKILL.md` opens with front matter:

```yaml
---
name: skill-name
description: When this skill should trigger, written so an agent can match it.
---
```

- The body covers what applies: trigger, role and limits, inputs, what to inspect first, what it may change, steps, output paths, references, validation.
- `agents/openai.yaml` holds a display name, short description, and default prompt. `SKILL.md` wins if they disagree.
- `impeccable/agents/` also holds `.toml` helper-agent definitions.
- `SKILL.md` rules outrank any helper script.

## Repository layout

```text
spec-driven-design/
├── <skill-name>/                 # one folder per skill (see Skills)
├── analysis-and-recommndations/  # legacy copy of code-analysis-recommendations
├── synced/<id>/                  # synced Anthropic skills: docs, docx, pdf, pptx, xlsx, …
├── my-plugins/
│   └── multi-opinion/            # skills/{base,codex,gemini} + manifests
├── external-plugins/
│   └── awesome-design-skills/    # manifests + upstream/ submodule
├── docs/diagrams/                # .mmd sources and rendered SVGs
├── guides/ssh_public_ip_setup.md # Linux SSH hardening guide (not a skill)
├── skills-lock.json              # upstream source and hash for pinned skills
├── AGENTS.md                     # agent instructions; CLAUDE.md, GEMINI.md import it
└── LICENSE
```

- `analysis-and-recommndations/` is misspelled on purpose: older installed links point at it. It has drifted from the top-level `code-analysis-recommendations/`, which is the one to edit.
- `guides/ssh_public_ip_setup.md` covers OpenSSH, firewall rules, port forwarding, keys, disabling password login, and Fail2ban. Prefer a VPN or private network over exposing SSH.

## Project-specific skills

| Skill | Assumes |
| --- | --- |
| `code-analysis-recommendations` | Writes to `~/<repo>/docs/ideas/<month>/`. |
| `create-commit-notes` | A `.commits/` folder and the repo's own version profile (`AGENTS.md`). |
| `create-release-listing-summaries` | Mobile apps and a `builds/` folder. |
| `create-substream-work-summary` | `docs/work/` and the `DDbbYY-substream<NN>-…` naming. |
| `create-specifications-existing-projects` | Generic, plus notes on Afriflex repo roles. |
| `merge-customer-journeys-into-specifications` | Generic, plus Afriflex SACCO/BNPL and USSD rules. |
| `ux-system-analyzer` | Screenshots plus JSX/HTML/CSS/Tailwind source. |
| `deep-code-and-security-audits` | Generic. "100% coverage" holds only if the target's tooling can prove it. |
| `professional-cae-fem-gui-principles` | Generic Dear ImGui CAE rules, plus a SESKA FEA profile. |
| `boq-print-standardise` | Excel BoQ workbooks with collection/summary sheets. |

- Everything else is project-neutral.
- To adapt a specialised skill, change its name, description, paths, examples, domain rules, and output contract together.

## Third-party sources

These came from elsewhere and keep their own licenses. Check upstream before heavy edits, or new releases get hard to merge.

| Skill or plugin | Upstream | License |
| --- | --- | --- |
| `awesome-design-skills` | [bergside/awesome-design-skills](https://github.com/bergside/awesome-design-skills) | MIT |
| `pretty-mermaid` | Beautiful-Mermaid contributors | MIT ([LICENSE](pretty-mermaid/LICENSE)) |
| `humanize` | [smykla-skalski/sai](https://github.com/smykla-skalski/sai) | MIT (front matter) |
| `dense-dashboard-design` | [arnavpuri/designskills](https://github.com/arnavpuri/designskills) | MIT (front matter) |
| `dashboard-design` | — | MIT (front matter) |
| `code-review`, `codebase-design` | [mattpocock/skills](https://github.com/mattpocock/skills) | See upstream |
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills) | Apache 2.0 ([LICENSE.txt](frontend-design/LICENSE.txt)) |
| `web-design-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | See upstream |
| `impeccable` | Impeccable (`impeccable/scripts/VERSION`) | See upstream |
| `whiteboard` | dev.fast Whiteboard | See upstream |
| `synced/*` | Anthropic | Per skill; `docx`, `pdf`, `pptx`, `xlsx` are proprietary (see each `LICENSE.txt`) |

- Pins and hashes for some of these are in [`skills-lock.json`](skills-lock.json).

## Writing or changing a skill

1. Give it one job and a description that says when it triggers.
2. Say whether it is read-only, writes documents, or edits source.
3. List the inputs and the conditions that make it stop.
4. Name output files and say whether existing files are edited in place.
5. Make the agent read the target repo before it concludes or edits.
6. Link only the references, scripts, and assets the job needs.
7. Ask for validation that fits the job, and honest reporting when it fails.
8. Try it on a real repo with uncommitted changes.
9. Check the installed copy matches this one.

Before committing:

- folder name matches `name` in front matter
- reference and script paths are relative to `SKILL.md` and exist
- output paths can't be confused with this repo
- a read-only skill can't drift into editing code
- destructive commands, secrets, and dirty worktrees are handled
- examples use placeholders, not real credentials or production IDs
- "complete" or "100%" is backed by something measurable
- validation commands fit the target's toolchain
- `agents/openai.yaml`, if present, agrees with `SKILL.md`

No version field or manifest. Git history is the record. If a change breaks a skill's output contract, say so in the commit message and update installed copies.

## Ground rules

Apply to every skill:

- Read the target repo's `AGENTS.md` or `CLAUDE.md` first.
- Leave uncommitted changes alone. Keep diffs to the task.
- Keep credentials, tokens, keys, production IDs, and personal data out of outputs.
- Client-side checks are UX, not security. Confirm server-side enforcement.
- Cite file paths, requirement sources, or Git baselines where traceability is asked for.
- Never invent APIs, fields, status, test results, citations, or commands.
- If a tool can't prove an audit claim, narrow the claim and say why.
- No commit, tag, push, deploy, or PR unless the user asks for it.

## Checking the repo

No linter, test runner, or CI here, so never report that one passed. What you can check:

```bash
# list skills
rg --files -g 'SKILL.md' | sort

# front matter
for f in $(rg --files -g 'SKILL.md'); do sed -n '1,5p' "$f"; done

# plugin manifests
agy plugin validate ./my-plugins/multi-opinion
agy plugin validate ./external-plugins/awesome-design-skills

# whitespace and scope
git diff --check
git status --short
```

- Open every relative link and every new `references/`, `scripts/`, `assets/`, or `agents/` path and confirm it exists.
- `pretty-mermaid`: `npm test` in its folder runs the render smoke test.
- Re-render diagrams after editing a `.mmd`:

```bash
cd pretty-mermaid
for f in ../docs/diagrams/*.mmd; do
  for t in light dark; do
    node scripts/render.mjs --input "$f" --output "${f%.mmd}-$t.svg" --theme "github-$t" --transparent
  done
done
```

## License

[MIT](LICENSE) © 2026 Paul Namalomba.

- Covers everything original in this repo: skills, plugins, docs, diagrams.
- Use, copy, modify, redistribute, or sell it. Keep the copyright and permission notice.
- Third-party skills and plugins keep their own licenses. See [Third-party sources](#third-party-sources).

## Author

**Paul Namalomba** · [GitHub](https://github.com/paulnamalomba) · [Email](mailto:paul.namalomba-cio@computemore.com) · [LinkedIn](https://www.linkedin.com/in/paulnamalomba/) · [Portfolio](https://paulnamalomba.github.io/)
