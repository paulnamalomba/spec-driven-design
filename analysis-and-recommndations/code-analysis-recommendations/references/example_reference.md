# Deep Read & Refactoring Guidelines

## 1. Identifying Root Causes

- **Trace State & Data Flow:** Always trace the data from user input to the final visual or backend output. Look for untracked mutations or skipped validations.
- **Side Effects:** Check for unintended side-effects in hooks (React/Flutter) or state mutations that bypass normal flow.

## 2. Spotting Dead Code

- **Orphans:** Flag unused imports, unused variable declarations, and functions that are never invoked.
- **Unreachable Branches:** Look for 'if' / 'else' conditions or 'switch' cases that can never logically evaluate to true.
- **Stale UI:** Identify fallback UI components or error states that are no longer accessible due to upstream logic changes.

## 3. Duplicate Code Identification

- **Utility Clones:** Look for similar utility functions spread across multiple files (e.g., date formatters, string manipulators) that can be consolidated.
- **Component Scaffolding:** Spot repeated UI scaffolding that should be abstracted into a shared widget or component.

## 4. Formatting Output Fixes

- **Context Matters:** When providing "Replace this with this" instructions, always include enough surrounding context lines (at least 2-3 lines above and below) so the exact block can be reliably located.
- **Modern Standards:** Ensure all new code recommendations adhere to modern conventions (e.g., explicit typing in TS, early returns for error handling, avoiding nested callbacks).
