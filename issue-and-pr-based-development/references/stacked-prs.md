# Stacked pull requests

Load when tasks form a dependency chain in one repository, or when opening, updating or cleaning up a stack. Placeholders as in [SKILL.md](../SKILL.md#placeholders).

Source: GitHub Docs, [Stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/stacked-pull-requests) and the [`gh stack` command reference](https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands).

## Concepts

| Term | Meaning |
| --- | --- |
| Stack | Two or more PRs in one repository, each built on the one below it. GitHub treats the chain as one unit. |
| Trunk | The stack's base branch, usually `<default>`; it can be another branch, such as a release branch. |
| Layer | One PR in the stack: one focused change of one or more commits. In this workflow, one layer is one issue. |
| Bottom PR | The first layer. It targets the trunk. |
| Top PR | The last layer. |
| `<lower>` | The branch of the layer directly below. Each PR targets it, so each PR diff shows only its own layer. |

Example, with each issue as one layer:

| Layer | Issue | Branch | PR base |
| --- | --- | --- | --- |
| Bottom | #41 | `<owner>/auth-schema` | `<default>` |
| Middle | #42 | `<owner>/auth-api` | `<owner>/auth-schema` |
| Top | #43 | `<owner>/auth-ui` | `<owner>/auth-api` |

What GitHub does for a stack:

- Branch protection, CODEOWNER approval and required checks of the trunk apply to every layer, middle layers included.
- CI workflows triggered by PRs to the default branch run for every layer, not only the bottom one.
- The merge box shows a stack map: every layer, its status and links between layers.
- After the bottom PR merges, the remaining branches are rebased and retargeted to the trunk automatically.
- Merge commit, squash and rebase all work. Stacks are merge-queue aware.

Limits: all branches must be in the same repository; cross-fork and cross-repository stacks do not exist. GitHub Desktop does not support stacks.

## When to stack

Stack when:

- tasks from the plan's dependency graph form a chain in one repository, and a later task needs code from an earlier one;
- waiting for each PR to merge before starting the next would block work;
- one large change would otherwise land as one PR too large to review well.

Do not stack:

- independent tasks. Give each its own PR against `<default>`; a stack would force a merge order that does not exist;
- work in different repositories. Use a cross-repository follow-up issue instead (SKILL.md, Issue hygiene);
- a single XS or S task with no dependants.

Layering rule: if code in one layer depends on code in another, the dependency is in the same layer or a lower one. Put foundations (shared types, schema, contracts) low and dependants (endpoints, UI, tests of the whole slice) high. Start a new layer when the concern changes or when the layer grows past size M.

## Prerequisites

Run once per machine, by the orchestrator:

```bash
gh --version                          # 2.90.0 or later (2.103.0 or later for issue artifacts)
git --version                         # 2.36 or later
gh extension install github/gh-stack  # upgrade later with: gh extension upgrade stack
```

Stacked PRs must be enabled for the repository. A `gh stack` command that exits with code 9 means they are not. Stop and ask the owner. If the owner does not enable them, use the [fallback](#fallback-without-stacks).

## Plan the stack

1. In `tasks/plan.md`, name each stack and list its layers bottom first, with their issue links.
2. In each layer's issue, fill the **Stack** line of the [task template](templates.md#task-issue) and keep the **Dependencies** line (`Blocked by #<lower issue>`).
3. A layer can move to Ready when every dependency is merged or is a lower layer of the same stack with its acceptance criteria complete.
4. Assign identifiers that must be unique (migration numbers, ports) per layer before any agent starts.

## Agents on layers

Agents commit locally only. They never run the `gh stack` commands that touch the remote (`submit`, `push`, `sync`, `link`, `merge`, `unstack`) and never use `gh stack` to edit PRs.

Sequential layers (default): one agent builds the layers bottom-up in one worktree.

```bash
git fetch origin
git worktree add ../<repo>-<stack> -b <owner>/<work-1> origin/<default>
# after layer 1 is committed:
git switch -c <owner>/<work-2>        # from the tip of <owner>/<work-1>
```

Parallel layers: an agent can start layer k+1 once layer k is committed locally. Branch it from the lower branch:

```bash
git worktree add ../<repo>-<work-2> -b <owner>/<work-2> <owner>/<work-1>
```

If the lower layer changes later, the orchestrator cascades the change with `gh stack rebase`. The agent on the upper layer does not rebase by itself.

Git checks out a branch in only one worktree at a time. Before any stack operation that rebases branches, run `git worktree list` and remove the finished agents' worktrees, or detach them, so no stack branch is checked out elsewhere.

## Orchestrator: open the stack

Run from one worktree, after every layer's agent has reported.

1. Review each layer against its issue. Diff each layer only against the layer below:

   ```bash
   git diff origin/<default>...<owner>/<work-1>     # bottom layer
   git diff <owner>/<work-1>...<owner>/<work-2>     # each higher layer
   ```

2. Adopt the branches as a stack, bottom first, and rebase the whole stack onto the latest trunk:

   ```bash
   git fetch origin
   gh stack init --base <default> <owner>/<work-1> <owner>/<work-2> <owner>/<work-3>
   gh stack rebase
   ```

3. Regenerate generated artefacts layer by layer, bottom first. Commit them in the layer that owns the change, then cascade upwards and re-validate every layer:

   ```bash
   gh stack bottom
   <regenerate>; git commit -am "<message>"
   gh stack rebase --upstack
   gh stack up                       # repeat for each layer
   ```

4. Push every branch and open the linked PRs as drafts. `--auto` skips the editor, so it works without a terminal:

   ```bash
   gh stack push
   gh stack submit --auto
   gh stack view --json              # PR number and URL per branch
   ```

5. Replace each generated PR body with the [PR template](templates.md#pull-request), including `Closes #<i>` for that layer's issue only:

   ```bash
   gh pr edit <owner>/<work-1> -R <org>/<repo> --title "<title>" --body-file <pr-body-1.md>
   ```

6. Mark the layers ready for review: `gh pr ready <pr> -R <org>/<repo>` for each, or `gh stack submit --open` for all.
7. Move each layer's item to In review.

PRs that already exist can be joined into a stack instead: `gh stack link <pr-1> <pr-2> <pr-3>`, bottom first. To add layers on top of an existing stack: `gh stack link <stack-number> <pr-or-branch> ...`.

## Review feedback and changes

- Fix a defect in the layer that owns it. Never fix a lower layer's defect inside a higher layer.
- Go to the layer (`gh stack checkout <pr-number>`, `gh stack down`, `gh stack up`), commit the fix, then cascade and push:

  ```bash
  gh stack rebase --upstack
  gh stack push
  ```

- To pick up new commits on the trunk: `gh stack sync`. It fetches, rebases the stack and pushes.
- Conflicts stop the cascade with exit code 3. Resolve them, then `gh stack rebase --continue`, or restore everything with `gh stack rebase --abort`.
- Reorder, drop or rename layers only with `gh stack modify`. If you abort, `gh stack modify --abort` restores the stack. Update the issues, plan and board to match.

## Merging

Merging is the owner's decision (SKILL.md, Ownership and safety). The orchestrator never runs `gh stack merge` and never merges a layer in the web UI or through the API.

What the owner should know before merging:

- Layers merge bottom-up. The whole stack does not have to merge at once.
- Merging a layer also merges every layer below it. Merging the top PR merges the whole stack. Authorising one layer authorises every unmerged layer under it.
- Layers above a merged layer stay open and retarget to the trunk automatically.
- The resulting history is the same as merging each PR on its own, bottom first.

After a merge, the orchestrator:

1. runs `gh stack sync --prune`, which rebases the open layers onto the trunk and deletes local branches of merged PRs;
2. checks that each merged layer's issue closed. If one stayed open, post the [closing evidence](templates.md#closing-evidence) and close it;
3. removes the worktrees of merged layers (`git worktree remove ../<repo>-<work>`).

Use `gh stack sync --accept-base-change` or `gh stack rebase --accept-base-change` only after the owner confirms that the retarget to a new base was intended.

To dissolve a stack without merging (the owner decides): `gh stack unstack <stack-number>` removes it on GitHub and locally; `--local` removes only local tracking. Then retarget or close each PR on its own.

## Exit codes

| Code | Meaning | Action |
| --- | --- | --- |
| 2 | Not in a stack, or stack not found | Check the branch; `gh stack view`. |
| 3 | Rebase conflict | Resolve, then `--continue`, or `--abort`. |
| 4 | GitHub API failure | Retry after a pause; report if it persists. |
| 6 | Branch belongs to several stacks | Name the stack number explicitly. |
| 7 | Rebase already in progress | Finish or abort it first. |
| 8 | Stack locked by another process | Another orchestrator is working on it. Wait; do not force. |
| 9 | Stacked PRs not enabled for this repository | Stop and ask the owner; see the fallback. |
| 10 | Modify session interrupted | Recover with `gh stack modify --continue` or `--abort`. |

## Fallback without stacks

If the owner does not enable stacked PRs, or the tracker is not GitHub:

- open dependent PRs one at a time against `<default>`, each after the PR below it merges;
- keep `Blocked by` links on the issues, and keep dependent items in Backlog until the dependency merges;
- do not chain plain PRs on each other's branches. Without stacks, branch protection and CI apply only to the PR that targets `<default>`.
