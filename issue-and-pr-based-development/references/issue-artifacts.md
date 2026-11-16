# Issue artifacts

Load when attaching a plan, brief, research note, prototype or link to an issue, or when syncing one after its source file changed. Placeholders as in [SKILL.md](../SKILL.md#placeholders).

Source: GitHub Docs, [Using artifacts with issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/using-artifacts-with-issues) and the [`gh issue artifact` manual](https://cli.github.com/manual/gh_issue_artifact).

## What they are

Issue artifacts are named pieces of content attached to an issue. They stay with the issue as context, have their own URL, and keep a version history. The feature is in preview and may change. They are not GitHub Actions artifacts (`gh run download`).

| Type | Use in this workflow |
| --- | --- |
| `plan` | `tasks/plan.md`, or a task's own implementation plan. |
| `generic` | Agent brief, research or investigation notes, decision record. |
| `embedded_html` | A self-contained HTML prototype, diagram or visualisation. |
| `link` | A named link to a discussion, wiki page, prototype or chat thread. |

Rules:

- `gh issue artifact` needs GitHub CLI 2.103.0 or later. Check with `gh issue artifact --help`.
- The file in the repository stays the source of truth. The artifact is a published copy. Change the file, then sync the artifact.
- Editing creates a new version; history is kept. Restore with `gh issue artifact edit <i> <a> --restore-version <version>`, which saves the old content as a new version.
- Never delete an artifact to replace it. Deletion is permanent and removes its version history. Edit it instead.
- An artifact is as visible as its issue. No secrets, tokens, customer data or internal hostnames. Redact before attaching.
- HTML artifacts open in Source view. Preview only HTML from sources you trust: a preview runs its code, which can send content to external sites.
- The orchestrator creates and edits artifacts. Agents do not; they report, and the orchestrator attaches.
- Draft items are not issues and cannot carry artifacts. Put a checkpoint's checklist in the draft body.

## Plan artifact (with `planning-and-task-breakdown`)

When [`planning-and-task-breakdown`](../../planning-and-task-breakdown/SKILL.md) feeds the tracker, attach `tasks/plan.md` to each task issue as a `plan` artifact, unless the owner declines. Each issue then carries the plan's architecture decisions, risks and open questions as context, without pasting them into the body.

Order:

1. Create the task issues and board items (SKILL.md, section 1).
2. Rewrite the Task List section of `tasks/plan.md` as an ordered index of the item links.
3. Attach the plan to each task issue, with one fixed name:

   ```bash
   gh issue artifact create <i> -R <org>/<repo> \
     --body-file tasks/plan.md --name "Implementation plan" --type plan
   ```

4. Record the artifact number per issue, in the bulk-population state file when one is used:

   ```bash
   gh issue artifact list <i> -R <org>/<repo> --type plan --json number,name \
     --jq '.[] | select(.name == "Implementation plan") | .number'
   ```

5. When `tasks/plan.md` changes, sync every issue that carries it. Never create a second copy:

   ```bash
   gh issue artifact edit <i> <a> -R <org>/<repo> --body-file tasks/plan.md
   ```

The bulk-population script does steps 3 to 5 idempotently; see [github-projects.md](github-projects.md#bulk-population).

If the plan references images, upload them with the artifact: add `--attach <file>#<alt text>` to `create`, or run `gh issue artifact edit <i> <a> --attach <file>#<alt text>`. With only `--attach`, `edit` appends the image to the current content.

If the owner declines artifacts, or the CLI is older than 2.103.0, keep the `Plan:` link in the issue body only.

## Other artifacts

```bash
# Agent brief, after the brief file is final
gh issue artifact create <i> -R <org>/<repo> --body-file <brief path> --name "Agent brief" --type generic

# Research note or decision record
gh issue artifact create <i> -R <org>/<repo> --body-file <note.md> --name "<title>" --type generic

# HTML prototype or diagram
gh issue artifact create <i> -R <org>/<repo> --body-file <prototype.html> --name "<title>" --type embedded_html

# Named link
gh issue artifact create <i> -R <org>/<repo> <https-url> --name "<title>"

# Several files at once; '#<name>' names the artifact
gh issue artifact create <i> -R <org>/<repo> '<path/plan.md>#Implementation plan' <path/research.md>
```

Inspect and maintain:

```bash
gh issue artifact list <i> -R <org>/<repo> --json number,name,type,updatedAt
gh issue artifact view <i> <a> -R <org>/<repo>       # content and edit history
gh issue artifact edit <i> <a> -R <org>/<repo> --name "<new name>"
```

An artifact is also addressable by its URL: `gh issue artifact edit <artifact-url> --body-file <file>`. Link that URL from PRs or other issues instead of copying the content.
