# Spec-Driven Design — Agentic Workflow Library

[![Workflows](https://img.shields.io/badge/workflows-10-blue)](#workflow-catalogue)
[![Format](https://img.shields.io/badge/format-SKILL.md-2ea44f)](#skill-package-anatomy)
[![Focus](https://img.shields.io/badge/focus-spec--driven%20delivery-purple)](#delivery-model)
[![Runtime](https://img.shields.io/badge/runtime-agentic%20workflows-orange)](#using-the-workflows)

> **A source-controlled library of rigorous agent workflows for discovering existing systems, producing specifications and architecture, reconciling customer journeys, auditing code and UX, preparing release notes, and performing tightly scoped maintenance.**

`spec-driven-design` is not an application, framework, or deployable service. It is the authoring home for reusable `SKILL.md` instruction packages used by coding agents across Ecoride, Afriflex, and other software projects.

Each workflow turns an open-ended request into a repeatable operating procedure with explicit roles, evidence requirements, output paths, guardrails, and validation expectations. The repository exists to make agent-assisted delivery more deterministic, reviewable, and grounded in the current state of the target project.

## Contents

- [Purpose](#purpose)
- [Design Principles](#design-principles)
- [Workflow Catalogue](#workflow-catalogue)
- [Delivery Model](#delivery-model)
- [Using the Workflows](#using-the-workflows)
- [Composing Workflows](#composing-workflows)
- [Skill Package Anatomy](#skill-package-anatomy)
- [Project Structure](#project-structure)
- [Repository-Specific Behavior](#repository-specific-behavior)
- [Authoring and Maintaining Skills](#authoring-and-maintaining-skills)
- [Safety and Evidence Rules](#safety-and-evidence-rules)
- [Validation](#validation)
- [Operational Guide](#operational-guide)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Purpose

The library addresses a recurring problem in agentic software work: a capable agent can still produce weak results when the operating method is vague.

These workflows define that method. Depending on the selected skill, an agent may be required to:

- inspect repositories before drawing conclusions;
- distinguish implemented behavior from documentation and planned intent;
- preserve dirty worktrees and constrain edits to an approved scope;
- create traceable requirements with testable acceptance criteria;
- produce exact replacement or insertion recommendations;
- connect screenshots to design-system source code;
- enumerate release diffs from a pinned Git baseline;
- write outputs to predictable, reviewable locations; and
- report validation failures honestly instead of treating them as success.

The result is a practical bridge between product intent, source evidence, technical design, implementation guidance, and release governance.

## Design Principles

| Principle | What it means in this repository |
| --- | --- |
| **Evidence before assertion** | Read the current source, routes, models, configuration, tests, and documentation before describing system behavior. |
| **Specifications before broad implementation** | Resolve scope, requirements, state transitions, integration boundaries, and acceptance criteria before making expansive changes. |
| **Repository conventions first** | Applicable `AGENTS.md` files and established project patterns outrank generic advice. |
| **Traceability** | Requirements, audit findings, recommendations, and release notes should point back to concrete source files or source documents. |
| **Explicit status** | Separate implemented behavior, documented intent, planned work, gaps, and unresolved decisions. |
| **Scoped mutation** | Analysis does not imply authorization to edit application code. Editing workflows define their own narrow mutation boundaries. |
| **Reviewable outputs** | Produce stable Markdown or text artifacts that a human can inspect, version, compare, and hand to another agent. |
| **Honest validation** | Record exact commands and results; never claim deterministic coverage, successful builds, or complete audits without evidence. |

## Workflow Catalogue

### Specifications, journeys, and architecture

| Skill | Use it when | Primary output |
| --- | --- | --- |
| [`$create-specifications-existing-projects`](create-specifications-existing-projects/SKILL.md) | An existing system needs an enterprise-grade SRS grounded in one or more repositories. | A development-ready SRS with requirement IDs, evidence, implementation status, acceptance criteria, security, operations, gaps, and glossary. |
| [`$merge-customer-journeys-into-specifications`](merge-customer-journeys-into-specifications/SKILL.md) | Customer journeys, service blueprints, or user flows must be reconciled with an existing SRS. | A merged SRS, requirements addendum, and/or journey-to-requirement traceability matrix. |
| [`$create-technical-architecture`](create-technical-architecture/SKILL.md) | Product requirements, design analysis, and source evidence need to become an authoritative architecture document. | `docs/architecture/SYSTEM_ARCHITECTURE_AND_DESIGN.md`, including diagrams, trade-offs, security, data flow, operations, glossary, and references. |

### Analysis, audits, and UX alignment

| Skill | Use it when | Primary output |
| --- | --- | --- |
| [`$code-analysis-recommendations`](analysis-and-recommndations/code-analysis-recommendations/SKILL.md) | A defect, feature, or structural concern needs a deep-read analysis before implementation. | Exactly two documents: a code analysis report and a line-targeted fixes document using “replace this” / “insert this here” instructions. |
| [`$deep-code-and-security-audits`](deep-code-and-security-audits/SKILL.md) | A subsystem needs architecture, security, integration, quality, performance, and runtime-integrity assessment. | Three dated reports: `SecurityAudit`, `IntegrationAudit`, and `CodeQualityAudit` in the supplied `$outputdir`. |
| [`$ux-system-analyzer`](ux-system-analyzer/SKILL.md) | Screenshots and UI source need cross-repository visual QA and design-system alignment analysis. | Two dated reports under `$outputdir/docs/code/`: UX analysis and implementation-ready recommendations. |

### Documentation, release governance, and maintenance

| Skill | Use it when | Primary output |
| --- | --- | --- |
| [`$convert-docx-to-md`](convert-docx-to-md/SKILL.md) | A DOCX source must become structurally faithful Markdown without losing headings, tables, formatting, or embedded media. | A snake_case Markdown file plus an adjacent extracted asset directory. |
| [`$create-commit-notes`](create-commit-notes/SKILL.md) | An Ecoride repository needs technical release notes derived from its actual Git diff and previous version. | `.commits/<version>.txt` with baseline, detailed changes, file inventory, compatibility, deployment, and validation. |
| [`$create-release-listing-summaries`](create-release-listing-summaries/SKILL.md) | An Ecoride mobile repository needs user-facing, abstract App Store and Google Play listing summaries derived from commit notes. | `builds/<app>-<version>-listing.md` with 5 abstract Android points and 12 abstract iOS points. |
| [`$comment-out-non-performant-scalers`](comment-out-non-performant-scalers/SKILL.md) | A confirmed Flutter app already scales typography at the theme root and approved widget-local `fontSize: AppConstants.scaledFontSize(...)` arguments must be disabled safely. | Targeted Dart edits, an exact occurrence ledger, scoped diff review, formatting analysis, and tests. |

## Delivery Model

The workflows support a spec-driven delivery chain rather than one monolithic “do everything” prompt:

```text
Source repositories + business documents + screenshots
                         │
                         ▼
             Discovery and evidence mapping
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
      Existing-system SRS     Code / UX analysis
              │                     │
              ▼                     ▼
      Journey reconciliation   Targeted recommendations
              │                     │
              └──────────┬──────────┘
                         ▼
              Technical architecture
                         │
                         ▼
             Approved implementation work
                         │
                         ▼
        Validation, audit, and release notes
```

The workflow boundaries are intentional:

- An SRS skill documents requirements; it does not silently implement them.
- An audit identifies risks and remediation; it does not imply approval to rewrite the target system.
- A recommendations skill prepares exact edits for a later implementation pass.
- The scaler workflow is deliberately exceptional: it is an editing workflow, but only for an exact authorized Dart argument shape.
- Commit-note creation documents the release state; it does not authorize committing, tagging, or pushing.

## Using the Workflows

### 1. Clone and inspect the library

```bash
git clone https://github.com/paulnamalomba/spec-driven-design.git
cd spec-driven-design
rg --files -g 'SKILL.md' | sort
```

There is no application bootstrap, dependency installation, build server, or runtime process. A compatible agent reads the selected `SKILL.md` and follows its instructions against a separate target repository or document set.

### 2. Make the skill available to the agent

In the current Codex setup, personal skills are discovered under:

```text
~/.codex/skills/<skill-name>/SKILL.md
```

This repository is the source-controlled authoring copy. Install or synchronize only the workflow you intend to expose. A non-destructive symlink example is:

```bash
mkdir -p "$HOME/.codex/skills"
ln -s "$PWD/create-technical-architecture" \
  "$HOME/.codex/skills/create-technical-architecture"
```

The command intentionally fails when the destination already exists. Inspect and reconcile an existing installed copy rather than overwriting it blindly.

Installed copies can drift from this repository. Check before assuming an edit is active:

```bash
cmp create-technical-architecture/SKILL.md \
  "$HOME/.codex/skills/create-technical-architecture/SKILL.md"
```

### 3. Invoke the skill with concrete inputs

Good requests name the workflow and provide its required evidence, scope, and output location.

```text
$create-specifications-existing-projects

Inspect ~/Development/example-api, ~/Development/example-web, and
~/Development/example-admin. Produce the SRS in
~/Development/example-contracts/docs/specifications/. Treat unimplemented
admin modules as planned gaps and cite source files for every implemented claim.
```

```text
$merge-customer-journeys-into-specifications

Merge docs/journeys/member-purchase.md into docs/specifications/SRS.md.
Preserve existing requirement IDs, add a traceability matrix, and leave
commercial conflicts as Requires Decision.
```

```text
$ux-system-analyzer

Compare the attached screenshots with ~/Development/example-admin/src.
Write both reports to ~/Development/example-admin and inventory every repeated
design-system violation before recommending edits.
```

```text
$create-commit-notes

Create .commits/1.2.0.txt from the previous documented tag. Include the exact
diff baseline, untracked release files, compatibility, deployment order, and
the commands that actually passed or failed. Do not commit or push.
```

### 4. Review the artifact, not just the chat response

The durable output is normally a Markdown or text file in the target project. Review:

- evidence and requirement traceability;
- assumptions and unresolved decisions;
- exact changed-file or recommendation inventory;
- security and privacy implications;
- stated implementation status;
- validation commands and limitations; and
- whether the output path matches the selected workflow contract.

## Composing Workflows

### Existing product documentation chain

1. Use `$convert-docx-to-md` to normalize a reference specification or customer journey.
2. Use `$create-specifications-existing-projects` to establish the source-grounded current-state SRS.
3. Use `$merge-customer-journeys-into-specifications` to reconcile narrative journeys with that baseline.
4. Use `$create-technical-architecture` to derive the implementation and operational architecture.
5. Use `$deep-code-and-security-audits` after implementation to assess the delivered boundaries.

### UI alignment chain

1. Use `$ux-system-analyzer` with screenshots and the responsible UI repository.
2. Use `$code-analysis-recommendations` when a specific misalignment needs deeper execution-flow analysis.
3. Review and approve the recommendations before asking an implementation agent to edit code.
4. Validate the implementation with the target repository’s own lint, analysis, test, build, and visual QA process.

### Flutter typography maintenance

1. Confirm root-level prescaling in the exact Rider or Driver repository.
2. Use `$comment-out-non-performant-scalers` for the explicitly authorized directory only.
3. Review the occurrence ledger and scoped diff.
4. Run the target Flutter repository’s format check, analyzer, tests, and relevant build.

### Release governance

1. Finish implementation and validation in the target repository.
2. Use `$create-commit-notes` against a pinned previous version or tag.
3. Review mixed-deployment, migration, environment, and compatibility notes.
4. Commit, tag, push, or deploy only through a separately authorized release process.

## Skill Package Anatomy

A workflow package is centered on `SKILL.md`:

```text
workflow-name/
├── SKILL.md                 # Required workflow contract
├── agents/
│   └── openai.yaml          # Optional agent UI metadata/default prompt
├── references/              # Templates, standards, or domain guidance
├── scripts/                 # Optional deterministic helper utilities
└── assets/                  # Output templates or static resources
```

### `SKILL.md`

Every skill begins with YAML front matter:

```yaml
---
name: workflow-name
description: A trigger-focused description of when this workflow applies.
---
```

The body should then establish, as applicable:

- purpose and trigger conditions;
- agent role and decision boundaries;
- required inputs;
- repository discovery requirements;
- mutation and safety guardrails;
- ordered execution protocol;
- mandatory outputs and file naming;
- supporting resources to load;
- validation commands or evidence expectations; and
- completion/reporting criteria.

### `agents/openai.yaml`

Some packages include a small interface descriptor with a display name, short description, and default prompt. It improves discoverability but does not replace `SKILL.md` as the authoritative workflow.

### References, scripts, and assets

- `references/` contains material the agent should load when the workflow selects it, such as the SRS structure and journey traceability template.
- `scripts/` contains optional helpers. Scripts support the workflow; they do not override its guardrails.
- `assets/` contains templates or other resources intended to be copied or embedded in outputs.

## Project Structure

```text
spec-driven-design/
├── analysis-and-recommndations/
│   └── code-analysis-recommendations/
│       ├── SKILL.md
│       ├── assets/
│       ├── references/
│       └── scripts/
├── comment-out-non-performant-scalers/
│   ├── SKILL.md
│   └── agents/openai.yaml
├── convert-docx-to-md/
│   └── SKILL.md
├── create-commit-notes/
│   └── SKILL.md
├── create-specifications-existing-projects/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/srs-structure.md
├── create-technical-architecture/
│   └── SKILL.md
├── deep-code-and-security-audits/
│   └── SKILL.md
├── merge-customer-journeys-into-specifications/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/merge-traceability-template.md
├── ux-system-analyzer/
│   └── SKILL.md
├── guides/
│   └── ssh_public_ip_setup.md
└── README.md
```

`analysis-and-recommndations` retains its current historical spelling. Use the actual path when linking or synchronizing the nested skill.

## Repository-Specific Behavior

Not every workflow is fully generic. Read these constraints before reuse:

| Workflow | Current specialization |
| --- | --- |
| `code-analysis-recommendations` | Writes exactly two documents to `~/Development/ecoride/docs/ideas/<month>/` and uses Ecoride-oriented naming conventions. |
| `create-commit-notes` | Explicitly models version sequences and `.commits` formatting across Ecoride API, Driver, Rider, Admin, and Website repositories. |
| `create-release-listing-summaries` | Formats abstract Android (5 points) and iOS (12 points) app store release notes in `builds/<app>-<version>-listing.md` without low-level code details. |
| `comment-out-non-performant-scalers` | Applies only to a confirmed Flutter/Dart source tree whose theme-root typography scaling has been verified. |
| `create-specifications-existing-projects` | Project-general at its core, with additional Afriflex repository-role guidance. |
| `merge-customer-journeys-into-specifications` | Project-general at its core, with detailed Afriflex SACCO/BNPL and USSD reconciliation rules. |
| `ux-system-analyzer` | Assumes screenshots plus inspectable UI source and currently emphasizes JSX/HTML/CSS/Tailwind design-system patterns. |
| `create-technical-architecture` | Project-general, calibrated to the depth and systems-thinking standard of Ecoride architecture documents. |
| `convert-docx-to-md` | Generic DOCX/OOXML conversion with adjacent media extraction. |
| `deep-code-and-security-audits` | Generic subsystem audit contract whose claimed coverage must be backed by the actual tools and crawl evidence available in the target environment. |

When adapting a specialized workflow, change its name/description, paths, examples, domain rules, and output contract together. Do not leave hidden Ecoride or Afriflex assumptions inside a supposedly generic clone.

## Authoring and Maintaining Skills

### Create or revise a workflow

1. Define one bounded job and a precise trigger description.
2. State whether the workflow is read-only, document-writing, or source-editing.
3. Identify required inputs and conditions that must stop execution.
4. Specify exact output files and whether existing documents are modified in place.
5. Require repository and instruction discovery before conclusions or edits.
6. Link only the references, scripts, and assets required for the job.
7. Include proportional validation and honest limitation reporting.
8. Test the workflow against a representative repository with existing uncommitted changes.
9. Confirm the installed agent copy matches the source-controlled copy.

### Quality checklist

- The folder name and YAML `name` agree.
- The description explains when the skill should trigger, not merely what it contains.
- Required files are referenced with paths relative to `SKILL.md`.
- Output paths are explicit and cannot be confused with the source workflow repository.
- Read-only analysis cannot silently become implementation.
- Destructive commands, secret handling, and dirty-worktree behavior are addressed.
- Examples use placeholders rather than credentials or production identifiers.
- “Complete,” “deterministic,” or “100%” claims require measurable evidence.
- The workflow names validation commands only after inspecting the target project’s actual toolchain.
- Optional `agents/openai.yaml` metadata remains consistent with the authoritative skill description.

### Versioning workflow changes

This repository currently has no separate package manifest or formal skill version field. Use Git history to review changes. For behavior-breaking revisions, document the changed output contract in the commit message and coordinate synchronization of installed copies.

## Safety and Evidence Rules

These rules apply across the library even when a skill is focused on documentation:

- Read every applicable `AGENTS.md` in the target repository before acting.
- Preserve existing uncommitted changes and keep unrelated diffs untouched.
- Never place credentials, tokens, private keys, production identifiers, or unnecessary personal data in generated artifacts.
- Treat client restrictions as UX, not authorization; security conclusions must verify server-side enforcement.
- Pin source evidence by file path, requirement source, or Git baseline wherever the workflow requires traceability.
- Do not invent APIs, database fields, implementation status, test results, citations, or repository commands.
- If a tool or environment cannot prove an audit claim, narrow the claim and document the limitation.
- Do not commit, tag, push, deploy, or open a pull request unless the user separately authorizes that external state change.

## Validation

This is a documentation/workflow repository, so validation focuses on package integrity rather than compilation.

### Inventory workflows

```bash
rg --files -g 'SKILL.md' | sort
```

### Check required front matter

```bash
for file in $(rg --files -g 'SKILL.md'); do
  sed -n '1,5p' "$file"
done
```

### Check local Markdown links and referenced paths

Review every relative Markdown link and every `references/`, `scripts/`, `assets/`, or `agents/` path introduced by a change. A workflow must not point to a missing resource.

### Check formatting and scope

```bash
git diff --check
git status --short
git diff -- README.md path/to/changed/workflow/
```

There is currently no repository-level Markdown linter, test runner, build script, or CI configuration. Do not claim those checks passed unless they are added and executed.

## Operational Guide

[`guides/ssh_public_ip_setup.md`](guides/ssh_public_ip_setup.md) is a standalone Linux operations guide covering OpenSSH installation, firewall configuration, router port forwarding, external connectivity testing, SSH keys, password-login disabling, and Fail2ban.

It is not an invokable skill. Follow its warning and prefer private networking, VPN, or identity-aware access where available instead of exposing SSH directly to the public internet.

## Contributing

When contributing a workflow:

1. Keep the change focused on one agent capability or one coherent revision.
2. Preserve existing packages unless the change explicitly updates their behavior.
3. Include all referenced templates and descriptors in the same change.
4. Explain project-specific assumptions in the skill and in this README catalogue.
5. Validate paths, front matter, Markdown, and the target workflow against a realistic prompt.
6. Review `git diff` before handing off; do not include `.DS_Store`, generated output, target-project documents, or secrets.

## License

No license file is currently present. Add an explicit license before treating the workflows as generally redistributable or accepting third-party contributions under defined terms.

## Author

- **Mr. Paul Namalomba** — [GitHub](https://github.com/paulnamalomba) | [Email](mailto:paul.namalomba-cio@computemore.com) | [LinkedIn](https://www.linkedin.com/in/paulnamalomba/) | [Portfolio](https://paulnamlaomba.github.io/)

