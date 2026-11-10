# Templates

Load when writing an issue, PR, closing comment, agent brief or agent report. Replace every `<placeholder>`. Delete a section only when it truly does not apply, and say so.

## Task issue

```markdown
<One paragraph: what this task delivers and why.>

## Acceptance criteria
- [ ] <specific, observable condition>
- [ ] <specific, observable condition>

## Verification
- `<focused test command>`
- `<build or lint command>`
- Manual: <what to check, where>

## Dependencies
- Blocked by <org>/<repo>#<i> (or "None")

## Likely files
- `<path>`

Size: <XS|S|M|L>
Plan: <link to tasks/plan.md or the plan item>
```

## Defect issue

```markdown
## Reproduction
1. <step>
2. <step>
Expected: <behaviour>
Actual: <behaviour, with the shortest decisive error line>
Environment: <commit SHA, runtime, configuration; no secrets or internal hostnames>

## Severity
<critical | high | medium | low>: <one-line impact>

## Definition of done
- [ ] <observable result, such as "request X returns 403 for role Y">
- [ ] Regression test `<test name>` fails before the fix and passes after.

Found while working on: <org>/<repo>#<i> (if any)
```

## Pull request

Title: `<imperative summary>`. Branch: `<owner>/<work>`.

```markdown
## Summary
<What changed and why, in two to four sentences.>

Closes #<i>

## Decisions for the reviewer
- <choice made, alternative rejected, reason>
- <anything the reviewer must confirm>

## Validation
- `<command>`: <pass | fail>, <counts or run URL>
- <flake or rerun, with solo-rerun result>
- Not run: <check> because <reason>

## Limits and follow-ups
- <known limitation>
- Follow-up: <org>/<repo>#<i>
```

Add attribution lines only as the team's policy says.

```bash
gh pr create -R <org>/<repo> --base <default> --head <owner>/<work> \
  --title "<title>" --body-file <pr-body.md>
```

## Closing evidence

Post before closing, or on the issue after the PR merges:

```markdown
Fixed in <commit SHA> via <PR URL>.
CI: <run URL>, <pass | fail>.
Tests: `<command>`: <counts>.
Definition of done: <each item, met or not>.
```

```bash
gh issue comment <i> -R <org>/<repo> --body-file <evidence.md>
gh issue close <i> -R <org>/<repo>    # only when no PR closes it
```

## Agent brief

Store as a file. The prompt only points at it: `Read <brief path> and <task-list path>. Work only on your tasks.`

```markdown
# Brief: <work>

Issue: <org>/<repo>#<i>
Worktree: <path>   Branch: <owner>/<work>   Base: origin/<default>
Read first: <AGENTS.md path>, <spec or plan path>

## Scope
- In: <files or modules>
- Out: <files or modules not to touch>

## Acceptance criteria
As listed in <org>/<repo>#<i>.

## Pre-assigned identifiers
- Migration number: <nnnn>; port: <port>

## Self-checks before reporting
- `<checker command>`
- Heavy tests only under the shared lock: <lock path>

## Rules
- Commit locally only. Do not push, open PRs or edit the board.
- Do not touch files you did not create or are not in scope.
- File a defect found outside scope as a note in your report.

## Report
Use the agent report format, nothing else.
```

## Agent report

Fixed format, at most ten lines:

```text
STATUS: done | partial | blocked
BRANCH: <owner>/<work> @ <short SHA>
CHANGED: <n> files: <paths or areas>
CHECKS: <command> -> pass|fail (<counts>); <command> -> ...
RERUNS/FLAKES: none | <test>, contended timeout, solo rerun pass|fail
NOT DONE: none | <criterion and reason>
FOUND: none | <defect, file:line, severity>
DECISIONS: none | <choice the reviewer must confirm>
```
