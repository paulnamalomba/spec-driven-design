---
name: merge-customer-journeys-into-specifications
description: Merge customer journeys, user flows, service blueprints, or journey-derived business rules into an existing SRS or specifications document. Use when Codex must read journey documents and update requirements by adding, deleting, replacing, or complementing existing specifications with traceability.
---

# Merge Customer Journeys Into Specifications

## Purpose

Reconcile narrative customer journeys with an existing requirements/specification document. The output must preserve traceability from journey step to requirement change and must clearly distinguish additions, deletions, replacements, complements, and unresolved conflicts.

## Required Inputs

- Existing SRS/specification document in Markdown, DOCX-converted Markdown, PDF-extracted text, or another readable format.
- One or more customer journey documents.
- Target output path or instruction to modify in place.

When the existing SRS is missing, create a journey-derived requirements addendum rather than pretending a full baseline exists.

## Workflow

1. Load the baseline specifications.
   - Extract section hierarchy, requirement IDs, module names, statuses, acceptance criteria, and glossary terms.
   - Build a baseline requirement map keyed by module and requirement ID.

2. Load customer journeys.
   - Identify actors, channels, screens, decisions, validations, state transitions, data captured, integrations, notifications, settlement/accounting events, failure cases, and accessibility/low-literacy requirements.
   - Preserve concrete numbers and formulas exactly unless they conflict with another source.

3. Derive journey requirements.
   - Convert each user action, system response, validation, edge case, and settlement step into requirement candidates.
   - Assign each candidate a channel/module, priority, source journey section, and acceptance criteria.

4. Reconcile with the baseline.
   - `Add`: no equivalent baseline requirement exists.
   - `Complement`: baseline exists but journey adds detail, acceptance criteria, edge cases, formulas, or channel behavior.
   - `Replace`: baseline conflicts with journey and the journey is the new desired behavior.
   - `Delete/Deprecate`: baseline requirement is contradicted or made obsolete by the journey.
   - `Question`: conflict requires business or technical decision.

5. Update the specification.
   - Maintain the SRS style and requirement ID scheme.
   - Add traceability columns or footnotes where useful.
   - Preserve current implementation status when known. Journey-derived requirements are not automatically implemented.
   - Add a change log section summarizing adds/complements/replacements/deprecations/questions.

6. Validate.
   - Every journey section should map to at least one requirement, non-requirement note, or explicit "out of scope" decision.
   - Every changed requirement should cite its journey source.
   - All formulas, fees, limits, timeouts, and user-facing confirmations should be testable.

## Output Modes

- **Merged SRS**: update the original specification structure with journey-derived changes.
- **Requirements Addendum**: create a standalone document when no baseline exists or when the user requests review before merge.
- **Traceability Matrix**: produce a table mapping journey step -> requirement ID -> change type -> acceptance criteria -> status.

## Afriflex Journey Guidance

For Afriflex SACCO BNPL journeys, pay special attention to:

- USSD channel constraints: numeric menus, short sessions, PIN attempts, timeout behavior, no internet dependency.
- Website low-literacy flows: large buttons, wallet dashboard, merchant selection, repayment comparison, OTP confirmation.
- Wallet and credit behavior: pre-approved SACCO limit, virtual wallet balance, amount <= balance validation, remaining balance display.
- Settlement formulas: merchant receives `Spend Amount x 95%`; Afriflex retains 5% merchant fee; SACCO separately pays 5% processing fee; member principal remains the spend amount only.
- Loan behavior: SACCO rate engine determines monthly deductions; first deduction date is shown before confirmation.
- Fail-safe behavior: no merchant payout or loan creation unless wallet debit and SACCO loan record both succeed; idempotency prevents double charging.
- Notifications: SMS receipts and support/help flows.
