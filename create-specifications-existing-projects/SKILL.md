---
name: create-specifications-existing-projects
description: Generate deep, source-grounded System Requirements Specification (SRS) documents from existing software projects. Use when Codex must inspect one or more repositories, discover implemented functional and technical modules, compare code with docs, and produce an enterprise-grade requirements/specification document similar to QueAudit-style SRS outputs.
---

# Create Specifications From Existing Projects

## Purpose

Create a comprehensive SRS for an existing system by reading the current repositories, not by inventing a greenfield product. The resulting document must separate implemented behavior, documented-but-unverified behavior, planned gaps, and requirements implied by adjacent artifacts.

## Required Inputs

Collect these before drafting:

- Project/repo roots and each repo's role, such as API, admin dashboard, customer webapp, contracts/docs, workers, or USSD.
- Existing reference SRS/PDF/template, if provided.
- Current source files, route maps, controllers, entities, migrations, API clients, tests, docs, and configuration.
- Target output location, usually the contracts/documentation repo.

If a repo is empty or only contains Git metadata, explicitly record it as "no current application implementation found" and document only planned role/scope from user prompt or roadmap docs.

## Workflow

1. Inventory repositories.
   - Capture framework, language, package/build files, run scripts, remotes, dirty status, major directories, and documentation.
   - Prefer `rg --files`, `find`, package manifests, solution files, controllers/routes, page routes, migrations, and README/checklist docs.

2. Extract system structure from evidence.
   - Backend: controllers/endpoints, DTOs, services, repositories, entities, enums, auth policies, background jobs, messaging topics, migrations, tests, config.
   - Frontend: routes/pages, layout shell, API client groups, auth/session model, forms, dashboards, checkout flows, empty/error states, design system tokens.
   - Admin/CMS: implemented modules, routes, content models, editorial workflows, permissions, integrations.
   - Contracts/docs: journeys, term sheets, commercial rules, settlement logic, diagrams, requirements docs.

3. Build an evidence map before writing.
   - For every module, note: source file(s), implemented status, public behavior, data entities/contracts, integrations, risks/gaps.
   - Distinguish source-proven implementation from README claims. If README claims are not source-verified, label them as documented intent.

4. Infer SRS requirements conservatively.
   - Convert implemented behavior into "system shall" requirements.
   - Convert TODO/checklist/customer docs into proposed requirements with status `Planned`, `Gap`, or `Requires Decision`.
   - Do not silently promote planned features to complete features.

5. Draft the SRS.
   - Follow `references/srs-structure.md` for document structure.
   - Include requirement IDs, category, description, evidence/source, priority/status, and acceptance criteria.
   - Go deeper technically than a business SRS: include API surfaces, data model, auth, events, integration boundaries, failure modes, non-functional requirements, deployment/configuration, observability, security, and compliance assumptions.

6. Validate the draft.
   - Check that every named module has source evidence or an explicit "planned/unimplemented" label.
   - Check that routes/endpoints/entities mentioned in requirements exist or are marked as gaps.
   - Check requirement IDs are unique and acceptance criteria are testable.
   - Save the output in the documentation/contracts repo unless the user specifies otherwise.

## Output Expectations

The final SRS should read like a development-ready system specification. It must include:

- Executive metadata: product, version, date, status, authorship/prepared-for where known.
- Introduction, product scope, users/personas, and design principles.
- Current-state architecture and technical stack verified from code.
- Functional module requirements with Req ID tables.
- Data model and integration requirements.
- Non-functional requirements: performance, availability, scalability, accessibility, localization, backup, auditability.
- Security requirements: auth, authorization, secrets, session handling, audit logging, data privacy.
- Implementation status/gap matrix across repos.
- Future roadmap and glossary.

## Afriflex-Specific Notes

When used for Afriflex, treat these repos as distinct evidence surfaces:

- `afriflex-contracts`: documentation and final SRS storage.
- `afriflex`: .NET API, domain model, persistence, messaging, SignalR, credit/commerce modules.
- `afriflex-webapp`: Next.js customer storefront/ecommerce hub.
- `afriflex-admin`: admin/CMS dashboard; if empty, document as planned/import target rather than implemented.
- `afriflex-ussd`: future USSD channel if created.

Use customer journeys as separate input; do not merge journey-derived requirements unless the task also triggers the customer-journey merge skill.
