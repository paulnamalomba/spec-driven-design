# PETSc internal versions and build progression

Use this profile only for `petsc-native-windows` or a repository explicitly adopting its PETSc policy. Read that repository's `AGENTS.md` first; it owns the current requirements and `PETSC_INTERNAL_VERSION` owns the accepted counter.

## Version identity

The internal format is `<breaking>.<major>.<minor>.<build-number>`. Start at `3.27.0.0`, an unbuilt seed. The first qualifying build becomes `3.27.0.1`. Only this initial seed is unbuilt by definition; a later version ending in zero can record a successful rollover build.

Build numbers range from 0 through 99, minor from 0 through 9, major from 0 through 99. Each qualifying successful artifact-producing build and its required profile checks advances the version once. Carry increments the preceding field and resets following fields to zero. Explicit minor, major, or breaking decisions select a candidate family and reset its following fields; they do not change the accepted version until a qualifying build passes. Complete accepted versions, rather than the fourth field alone, progress monotonically. Keep upstream PETSc versioning independent.

Keep upstream PETSc's source commit, version macros, development/release flag, and ABI/library versioning separate. Do not overwrite them or append the internal build number to an upstream macro. Do not apply this version family to SESKA, the workbench, or the skill repository.

## What can advance a build number

A qualifying build produces artifacts and passes the declared compile/link, applicable installation/package stages, and the checks required for that selected configuration. Record the scope accurately: a limited smoke configuration does not establish complete native Windows, SESKA, numerical, deployment, or lifecycle support.

Failed, cancelled, skipped, configure-only, documentation-only, and no-op runs leave the accepted counter unchanged. Running a notes skill or editing an instruction file cannot create a successful build. If no qualifying build ran, explicitly state that fact and preserve the current accepted version.

When a build embeds its internal identity, the build workflow may reserve the next candidate before compilation. Accept the candidate only after verification, then persist `PETSC_INTERNAL_VERSION` and the matching build record together. Do not relabel unrelated old artifacts. Allocate counters consistently across branches/CI before publication; stop and resolve a conflicting accepted counter rather than publish duplicate build identities.

This skill records verified outcomes. Do not run builds or change counters merely to complete a note. If a requested note follows an already authorized successful build and its version metadata is stale, reconcile it against that build's actual evidence and local policy; never assume that a reported zero exit proves success.

## One note per release family

The output is `.commits/<breaking>.<major>.<minor>.txt` in the PETSc fork. Versions `3.27.0.1` and `3.27.0.2` share `.commits/3.27.0.txt`. Do not create one note per fourth-field value. Invoke this workflow at seed initialization and every minor, major, or breaking change, including an automatic carry.

Append chronological build records without deleting or collapsing earlier transitions. Preserve multiple successful builds made before a commit. A new release-family file links the preceding family's note and records the complete rollover, including numeric `99 -> 0`. Failed or unbuilt attempts retain the accepted version and record a separate candidate.

Illustrative transitions, not actual build results:

| Event | Previous accepted version | New accepted version | Note |
| --- | --- | --- | --- |
| First qualifying build | 3.27.0.0 | 3.27.0.1 | `.commits/3.27.0.txt` |
| Another qualifying build | 3.27.0.1 | 3.27.0.2 | Append to `.commits/3.27.0.txt` |
| Failed or documentation-only work | 3.27.0.2 | 3.27.0.2 | Record no counter advance |
| Build rollover | 3.27.0.99 | 3.27.1.0 | `.commits/3.27.1.txt`; record `99 -> 0` |
| Minor rollover | 3.27.9.99 | 3.28.0.0 | `.commits/3.28.0.txt` |
| Major rollover | 3.99.9.99 | 4.0.0.0 | `.commits/4.0.0.txt` |

## Required note content

Use the repository's plain-text style and a PETSc-specific header. Include:

1. Release family, current accepted four-part version, note date, authoritative version file, upstream PETSc version/release flag and commit, and the preceding accepted build/note.
2. Diff baseline and exact scope. Identify the source commit used for the build, or its base commit plus the recorded patch/worktree identity. Do not claim a future commit SHA or require a note to contain the hash of the commit that contains itself.
3. Technical changes to configuration, subprocess/path handling, compiler adapters, generated source/header selection, native Ninja rules, library/MPI/math integration, or tests, with actual affected symbols/files. Include scientific/API behavior changes only when source and validation establish them.
4. A chronological build-progression table with UTC time, outcome, complete previous and accepted versions, numeric counter transition, selected profile, and evidence locations. A failed candidate must show an unchanged accepted counter.
5. For every successful transition, a detailed record of:
   - OS/CPU and user-selected `PETSC_ARCH`; exact C/C++/Fortran compiler, linker/toolset, Windows SDK, Python/build-tool versions, and source/dependency/patch pins.
   - MPI runtime/SDK and launcher, oneMKL/provider selection, sparse/BLAS integer widths, precision/scalar kind, debug/static/shared choices, solver adapters, and any relevant rank/thread budget.
   - Actual configure, build, install/package, and test command arguments, working directory and relevant environment, exit statuses, and the checked values or assertions. Do not include credentials or unrelated environment secrets.
   - Artifact names/locations and checksums or an immutable artifact manifest, associated logs/test reports, and source identity. Record evidence that is absent as absent rather than inventing a checksum or test result.
   - Explicit limitations and open gates. Distinguish compile/link smoke checks from MPI execution, sparse-solver tests, numerical cases, clean-machine installation, and process-tree completion.
6. Compatibility/deployment effects, code files touched, remaining work, and failed/unbuilt attempts relevant to this change.

Respect the local `PETSC_ARCH` requirement. Writing a note does not authorize selecting a new architecture, configuring PETSc, running its executables, or building its documentation.

## Consistency check before completion

- The note filename has exactly the three numeric family fields; accepted internal versions have four numeric fields.
- The latest successful note entry equals `PETSC_INTERNAL_VERSION`; subsequent failed/unbuilt entries leave that accepted value unchanged.
- Every accepted build follows the arithmetic above and the prior recorded success, including carries across family files. Do not invent missing historical successes to conceal a gap. Explicit release decisions require their own recorded rationale.
- No successful build is claimed from a source inspection, imported binary, configure-only run, documentation validation, no-op build, or unsupported exit-only assertion.
- Existing progression records remain intact, and candidate, accepted internal, and upstream version identities remain distinct.
