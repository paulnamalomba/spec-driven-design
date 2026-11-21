---
name: version-bump
description: Version bumps when using the issue-and-pr-based-development
risk: safe
source: "self"
---

# Version Bump

For tasks performed using issue-and-pr-based-development skill, properly loaded. We must now use create-commit-notes-markdown to create commit notes (only bumps the build version for each PR merged since last tag)

If last tag were 0.0.14, with 7 PRs merged, new tag is now 0.0.21 i.e. +1 build number for each PR.