# SESKA internal versions and build evidence

Read the backend repository's AGENTS.md first. SESKA_INTERNAL_VERSION owns its independent `<breaking>.<major>.<minor>.<build-number>` identity. The user declared 1.0.0.17 as the historical starting identity; this does not prove a reproduced historical build. The first new qualifying candidate is 1.0.0.18. Never apply PETSc's 3.27 family to SESKA.

Build ranges 0–99, minor 0–9, major 0–99. Carry resets following fields: 1.0.0.99 -> 1.0.1.0; 1.0.9.99 -> 1.1.0.0; 1.99.9.99 -> 2.0.0.0. Later rollover build zero is valid when supported by normal acceptance evidence. Invoke this skill at initialization and every minor, major or breaking transition, including automatic carries.

Use `.commits/<breaking>.<major>.<minor>.md`. Append every successful full version transition, including multiple builds before one Git commit. Each accepted build records UTC, previous/candidate/accepted versions, source commit or base-plus-patch/tree identity, platform/profile, compiler and dependency pins, actual configure/build/test/package commands, required checked values, artifact hashes and retained evidence, plus the capabilities that remain unverified. Distinguish an engine profile from ABI-only probes, hosted relocation from clean-host deployment, and cross-platform agreement from an analytical benchmark.

Record failed, cancelled, configure-only, validation-only, documentation-only and no-op attempts without increasing the accepted counter. Notes never authorize a build or fabricate one. Trusted build acceptance owns the counter; the repository management script only reads it. Its -Version must equal the version file. Preserve chronological records and immutable build evidence; do not relabel an unrelated old executable.

Short generated Git messages summarize each change. Version tags retain the family-note snapshot; later note growth never changes an existing tag. Creating notes does not itself authorize a commit, tag or push.

The current product uses one pinned PETSc fork source across Windows, Linux and macOS. Modern Linux supplies new numerical references. Legacy build/comparison checks were excluded by the user's 16 October 2026 decision; do not reintroduce them as an acceptance requirement. 