# Frontend internal versions and releases

Read the frontend and suite `AGENTS.md` first. `FRONTEND_INTERNAL_VERSION` owns the independent SESKAFEM workbench counter. Every field in `<breaking>.<major>.<minor>.<build>` has exactly one digit, 0–9. Carries reset following fields: `0.1.0.9 -> 0.1.1.0`, `0.1.9.9 -> 0.2.0.0`, `0.9.9.9 -> 1.0.0.0`. Stop at `9.9.9.9`.

Only successful artifact production and all declared acceptance checks advance the accepted version. Failed, cancelled, validation-only, documentation-only and no-op work leave it unchanged. Reserve a candidate before embedding it; retain the actual source commit, acceptance commit, evidence and artifact hashes separately. Never relabel an old artifact. Keep every earlier acceptance gate and record explicit qualification limits.

Group notes in `.commits/<breaking>.<major>.<minor>.md`. Use a product heading, baseline, chronological progression table, detailed changes, actual verification, artifact/evidence links, compatibility and remaining limits. Continue historical `.txt` notes by link without rewriting them. An unbuilt entry must say that it advances no counter.

The first accepted build in each new three-part family requires an immutable annotated `v<family>` tag and release on the owned frontend remote. The tag targets the published acceptance commit and retains that build's Markdown note snapshot. The release identifies the full four-part version, built source, acceptance record and immutable artifact hashes. Later builds never move the family tag or replace its original assets. No historical backfill is implied. Preserve native/backend/PETSc release namespaces and policies.

Publish reviewed implementation source first. Run full local acceptance, publish its metadata/counter/notes, create the family release if required, and only then advance the suite gitlink/documentation. A failed publication resumes the same accepted identity; it does not authorize another version increment.

Frontend GitHub CI remains paused by user direction until explicitly resumed. Local acceptance does not qualify hosted CI. Writing this note grants no additional build, commit, tag, publication or CI permission.
