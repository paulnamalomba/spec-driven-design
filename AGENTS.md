# AGENTS.md

## Skill source ownership

This repository owns the `spec-driven-design` skills. Edit each skill's source here; installed skill directories may be symbolic links to these sources. Preserve unrelated skills, repository profiles, and existing invocation/permission rules.

Before changing a skill, read its `SKILL.md` and applicable references. Keep the entry point concise; place substantial repository-specific rules in a linked reference that is loaded only for that profile. Preserve valid YAML metadata and validate changed skills with the available skill validator. Documentation checks do not authorize application builds, commits, or publication.

## Commit-note version profiles

`create-commit-notes` supports the existing Ecoride conventions and the PETSc native Windows fork's separate profile. Resolve the target repository's local `AGENTS.md` and version metadata first; do not apply one project's version scheme to another.

SESKA/seskafeabackend also has its own profile: SESKA_INTERNAL_VERSION starts at the user's historical 1.0.0.17, with no invented historical build evidence. It uses the same bounded four-part arithmetic and three-part note grouping, but an independent counter. Read create-commit-notes/references/seska-versioning.md. Invoke notes at initialization and every minor/major/breaking transition, and preserve every accepted build progression. The release script never changes versions; successful build acceptance does.

For `petsc-native-windows`, the internal version format is `<breaking>.<major>.<minor>.<build-number>`, starting with the unbuilt seed `3.27.0.0`. Successful artifact-producing builds and required profile checks advance once; failed, skipped, configure-only, documentation-only, and no-op runs do not. Build ranges 0–99, minor 0–9, major 0–99; carry resets following fields to zero. Examples: `3.27.0.99 -> 3.27.1.0`, `3.27.9.99 -> 3.28.0.0`, `3.99.9.99 -> 4.0.0.0`. Only the initial seed is unbuilt by definition; later zero builds require normal success evidence. Invoke `create-commit-notes` at seed initialization and every minor/major/breaking change. Upstream PETSc macros and ABI identity remain separate.

PETSc note filenames omit the fourth field: `.commits/<breaking>.<major>.<minor>.txt`. Every such note preserves chronological full-version/build-counter transitions, source and upstream identities, selected build profile, toolchain/dependency pins, exact commands and actual verification, artifacts/evidence, and remaining limitations. Never manufacture successful builds or advance a counter merely to write notes. See [the PETSc profile](create-commit-notes/references/petsc-versioning.md).

If this skill repository later produces a versioned distributable, establish its own version source and increase its build number only after a successful artifact-producing build and required checks. Ordinary skill prose validation does not create an application build or advance PETSc's version.

## Shared instruction entry points

`CLAUDE.md`, `ANTIGRAVITY_INSTRUCTIONS.md`, and `GEMINI.md` reference `@AGENTS.md`. Keep substantive instructions here; explicitly read this file when imports are not expanded.
