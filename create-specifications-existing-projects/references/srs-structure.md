# SRS Structure Reference

Use this structure for enterprise SRS documents generated from existing systems.

## 1. Front Matter

- Product/project name
- Document title: System Requirements Specification
- Version, date, status, classification
- Prepared by / prepared for, if known
- Source repositories and inspection date

## 2. Introduction

- Document purpose
- Product overview
- Scope and boundaries
- Target users and roles
- Design principles and operating constraints

## 3. System Architecture and Technical Requirements

- Architecture overview and repo/module map
- Core technical stack table
- Runtime/deployment topology
- API, realtime, messaging, storage, CMS, and integration boundaries
- Non-functional requirements table
- Current implementation status notes

## 4. Functional Module Requirements

For each module:

- Module overview and business purpose
- Current implementation evidence
- Functional behavior
- Data/contracts involved
- Integration points
- Edge cases/failure modes
- Requirement table with columns:
  - Req ID
  - Category
  - Requirement Description
  - Evidence / Source
  - Status
  - Acceptance Criteria

Use stable prefixes such as AUTH, CAT, CART, ORD, INV, CREDIT, SETTLE, ADMIN, WEB, USSD, INT, SEC, NFR.

## 5. Data Requirements

- Entity/register tables and relationships
- State machines and lifecycle enums
- Data retention, audit trail, import/export, reporting needs

## 6. Integration and API Requirements

- REST endpoints, realtime hubs, webhooks, payment providers, SMS/email, SACCO/core-banking, CMS, settlement/export interfaces.
- Include request/response contract expectations where relevant.

## 7. Security Requirements

- Authentication
- Authorization and roles
- Session/token handling
- Input validation
- Secrets/configuration
- Audit logging
- Data protection and privacy
- Abuse/fraud/risk controls

## 8. Operational Requirements

- Environments
- Deployment
- Backup/restore
- Monitoring/observability
- Support workflows
- Incident response

## 9. Gap Matrix and Roadmap

- Implemented
- Partially implemented
- Documented intent only
- Missing / not started
- Requires business decision

## 10. Glossary

Define domain, user-role, technology, and delivery terms.
