---
name: optimize-docker-builds
description: Audit and optimize Dockerfiles, Docker build contexts, Compose build graphs, CI image builds, and deployment wrapper functions for faster cached rebuilds and smaller runtime images. Use when Docker builds take minutes, contexts are unexpectedly large, dependency restores repeat, images contain build tooling, Compose rebuild behavior is inefficient, BuildKit cache mounts are missing, or a project needs tailored Dockerfiles and .dockerignore files without changing application behavior.
---

# Optimize Docker Builds

Produce source-grounded Docker changes with measured build evidence. Optimize the complete
build graph rather than rewriting an isolated Dockerfile from a generic template.

## 1. Discover Scope and Preserve Existing Work

1. Read every applicable `AGENTS.md` and repository instruction.
2. Treat each Git root as an independent scope. Include sibling repositories only when the
   user explicitly includes their images or a parent Compose graph references them in scope.
3. Run `git status --short`, `git diff`, and `git diff --cached` in every repository before
   editing. Preserve all existing work.
4. Find Docker and Compose inputs with `rg --files` or `find`:
   - `Dockerfile`, `Dockerfile.*`
   - `.dockerignore`
   - `compose.yml`, `docker-compose.yml`, and variants
   - lockfiles, project files, workspace files, and build configuration
5. Resolve every Compose `build.context`, `dockerfile`, `target`, build argument, and image.
   Do not assume the current repository is the build context.
6. Read the package manager and runtime configuration for each image. Inspect neighboring
   Dockerfiles before choosing a pattern.

Never read or print `.env` values, secrets, signing material, package tokens, registry
credentials, or production customer data. Ensure ignore rules exclude them from contexts.

## 2. Establish a Baseline

Record evidence before changing files:

```bash
docker version
docker buildx version
docker buildx ls
docker compose config --quiet
docker image inspect image:tag --format '{{.Size}}'
```

Measure the working directory and obvious generated directories with `du -sh`. Use actual
BuildKit output to record `transferring context` size because repository size is not Docker
context size. When safe and affordable, time one ordinary build before editing.

Identify whether the delay comes from:

- transferring `node_modules`, `.next`, `bin`, `obj`, `.git`, tests, docs, or local artifacts;
- dependency metadata being copied with volatile source;
- missing BuildKit cache mounts;
- repeated downloads caused by destructive builder-cache pruning;
- copying a very large dependency tree between disposable stages;
- rebuilding unrelated projects from one broad `COPY . .`;
- compiling instead of reusing a warm layer;
- exporting/unpacking a large final image;
- Compose wrappers that run `down`, omit `build`, or rebuild sequentially;
- slow health checks or unhealthy dependencies being mistaken for build time.

Do not promise that every source-changing build will take seconds. Distinguish cold cache-fill,
incremental source rebuild, and identical warm rebuild timings.

## 3. Design the Dockerfile as an Inverted Pyramid

Order instructions from least volatile to most volatile:

1. syntax directive and pinned base image;
2. static `WORKDIR`, runtime `ENV`, system packages, and user setup;
3. package manifests, lockfiles, project references, and workspace metadata;
4. dependency restore using BuildKit cache mounts;
5. narrowly scoped source directories;
6. compile or publish;
7. copy only runtime artifacts into the final stage.

Apply these rules:

- Start cache-mount Dockerfiles with a supported frontend such as
  `# syntax=docker/dockerfile:1.7`.
- Never copy the whole project before dependency restore.
- Copy lockfiles and dependency metadata before source.
- Put environment-specific build arguments after dependency restore so they do not invalidate
  package installation.
- Prefer explicit source dependency graphs for monorepos and .NET solutions. An API change
  should not rebuild an unrelated worker when project references do not require it.
- Use `COPY . .` only after restore and only with a proven `.dockerignore`.
- Combine related system-package operations into one `RUN` instruction.
- Remove package indexes in the same layer, or mount those cache directories so they never
  enter the layer.
- Use a build stage with compilers/dev dependencies and a slim runtime stage containing only
  published or standalone artifacts.
- Use a non-root runtime user when compatible with existing ports and write paths.
- Preserve entrypoints, health endpoints, ports, public build-time variables, and runtime
  environment semantics.

For tested cache targets and language-specific patterns, read
[`references/patterns.md`](references/patterns.md).

## 4. Avoid Redundant Heavy Stages

Do not add stages merely to increase the stage count. A separate Node `deps` stage followed by
`COPY --from=deps /app/node_modules` can materialize hundreds of megabytes on slow overlay
storage. Prefer one disposable Node builder stage when all of these are true:

- the lockfile-only `npm ci` layer already provides dependency caching;
- source is copied only after installation;
- the final stage uses Next standalone output or another traced runtime artifact;
- no independent test/build target needs the dependency stage.

Keep a separate dependency stage when multiple targets genuinely reuse it and measured builds
show the copy/snapshot cost is lower than the reuse benefit. Make this decision from timings,
not from a canonical sample Dockerfile.

## 5. Tailor `.dockerignore`

Create one ignore file per build context. At minimum consider:

- `.git`, `.github`, editor state, OS metadata;
- `.env`, `.env.*`, nested environment files, keys, certificates;
- `node_modules`, `.next`, `dist`, `out`, `bin`, `obj`, coverage and test output;
- local logs, backups, reports, screenshots, caches, and temporary archives;
- documentation, tests, release notes, and deployment files when the production build does not
  consume them.

Do not blindly ignore files referenced by `COPY`, framework configuration, code generation, or
publish steps. Prefer conventional exclusion lists for evolving applications. Use an allowlist
only when the build input contract is stable and every required parent directory is re-included.

## 6. Optimize Compose and Deployment Wrappers

For Compose v1 on a BuildKit-capable host, use:

```bash
sudo env DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 COMPOSE_PARALLEL_LIMIT=3 \
  docker-compose build
sudo docker-compose up -d --remove-orphans --no-build
```

Compose v1 ignores `build --parallel` when `COMPOSE_DOCKER_CLI_BUILD=1`; set
`COMPOSE_PARALLEL_LIMIT` instead so the Docker CLI/BuildKit path can schedule builds without the
misleading warning.

For Compose v2, use the equivalent `docker compose` commands. Apply these semantics:

- validate interpolation before building;
- build enabled application images in parallel;
- do not run `down` for an ordinary deployment because it causes avoidable downtime and removes
  the dependency graph before replacements are healthy;
- run `up --no-build` after an explicit successful build;
- preserve named database, CMS, and cache volumes;
- use `docker image prune`, if authorized, only after successful startup;
- do not run `docker builder prune` or `docker system prune` in the normal build wrapper because
  that deletes the cache the optimization depends on;
- return nonzero immediately when config, build, or startup fails.

If a service is temporarily disabled, remove or comment its complete service boundary and all
`depends_on` references. Do not leave a service with neither `image` nor `build`. Prefer Compose
profiles when frequent toggling is expected; follow an explicit request to preserve a commented
block when that is the repository convention.

When editing a remote shell profile, identify the exact sourced file and function, make a
timestamped permission-preserving backup, replace only that function, run `bash -n`, and inspect
the reloaded definition. Do not print unrelated shell configuration or secrets.

## 7. Validate in Increasing Scope

1. Run the native production build outside Docker to separate application failures from image
   construction failures.
2. Run `git diff --check` and inspect every Dockerfile and ignore-file diff.
3. Validate Compose without rendering secret values.
4. Build every affected final image with BuildKit.
5. Build the identical inputs again and record warm timing and cached steps.
6. Record context transfer and final image sizes.
7. Inspect final images to confirm compilers, test trees, local source, and dev dependency trees
   are absent.
8. Run the container health command or a bounded endpoint smoke test when dependencies allow it.
9. Confirm runtime user, entrypoint, exposed port, and writable paths.
10. Recheck all Git roots and preserve unrelated work.

Use [`scripts/benchmark_docker_build.sh`](scripts/benchmark_docker_build.sh) for a repeatable
two-pass build when its local tag mutation is acceptable. Pass additional BuildKit options after
the first three arguments.

Classify failures precisely. A temporary transfer artifact, network pull failure, host disk
pressure, missing Docker CLI, unhealthy runtime dependency, and Dockerfile syntax error require
different fixes. Report the first relevant diagnostic and never weaken application checks to
obtain a green image.

## 8. Deliver the Result

Report:

- every changed Dockerfile, `.dockerignore`, Compose file, and deployment wrapper;
- cold/first successful, incremental, and identical warm timings that were actually measured;
- previous and optimized context sizes when available;
- final image sizes;
- application and container validation commands and results;
- unavailable checks and pre-existing failures;
- any temporarily disabled service and exact re-enablement boundary;
- whether remote profiles or production services were changed and the backup/rollback path.

Do not claim a minutes-to-seconds improvement without an identical warm-build measurement.
