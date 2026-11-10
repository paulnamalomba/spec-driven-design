---
name: issue-and-pr-based-development
description: Run development transparently through a project board, issues and pull requests, with a human owner and AI agents working in parallel. Use when a plan must become tracker issues, when setting up or bulk-populating a GitHub Project (v2), when orchestrating agents on branches and worktrees, or when writing issues, PRs, agent briefs and closing evidence.
---

# Issue- and PR-Based Development

## Overview

Every unit of work is visible as a board item, an issue in the repository that owns the code, a branch, and a PR that closes the issue. Agents implement. An orchestrator (a lead agent or person) reviews and opens PRs. The human owner approves and merges. The board is the single source of status and history.

Defaults: GitHub Projects (v2) and the `gh` CLI. For other trackers, see [references/github-projects.md](references/github-projects.md#other-trackers).

**Mode:** writes to trackers (issues, project items, comments) and to Git (branches, commits, PRs). It never merges, tags or releases. It writes externally only within the authorisation in [Ownership and safety](#ownership-and-safety).

## When to Use

- A plan or spec must become tracked, reviewable work.
- Several agents work in parallel on one or more repositories.
- The owner wants every change to pass through an issue and a PR.

**When NOT to use:** a one-off local fix the owner does not want tracked, or a repository without a remote tracker.

## Placeholders

| Placeholder | Meaning |
| --- | --- |
| `<org>` | Account or organisation that owns the repository and project (`gh --owner`). |
| `<repo>` | Repository name; `<org>/<repo>` for `gh -R`. |
| `<n>` | Project number, from the project URL. |
| `<owner>` | Handle of the human or agent that owns a branch. |
| `<work>` | Short kebab-case name of the work, such as `<slug>`. |
| `<default>` | The repository's default branch. |
| `<i>` | Issue number. |

## Inputs and stop conditions

Read first: the target repository's `AGENTS.md` or `CLAUDE.md`, its contribution and attribution rules, and the plan.

Stop and ask when:

- no tracker or project is designated;
- `gh auth status` lacks the `project` scope (only the owner can refresh it);
- a task has no acceptance criteria or no verification command;
- the work tree holds changes you did not make and the operation needs a clean tree;
- an action needs authorisation you do not have.

## 1. From plan to tracker

1. Run [`planning-and-task-breakdown`](../planning-and-task-breakdown/SKILL.md) with the tracker as its **task list target**.
2. Create one issue per task in the repository that owns the code. The body carries acceptance criteria, verification commands, dependencies, likely files and size. Use the [task template](references/templates.md#task-issue).
3. Add each issue to the project and set Status, Size and the custom fields.
4. Represent each checkpoint as a draft item whose body is the checkpoint checklist. The owner moves it to Done.
5. Record finished milestones as draft items with Status Done. Link their release or build notes in the body, so the board shows history.
6. Keep `tasks/plan.md` as an ordered index of item links, not a duplicate checklist.

## 2. Project setup

Status flow and who moves each status:

| Status | Meaning | Moved there by |
| --- | --- | --- |
| Backlog | Captured; not approved or blocked by a dependency. | Anyone creating the item. |
| Ready | Approved; dependencies merged; acceptance criteria complete. | Owner. |
| In progress | Claimed by one agent on one branch. | Orchestrator, when it assigns the brief. |
| In review | PR open with `Closes #<i>`. | Orchestrator, after opening the PR. |
| Done | PR merged or item otherwise closed with evidence. | Built-in workflow on merge or close, or owner. |

Fields: Status (rename the built-in options in project settings), Size (single-select `XS`, `S`, `M`, `L`; split anything larger) and custom single-selects such as Component, Phase and Module.

Token scope, run once by the owner:

```bash
gh auth refresh -h github.com -s project   # -h is required when non-interactive
gh auth status                              # confirm 'project' in token scopes
```

Commands for fields, items and IDs: [references/github-projects.md](references/github-projects.md#commands).

## 3. Bulk population

Populate from one spec file through an idempotent script that keeps a state file:

- Dry-run first; it prints what it would create and writes nothing.
- Validate every field and option name against `gh project field-list` before the first write.
- Pace API calls (a short sleep per call) to stay under secondary rate limits.
- Record each created issue and item ID in the state file at once. Re-runs skip recorded items and finish partial ones.

Spec format and script skeleton: [references/github-projects.md](references/github-projects.md#bulk-population).

## 4. Branches, worktrees and agents

- Name branches `<owner>/<work>`. Give each agent one worktree:

  ```bash
  git fetch origin
  git worktree add ../<repo>-<work> -b <owner>/<work> origin/<default>
  ```

- Agents commit locally only. They never push, open PRs or edit board status.
- The orchestrator, per finished branch:
  1. reviews the diff against the issue (`git diff origin/<default>...<owner>/<work>`);
  2. rebases onto the latest default branch (`git fetch origin && git rebase origin/<default>`);
  3. regenerates generated artefacts (schemas, clients, lockfiles) and re-validates the combined state;
  4. pushes (`git push -u origin <owner>/<work>`; `--force-with-lease` only if already pushed);
  5. opens a PR whose body contains `Closes #<i>` (cross-repository: `Closes <org>/<repo>#<i>`);
  6. moves the item to In review.
- The human reviews and merges.
- Release notes and tags follow merges. Batch them when several PRs merge together.
- Remove a worktree after merge: `git worktree remove ../<repo>-<work>`.

## 5. Agent briefs

- Keep the prompt short. Point it at a brief file and the agent's task list; never paste their content into the prompt.
- Each brief names: the issue, the branch and worktree, files in scope, acceptance criteria, verification commands, pre-assigned identifiers, and the report format.
- Give agents machine checkers (coverage, link check, schema staleness, lint) so they verify themselves before reporting.
- Require the fixed [report format](references/templates.md#agent-report). Failed runs, reruns and flakes are reported as they happened.

## 6. Concurrency hygiene

- Assign scarce identifiers before agents start: migration numbers, ports, database names, fixture IDs.
- Serialise heavy test runs with a shared `mkdir` lock (atomic on local file systems):

  ```bash
  lock=/tmp/<slug>-tests.lock
  until mkdir "$lock" 2>/dev/null; do sleep 15; done
  trap 'rm -rf "$lock"' EXIT
  echo $$ > "$lock/pid"
  <heavy test command>
  ```

  A lock whose `pid` is not alive (`kill -0 "$(cat "$lock/pid")"` fails) is stale; remove it.
- A failure that is only a timeout under contention is not a code failure. Rerun it solo under the lock before reporting it as one.
- Run memory-heavy validation (full builds, browser suites, container stacks) serially.
- In `pgrep -f` and `pkill -f`, write the pattern with the bracket trick, such as `'[d]otnet test'`, so it never matches its own command line. Never `pkill -f` a pattern that also matches your own shell, script or SSH session. List with `pgrep -af '<pattern>'`, then kill by PID.

## 7. Issue hygiene

- One defect or task per issue: reproduction, severity, observable definition of done. Use the [defect template](references/templates.md#defect-issue).
- A defect found during other work gets its own issue. Do not fix it silently inside an unrelated PR.
- Cross-repository impact becomes a follow-up issue in the other repository. Keep it in Backlog until the dependency merges, then the owner moves it to Ready.
- Close with an evidence comment: commit SHA, CI run URL, tests run and results. Use the [closing template](references/templates.md#closing-evidence).

## 8. PR hygiene

- Body order: summary, decisions for the reviewer, validation actually run, limits and follow-ups. Use the [PR template](references/templates.md#pull-request).
- Link the issue with `Closes #<i>`. No unrelated changes.
- Follow the team's attribution policy. Omit tool or AI footers and session links when the team declines them.

## Ownership and safety

- Never commit, discard or reformat someone else's uncommitted work.
- Stash only around an operation that needs a clean tree. Verify restoration by hash, and drop the stash only after a match:

  ```bash
  dirty_hash() {
    git status --porcelain --untracked-files=all | cut -c4- | sort |
      while IFS= read -r p; do
        printf '%s %s\n' "$(git hash-object -- "$p" 2>/dev/null || echo gone)" "$p"
      done | shasum -a 256
  }
  before=$(dirty_hash)
  git stash push -u -m "<work>-guard"
  <operation>
  git stash apply && [ "$(dirty_hash)" = "$before" ] && git stash drop
  ```

  On a mismatch or conflict, stop. Keep the stash and report it.
- No secrets, tokens, customer data or internal hostnames in issues, PRs, comments or pasted logs. Redact before posting.
- Authorisation:
  - Creating issues and items, pushing work branches and opening PRs need the owner's standing approval of this workflow.
  - Merge, tag, release and deploy need the owner's explicit authorisation for that change.
  - The PR is the gate. Never merge your own PR.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "It's a two-line fix; an issue is overhead." | Untracked fixes vanish from history and review. A small issue costs a minute. |
| "I'll fix this unrelated bug while I'm here." | It hides in a PR about something else. File it separately. |
| "The agent said tests pass." | Without the command, output and run URL, it is a claim, not evidence. |
| "The test timed out; the code must be broken." | Under contention, rerun solo first. |
| "I'll paste the spec into the prompt so the agent has it." | Pasted context drifts from the file. Point at the file. |
| "I'll stash their changes and put them back later." | Unverified restores lose work. Hash before and after. |
| "The PR is approved in spirit; I'll merge it." | Merging is the owner's decision. |
| "Re-running the population script is safe enough." | Without a state file it duplicates issues. |

## Red Flags

- An agent pushes, opens a PR or changes board status.
- A PR without `Closes #<i>`, or one PR closing several unrelated issues.
- Items In progress with no branch, or In review with no PR.
- An issue closed without an evidence comment.
- Two agents holding the same migration number or port.
- A failure reported as a code defect after only a contended run.
- `pkill -f` with an unbracketed pattern from inside a script.
- A stash dropped before its restoration was verified.
- Secrets or internal hostnames in an issue, PR or log excerpt.
- A bulk script run with `--apply` before a dry run.

## Verification

Before handing a change set to the owner:

- [ ] Every task is one issue in the owning repository with acceptance criteria, verification and size.
- [ ] Every issue is on the board with correct Status and fields.
- [ ] Checkpoints and finished milestones are board items; the plan indexes item links.
- [ ] Each branch is `<owner>/<work>`, rebased on the latest `<default>`, with generated artefacts current.
- [ ] Each PR contains `Closes #<i>`, the four body sections and no unrelated changes.
- [ ] Validation listed in each PR was run, with failures and flakes reported.
- [ ] Follow-up issues exist for defects found and cross-repository impact.
- [ ] No uncommitted work of others was changed; any stash was verified and dropped.
- [ ] No secrets in tracker or PR text.
- [ ] Nothing was merged, tagged or released without the owner's authorisation.
