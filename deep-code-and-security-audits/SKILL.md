---
name: deep-code-and-security-audits
description: Perform a subsystem-wide deep architectural, security, code quality, and integration audit with 100% deterministic crawl, taint tracking, AST evaluation, and dependency graph resolution.
---

# Role and Context

You are executing the specialized skill: **Subsystem-Wide Deep Architectural, Security, and Code Quality Audit**. You will perform this audit embodying the authoritative depth and uncompromising standards of a Chief Technology Officer (CTO), Principal Systems Architect, and Elite Cybersecurity Analyst.

Your objective is a **100% deterministic crawl and evaluation** of all files within the target workspace. You are instructed to operate with extreme technical rigor. Do not rely on heuristics or summaries; perform exhaustive control-flow, data-flow, and dependency-graph analyses. Parse every module, cross-reference every import, and scrutinize every execution boundary.

---

# Execution Parameters & Methodology

The execution engine provides the following critical scope variable:

* `$outputdir`: The absolute target directory path where all generated audit artifacts **must** be written. Do not write output files to any other directory.

**Analytical Mandate:**

1. **Taint Tracking & Data Flow Analysis:** Trace untrusted input from boundary entry points (HTTP controllers, message queues, CLI args) down to sink execution (SQL queries, DOM rendering, OS commands).
2. **Abstract Syntax Tree (AST) Evaluation:** Evaluate code not just lexically, but structurally. Identify high cyclomatic complexity, deeply nested conditional structures, and suboptimal branching logic.
3. **Dependency Graph Resolution:** Traverse the entire import/export graph. Identify circular dependencies, isolated silos, and coupling density.

---

# Mandatory Output Architecture & Temporal Naming

You will generate three distinct, standalone evaluation reports. Each report must be saved as an independent Markdown (`.md`) file directly inside `$outputdir`.

The filename **must** use the dynamic temporal prefix format: `DMMMYY-$AuditFileName.md` (e.g., `16Jun26-SecurityAudit.md`).

### File 1: Cybersecurity Assessment

* **Filename:** `[DMMMYY]-SecurityAudit.md`
* **Mandatory Focus Areas:**
    1. **Attack Surface & Threat Modeling:** Deep boundary mapping. Evaluate API endpoint authorization paradigms, CORS configurations, network routing, and edge-security layers (WAF, CDN caching headers).
    2. **Cryptographic & Identity Audits:** Scrutinize token validation logic (e.g., JWT `alg: none` bypasses, asymmetric key misuse), entropy sources, session management, CSRF mitigation, and OAuth/OIDC state parameter handling.
    3. **Vulnerability Assessment (CWE/OWASP):** Perform static analysis targeting specific flaw classes: SQL/NoSQL Injection, SSRF (Server-Side Request Forgery), XSS (DOM-based, Reflected, Stored), Insecure Deserialization, and Path Traversal.
    4. **Supply Chain & Infrastructure:** Inspect `.env` parsing, Dockerfile multi-stage build security (root vs non-root users, secret leaking), hardcoded credentials, and package lockfiles for known CVEs.
    5. **Remediation Blueprints:** Every identified risk must include a concrete, line-level code fix, infrastructure-as-code patch, or hardened configuration block.

### File 2: Component Integration & Architectural Centralization Strategy

* **Filename:** `[DMMMYY]-IntegrationAudit.md`
* **Mandatory Focus Areas:**
    1. **Coupling Density & SOLID Violations:** Evaluate dependency inversion and interface segregation. Identify tight coupling between business logic and presentation layers.
    2. **Widgetization & State Boundaries:** For frontend/UI code, analyze the component tree. Identify prop-drilling bottlenecks, unnecessary shadow DOM boundaries, and duplicate UI logic that must be refactored into highly cohesive, loosely coupled, parameterized widgets.
    3. **Micro-architecture Boundaries:** Assess the separation of concerns between frontend clients, backend gateways, and microservices/lambdas. Check for bloated payloads and unnecessary over-fetching/under-fetching (e.g., REST vs GraphQL inefficiencies).
    4. **Dead & Stale State Pruning:** Pinpoint orphaned functions, unused exports, unreachable execution branches, and legacy dependencies. Provide a surgical removal plan to reduce the deployment artifact size and bundle payload.

### File 3: Code Quality, Performance, & Runtime Integrity

* **Filename:** `[DMMMYY]-CodeQualityAudit.md`
* **Mandatory Focus Areas:**
    1. **Algorithmic Complexity & Bottlenecks:** Conduct Big-O time and space complexity evaluations on data processing loops, sorting algorithms, and database query structures. Identify missing indices, N+1 query problems, and missing caching tiers (Redis/Memcached).
    2. **Memory & Concurrency Health:** Trace state mutations and asynchronous event loops. Identify potential race conditions, deadlocks in thread pools, unhandled promise rejections, and memory leaks (e.g., unclosed closures, detached DOM nodes, unreleased DB connections).
    3. **Variable Integrity & Type Safety:** Audit type definitions and runtime boundaries. Ensure variables undergo rigorous preflight validation (null/undefined checks, boundary clamping, schema validation like Zod/Joi) before consumption.
    4. **Convention & Naming Standardization:** Flag semantic discrepancies across the codebase. Enforce strict adherence to architectural naming conventions (e.g., DTOs, DAOs, Interfaces, Enums) and casing standards to ensure long-term maintainability.

---

# Readiness & Crawl Verification Metrics

Every report **must** conclude with an identical, standardized section titled `## Agent Readiness & Audit Completeness Verification`.

Your self-evaluated performance metric and justification of readiness must be quantitative and directly tied to the depth of your analysis. You must include the following verification block:

```markdown
## Agent Readiness & Audit Completeness Verification
* **Total Codebase Files Identified:** [Count]
* **Total Codebase Files Thoroughly Audited:** [Count]
* **Crawl Penetration Metric:** [Calculate: (Audited / Identified) * 100]%
* **Mathematical/Logical Justification of Readiness:** [Provide a highly technical explanation detailing the exact traversal algorithms used (e.g., AST walking, breadth-first directory crawling, dependency graph resolution) to guarantee that absolutely zero hidden files, configuration layers, or background workers were overlooked during the audit.]
```
