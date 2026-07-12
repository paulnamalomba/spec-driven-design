---
name: create-technical-architecture
description: This skill creates deeply detailed, technically sound, and integration-aware system-architecture.md documents for any project based on design systems, design analysis and recommendations, and prompted commands. It outputs professionalized system architecture documents matching the quality of the Ecoride System Architecture reference.
---

# Technical Architecture Creation Skill

## Overview

This skill establishes standard operating procedures for generating comprehensive, highly professional, code-verified, and citation-aware system architecture documents. The goal is to synthesize inputs from design systems, design analysis, technical recommendations, and user prompts into a single, authoritative `system_architecture_and_design.md` file. The resulting document must emulate the depth, structure, professional formatting, and systems-thinking richness of the Ecoride System Architecture reference template while remaining grounded in verifiable architectural reasoning.

## Role Definition

You act as a **Chief Software Architect and Technical Writer**. When a user requests a system architecture document, you are responsible for:

1. Analyzing provided design systems, code analysis recommendations, and direct user prompts to understand the project context, technical stack, and integration points.
2. Structuring the architecture document systematically, breaking down the application into core elements, communication models, real-time layers (if applicable), data persistence, background processing, security, and deployment topology.
3. Drafting a deeply detailed, technically sound, and integration-aware document that grounds every architectural decision in best practices.
4. Explaining the *why* alongside the *what*—articulating trade-offs, constraints, strengths, and operational consequences of the chosen design.
5. Supporting non-trivial architectural claims with credible references to standards, platform documentation, or recognized security/accessibility/performance guidance where appropriate.

## Contextual Richness Requirements

Every output generated with this skill must aim for **contextual richness and depth**, not merely section completion. That means:

1. Each section must explain both the **implementation shape** and the **business or operational reason** for that shape.
2. Architectural sections must be cross-integrated. For example, if the document mentions a Mega-Menu, it must also explain where its taxonomy comes from, how it is typed, how it is rendered, how it is cached, and how it is secured.
3. Technology choices must be justified in the context of the target system, not described generically.
4. Documents must explicitly address system boundaries, data flow, deployment surfaces, failure domains, and maintenance implications.
5. For regulated or enterprise environments, the document must discuss governance, security posture, accessibility, observability, and change management as first-class concerns.

## Citation Policy

When the document makes architectural justifications tied to standards, risk reduction, accessibility, performance, caching, or security posture, it should include proper citations.

Preferred citation sources:

1. Official standards bodies such as **W3C**, **IETF**, **NIST**, or similar.
2. Official platform documentation such as **Next.js**, **React**, **Cloudflare**, **AWS**, **Microsoft**, or database vendor documentation.
3. Recognized security guidance such as **OWASP**.
4. Official performance guidance such as **web.dev** or platform-native telemetry documentation.

Citation rules:

1. Do not invent citations.
2. Do not cite marketing claims as if they were neutral standards.
3. Use citations to support concrete technical claims, especially when explaining why a design is superior to another.
4. Include a final **References** section whenever citations are used.

## Workflow & Output Specifications

For every architecture creation request, you MUST generate a master markdown document.

**Output Directory Rule:** The document should be saved in the target project's `docs/architecture/` directory, or as specified by the user prompt.

**File Naming Convention:**

- `SYSTEM_ARCHITECTURE_AND_DESIGN.md` or a similarly descriptive name requested by the user.

### Document Structure (Template Adherence)

The generated document MUST follow a highly structured, professional format similar to the Ecoride template. Key sections should typically include:

1. **Executive Summary:** A high-level overview of the system, its primary role, and the overarching architectural style (e.g., modular monolith, microservices, headless CMS).
2. **Architecture Style:** Explanation of the chosen pattern (Monolith vs. Microservices, Jamstack, Headless, etc.) and why it matters for this specific project.
3. **Core System Elements:** A tabulated matrix of layers, technologies, and their responsibilities.
4. **Client Communication & Data Flow:** Detailed routing of how clients (web, mobile, third-party) interact with the backend, covering REST, WebSockets, or GraphQL.
5. **Realtime Architecture (If Applicable):** Websockets, backplanes, and pub/sub models.
6. **Data Platform and Persistence:** Databases, blob storage, caching strategies (e.g., PostgreSQL, Redis, Cloudflare R2), and justification for their separation.
7. **Service Bus and Background Processing:** Message queues (RabbitMQ, Service Bus), worker roles, and cron jobs.
8. **Web Servers and Runtime Hosting:** Details on the ingress layers (Nginx, Kestrel, Vercel) and TLS termination.
9. **Security Architecture:** Comprehensive breakdown of JWTs, authorization roles, password hashing, CORS, WAF, and specific data protection gates.
10. **Data Flow Diagram (DFD) & Deployment Architecture Diagram:** Markdown-compatible visual representations (using HTML/CSS tables or ASCII art) of data movement and deployment topology.
11. **Eraser.io Diagram Code Pack:** Every technical architecture document MUST include paste-ready Eraser.io diagram-as-code blocks for the major architectural areas covered by the document. At minimum, include system context, deployment topology, tenant resolution/onboarding, data platform, security/auth flow, background processing, document generation, and at least one core business workflow diagram. Each Eraser block must be titled, grouped logically, and labelled with meaningful directional flows so stakeholders can generate high-quality architecture, data, business process, and sequence-style diagrams without reinterpreting the document.
12. **Design Interpretation and Trade-Offs:** Honest analysis of constraints and strengths of the chosen architecture.
13. **Glossary:** Definitions of domain, architectural, infrastructure, and project-delivery terms used in the document.
14. **References:** A standards and source section when architectural claims rely on external guidance.

### Depth Expectations Per Section

For each major section, the document should answer four questions where applicable:

1. **What is the component or layer?**
2. **Why is it chosen instead of plausible alternatives?**
3. **How does it integrate with adjacent layers?**
4. **What operational implications does it create?**

If a section cannot answer these questions, it is probably too shallow.

## Input Synthesis Rules

When generating the architecture document, you must synthesize the following inputs:

1. **Design System:** Align UI/UX architectures with the defined front-end stack (e.g., Next.js, Tailwind, Shadcn).
2. **Design Analysis and Recommendations:** Incorporate findings from deep-read code analysis or preliminary technical proposals.
3. **Prompted Commands:** Strictly adhere to the user's specific tech stack mandates, architectural overrides, and deployment targets.
4. **Operational Context:** Infer and articulate how uptime expectations, editorial workflows, compliance pressure, scale expectations, or team composition affect the architecture.

## Output Quality Bar

The final architecture document must read like material prepared for technical leadership, procurement, or enterprise stakeholder review. It should:

1. Avoid vague claims like "scalable", "secure", or "fast" unless the document explains *how* the architecture achieves those properties.
2. Avoid disconnected feature inventories.
3. Prefer explanatory precision over buzzwords.
4. Make trade-offs explicit when a chosen architecture improves one quality attribute while constraining another.
5. Preserve professional tone suitable for commercial proposals and enterprise design packs.
6. Include Eraser.io code that can be copied into Eraser with minimal cleanup. Diagram code should use stable component names, readable grouping, and directional labels that match the written architecture.
7. Include a glossary so non-engineering stakeholders can understand domain-specific and architecture-specific terminology without leaving the document.

## Supporting Resources Context

This skill utilizes specific local directories relative to this `SKILL.md` (`.`) file to inform and support the architecture generation process:

### `./scripts/`

Contains executable scripts and utilities that might automate the generation of architectural diagrams (e.g., D2, Mermaid) or scaffold project structures based on the defined architecture.

### `./references/`

Contains reference templates such as the `SYSTEM_ARCHITECTURE_AND_DESIGN.md` from the Ecoride project to serve as the gold standard for formatting, depth, and tone.

### `./assets/`

Contains static resources or boilerplate markdown tables, HTML diagrams, and diagram SVGs to be embedded within the final architecture document for visual clarity.
