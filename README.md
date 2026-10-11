# spec-driven-design

[![Skills](https://img.shields.io/badge/skills-17-blue)](#skills)
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

### Analysis and audits

| Skill | Use it when | Output |
| --- | --- | --- |
| [`code-analysis-recommendations`](analysis-and-recommndations/code-analysis-recommendations/SKILL.md) | A bug, feature, or structural problem needs a close read before anyone edits code. | Two documents: an analysis report and a fixes document written as "replace this with this" and "insert this here" instructions. |
| [`deep-code-and-security-audits`](deep-code-and-security-audits/SKILL.md) | A subsystem needs a security, integration, code quality, and performance review. | Three dated reports in `$outputdir`: `SecurityAudit`, `IntegrationAudit`, `CodeQualityAudit`. |
| [`ux-system-analyzer`](ux-system-analyzer/SKILL.md) | Screenshots and UI source need to be checked against the design system. | Two dated reports under `$outputdir/docs/code/`: the UX analysis and the recommended changes. |
| [`optimize-docker-builds`](optimize-docker-builds/SKILL.md) | Docker builds are slow, contexts are large, dependency restores repeat, or runtime images carry build tools. | Rewritten Dockerfiles, `.dockerignore` files, and Compose/CI build changes, with before/after timings from `scripts/benchmark_docker_build.sh`. |

### Frontend and UI design

| Skill | Use it when | Output |
| --- | --- | --- |
| [`impeccable`](impeccable/SKILL.md) | Designing, redesigning, critiquing, or polishing any frontend: sites, product UI, forms, onboarding, empty states. | UI changes driven by sub-commands (`critique`, `audit`, `polish`, `harden`, `animate`, `colorize`, and more), plus `PRODUCT.md` / `DESIGN.md` context files. Ships its own helper agents and a live-browser script. |
| [`design-taste-frontend`](design-taste-frontend/SKILL.md) | Building or redesigning a landing page, portfolio, or editorial site that shouldn't look like a template. | A one-line design read, then the page, checked against a pre-flight list. |
| [`dashboard-design`](dashboard-design/SKILL.md) | Designing or reviewing operations, finance, logistics, seller, or analytics dashboards. | A short design decision list, the dashboard, and evidence that it was checked in the running app at several viewport widths. |
| [`pretty-mermaid`](pretty-mermaid/SKILL.md) | You have Mermaid source, or need a flowchart, sequence, state, class, ER, or XY diagram drawn. | Themed SVG, PNG, or ASCII/Unicode output, rendered locally with the bundled Node scripts. 15 built-in themes. |

### Docs, releases, and maintenance

| Skill | Use it when | Output |
| --- | --- | --- |
| [`convert-docx-to-md`](convert-docx-to-md/SKILL.md) | A `.docx` has to become Markdown without losing headings, tables, formatting, or images. | A snake_case `.md` file plus a folder of extracted media next to it. |
| [`create-commit-notes`](create-commit-notes/SKILL.md) | An Ecoride repo needs technical release notes built from its real Git diff. | `.commits/<version>.txt` with the diff baseline, changes, touched files, compatibility, deployment, and validation. |
| [`create-release-listing-summaries`](create-release-listing-summaries/SKILL.md) | An Ecoride mobile app needs store listing text written from its commit notes. | `builds/<app>-<version>-listing.md` with 5 Android points and 12 iOS points, no low-level code detail. |
| [`create-substream-work-summary`](create-substream-work-summary/SKILL.md) | A piece of parallel work (a "substream") needs a write-up for its target repo and branch. | One file at `docs/work/DDbbYY-substream<NN>-work-to-<reponame>-<branchname>.md`, never duplicated under another name. |
| [`comment-out-non-performant-scalers`](comment-out-non-performant-scalers/SKILL.md) | A Flutter app already scales text at the theme root, and widget-level `fontSize: AppConstants.scaledFontSize(...)` calls should be disabled. | Targeted Dart edits, a ledger of every occurrence, a scoped diff review, then format, analyze, and test runs. |

### Agent behavior

| Skill | Use it when | Output |
| --- | --- | --- |
| [`caveman`](caveman/SKILL.md) | You want shorter agent replies with all technical detail kept. | No files. Changes how the agent writes until told "stop caveman" or "normal mode". |

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

Agents look for skills in their own folder: `~/.codex/skills/<name>/` for Codex, `~/.claude/skills/<name>/` for Claude Code. Symlink the ones you want rather than copying, so edits here take effect:

```bash
mkdir -p "$HOME/.codex/skills"
ln -s "$PWD/create-technical-architecture" \
  "$HOME/.codex/skills/create-technical-architecture"
```

`ln -s` fails if the destination already exists. That's on purpose. Look at the installed copy and reconcile it by hand instead of overwriting it.

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
├── caveman/
├── comment-out-non-performant-scalers/  # agents/openai.yaml
├── convert-docx-to-md/
├── create-commit-notes/
├── create-release-listing-summaries/
├── create-specifications-existing-projects/  # agents/, references/srs-structure.md
├── create-substream-work-summary/
├── create-technical-architecture/
├── dashboard-design/
├── deep-code-and-security-audits/
├── design-taste-frontend/
├── impeccable/                          # agents/, reference/, scripts/
├── merge-customer-journeys-into-specifications/  # agents/, references/
├── optimize-docker-builds/              # agents/, references/patterns.md, scripts/
├── pretty-mermaid/                      # references/, scripts/, docs/, package.json
├── ux-system-analyzer/
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
| `create-commit-notes` | Ecoride's API, Driver, Rider, Admin, and Website repos and their `.commits` format. |
| `create-release-listing-summaries` | Ecoride mobile apps and the `builds/` folder. |
| `create-substream-work-summary` | The `docs/work/` folder and the `DDbbYY-substream<NN>-…` naming scheme. |
| `comment-out-non-performant-scalers` | A Flutter app with verified theme-root text scaling. |
| `create-specifications-existing-projects` | Generic, with extra notes on Afriflex repo roles. |
| `merge-customer-journeys-into-specifications` | Generic, with detailed Afriflex SACCO/BNPL and USSD rules. |
| `ux-system-analyzer` | Screenshots plus JSX/HTML/CSS/Tailwind source. |
| `create-technical-architecture` | Generic, pitched at the depth of the Ecoride architecture docs. |
| `deep-code-and-security-audits` | Generic. Its "100% coverage" claims only hold if the tools in the target environment can back them. |

The rest (`convert-docx-to-md`, `optimize-docker-builds`, `impeccable`, `design-taste-frontend`, `dashboard-design`, `pretty-mermaid`, `caveman`) don't depend on a particular project.

To adapt a specialised skill, change the name, description, paths, examples, domain rules, and output contract together. A "generic" copy with Ecoride paths still inside is worse than the original.

## Third-party skills

Some skills came from elsewhere and keep their own licenses:

- `pretty-mermaid` is MIT (Beautiful-Mermaid Contributors). See [`pretty-mermaid/LICENSE`](pretty-mermaid/LICENSE).
- `dashboard-design` declares `license: MIT` in its front matter.
- `impeccable` ships its own scripts and version file (`impeccable/scripts/VERSION`).

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
