---
name: multi-opinion
description: Trigger this if the user says 'multi-opinion'.
---

# Council

## When to Apply

When a user desires deep research about a bug, feature or review of a diff or an entire branch.

## Core Mindset: Seamless Coordination

Before an audit, address outstanding PR comments, fix known issues, and run relevant checks. Give council the updated implementation; do not defer known fixes until reviews return. If the user wants to discard the implementation and explore new ideas, skip fixes to code being replaced.

## Best Practices

Bring in four delegates to help with the user's request, usually for research, review or feedback via the following matrix:
- 1 fable high
- 1 opus high
- 2 Gemini Flash 3.8 high 
  - via `/antigravity:research` for research tasks 
  - via `/antigravity:handoff` for implementation, analysis and review

If the user's instructions name council members, use those. Otherwise pick the aforementioned models.

In T3 Code, use `/chief-of-staff` to resolve the models and start each delegate model in parallel. Use the harness's subagent tools warpped in that skil. If you cannot reach three providers, or a named member is unavailable, report it instead of substituting.

Give each delegate the request and relevant context. For review or feedback, keep their work read-only. Collect their responses and summarize the useful findings, disagreements, and recommended next steps.

Do not wait idle. When a result arrives, check its findings against the code at once and decide what to fix while the other delegates run. Do not edit files while a delegate still reviews the same checkout. If the user's instructions mark a delegate as non-blocking, do not wait for it; treat a late result as feedback and do not record its score.

For a code review, ask each delegate for a score out of 10. Count each full review pass as one round. A fresh review after fixes starts a new round.

If the work ends in a pull request, put the results in the PR description. Put this section before the model and harness line at the end:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| GPT Sol | 8/10 | 10/10 |
| Gemini Pro | 7/10 | 9/10 |
```

## More Rules

- If a delegate gives no score, write `no score`. Do not invent one. 
- If the PR is open, edit the description. Do not post a comment for this.
- If there is no PR, put the same results in the final reply only.
- If you agree with their recommendations, make the changes and request a fresh
review after. Continue this process until all delegates are satisfied with the
outcome.
- Do not let repeated reviews result in scope creep. It is your job to fight to
keep scope limited.