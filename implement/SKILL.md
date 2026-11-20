---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

# Implementer

Implement the work described by the user in the spec, prompt or tickets.

If the user passes a ticket, issue, or spec reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Bring in four delegates to help with the user's request via the following matrix:

Use `/chief-of-staff` with up to four (4), but minimum of one (1) delegates to help with the user's request via the following matrix:

- Embedded external models via the antigravity skills: Uses Maximum 2 Gemini Flash 3.8 (High) via:
  - $antigravity:antigravity-handoff (if the executor of this skill is codex CLI)
  - /antigravity:handoff (if the executor of this skill is claude code)
- Internal models via executor:
  - Uses Maximum two (2) GPT Terra 6.1 (xHigh) (if the executor of this skill is codex CLI) 
  - Uses Maximum two (2) Claude Sonnet 5.5 Medium (if the executor of this skill is claude code)

Resolve these delegate models and start each delegate model in parallel. Use the harness's subagent tools warpped in that skil. If you cannot reach three providers, or a named member is unavailable, report it instead of substituting.

If the user's instructions name council members, use those. Otherwise pick the aforementioned models.

Give each delegate the request and relevant context. For review or feedback, keep their work read-only. Collect their responses and summarize the useful findings, disagreements, and recommended next steps.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "code-review" ($code-review or /code-review) to review the work.
- Strictly use $multi-opinion-codex (if the executor of this skill is codex CLI) or $multi-opinion (if the executor of this skill is claude code) for review but only with 1 council memeber each from each provider (1 and 1).

Commit your work to the current branch.
