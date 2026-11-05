# Depth and proportionality

Investigate deeply. Recommend proportionally. A deep trace that finds ten defects does not make all ten part of the fix.

This reference exists because an analysis of one local test limitation (a fresh migration replay that stopped at migration 004) produced a recommendations document that escalated into a new migration runner, a schema baseline snapshot, content-hash manifests and startup-blocking schema verification. None of that was needed for any customer-facing behavior. When it was implemented, the startup check rejected the production database and took the API offline. Every rule below prevents a step in that chain.

## 1. Classify impact before recommending anything

For each finding, state one class with its evidence:

| Class | Meaning | Evidence required |
| --- | --- | --- |
| Observed production failure | Users, data or operations are affected now | Logs, rows, error rates, a reproduced request |
| Latent defect | Wrong behavior that has not triggered, with a plausible trigger | The code path and the condition that triggers it |
| Tooling or environment gap | Affects local tests, fresh environments, CI or developer workflow only | The failing command and where it runs |
| Hygiene | Dead code, duplication, misleading comments or docs | The location |

Check whether runtime code actually depends on a finding before calling it impactful. For example, a missing index matters only if something writes or queries through it; search for the writers and readers. Say plainly when a finding has no runtime effect.

## 2. Tier the recommendations

The Fixes document must open with the **minimal sufficient fix**: the smallest change that resolves the problem the user actually raised. Then list the rest in tiers:

- **Required:** resolves the stated problem or an observed production failure.
- **Recommended:** cheap, low-risk removal of a latent defect (for example, deleting an error handler that records failure as success).
- **Optional:** hardening, re-architecture or new subsystems. Each item states its cost (files, lines, new maintenance obligations), its risk, and what would justify doing it later.
- **Not recommended now:** things considered and rejected, with the reason.

Do not label optional work as a "release gate" or "release readiness requirement" unless the user asked for that standard.

## 3. Separate investigation depth from change depth

- Stop the investigation when the root cause and the minimal fix are established and verified. Record further defects as findings, not as plan items.
- Treat a recommendation that adds a new subsystem, a new startup or deploy gate, a generated artifact over a few hundred lines, or changes to more than a handful of files as **optional by default**. Promote it only with explicit justification against the impact classes above.
- Prefer forward, local fixes over replacing the mechanism that has been working in production.

## 4. Blast radius for high-risk boundaries

For any recommendation that touches application startup, deployment, migrations, authentication, payments or data deletion, the Fixes document must state:

1. **What happens if it is wrong.** A fail-closed check at startup means an outage on every restart, not a logged warning.
2. **How it is verified against the artifact that will actually deploy**, not the working tree. Generated or packaged files can drift between the build and the last local edit.
3. **The rollback**: the exact previous image, tag or commit, and whether the change leaves state behind (for example, columns or tables a failed migration already committed).
4. **Ongoing obligations it creates**: manifests, hashes, snapshots or postcondition files that every future change must update, and what breaks if someone forgets.

If a recommendation re-checks a pinned snapshot (exact constraint text, function bodies, column types) on every startup, call out that every future schema change must update that snapshot, or startup fails after the change commits.

## 5. Required sections in the two documents

Add these to the standard templates:

- **CodeAnalysis.md:** an "Impact and necessity" section that classifies each finding (section 1), and states which findings have no runtime effect.
- **Fixes.md:** a "Minimal sufficient fix" section first, then the tiers (section 2), then a "Blast radius and rollback" section for any high-risk item (section 4).

## 6. When implementing someone else's Fixes document

Before implementing, re-read the tiers. If the document has no minimal-fix section or no impact classification, write one first and confirm the scope with the user. Implementing a recommendations document is not authorization to implement its optional tier.
