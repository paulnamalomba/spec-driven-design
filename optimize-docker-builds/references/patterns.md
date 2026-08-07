# Docker Build Optimization Patterns

Use only the sections matching the repository's actual package manager and runtime.

## Cache mount targets

| Ecosystem | Persistent targets | Notes |
|---|---|---|
| npm | `/root/.npm` | Run `npm ci --prefer-offline`; keep `node_modules` in the normal build layer. |
| pnpm | configured store, commonly `/pnpm/store` | Pin Corepack/package-manager version and set the store path explicitly. |
| Yarn | version-specific global/cache directory | Discover with the repository's Yarn version; do not guess across Classic/Berry. |
| NuGet | `/root/.nuget/packages`, `/root/.local/share/NuGet/v3-cache` | Mount the same cache IDs for restore and publish when using `--no-restore`. |
| pip | `/root/.cache/pip` | Keep wheels/downloads cached; install into a virtual environment copied to runtime. |
| apt | `/var/cache/apt`, `/var/lib/apt/lists` | Use locked sharing and either mounts or same-layer list cleanup. |
| apk | `/var/cache/apk` | A cache mount keeps indexes/packages outside the committed layer. |
| Go | `/go/pkg/mod`, `/root/.cache/go-build` | Copy `go.mod` and `go.sum` before source. |
| Maven | `/root/.m2` | Copy `pom.xml` hierarchy before application source. |
| Gradle | `/root/.gradle/caches`, `/root/.gradle/wrapper` | Do not copy the host `.gradle` directory into the image. |

Use stable, project-specific cache IDs so related images can share downloads. Use
`sharing=locked` where concurrent writers are unsafe. Do not mount a final artifact directory in
a way that hides output that must be copied to the runtime stage.

## Next.js with npm and standalone output

```dockerfile
# syntax=docker/dockerfile:1.7
FROM node:22-alpine AS builder
WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1

COPY package.json package-lock.json ./
RUN --mount=type=cache,id=my-app-npm,target=/root/.npm,sharing=locked \
    npm ci --prefer-offline --no-audit --no-fund

# Declare public build arguments after npm ci.
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

COPY . .
RUN --mount=type=cache,id=my-app-next,target=/app/.next/cache,sharing=locked \
    npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    HOSTNAME=0.0.0.0 \
    PORT=3000
COPY --from=builder --chown=node:node /app/public ./public
COPY --from=builder --chown=node:node /app/.next/standalone ./
COPY --from=builder --chown=node:node /app/.next/static ./.next/static
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

Require `output: "standalone"` in the Next configuration. Keep every `NEXT_PUBLIC_*` value
non-secret because it is embedded in browser-visible output. If `public/` is optional, ensure it
exists or adapt the copy without creating unrelated assets.

## ASP.NET Core or .NET worker

```dockerfile
# syntax=docker/dockerfile:1.7
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    NUGET_XMLDOC_MODE=skip

COPY src/Domain/Domain.csproj src/Domain/
COPY src/Application/Application.csproj src/Application/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/
COPY src/Api/Api.csproj src/Api/

RUN --mount=type=cache,id=my-app-nuget,target=/root/.nuget/packages,sharing=locked \
    --mount=type=cache,id=my-app-nuget-http,target=/root/.local/share/NuGet/v3-cache,sharing=locked \
    dotnet restore src/Api/Api.csproj

COPY src/Domain/ src/Domain/
COPY src/Application/ src/Application/
COPY src/Infrastructure/ src/Infrastructure/
COPY src/Api/ src/Api/

RUN --mount=type=cache,id=my-app-nuget,target=/root/.nuget/packages,sharing=locked \
    --mount=type=cache,id=my-app-nuget-http,target=/root/.local/share/NuGet/v3-cache,sharing=locked \
    dotnet publish src/Api/Api.csproj \
    --configuration Release \
    --output /app/publish \
    --no-restore \
    --no-self-contained \
    -p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "Api.dll"]
```

Restore the target project instead of the full solution when tests and unrelated executables are
not part of the image. Copy every transitive `ProjectReference` metadata file before restore and
every referenced source directory before publish. Include repository-level build props, targets,
NuGet config, central package files, or lockfiles when present.

## apt in a disposable build or runtime stage

With cache mounts, index files are outside the committed layer:

```dockerfile
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates
```

Without cache mounts, clean in the exact same layer:

```dockerfile
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*
```

Do not install compilers in the final stage when artifacts can be built elsewhere.

## Alpine packages

```dockerfile
RUN --mount=type=cache,id=my-app-apk,target=/var/cache/apk,sharing=locked \
    apk add --update-cache --no-progress ca-certificates wget
```

Because the cache directory is mounted, cached indexes and packages do not become part of the
image layer. Verify whether BusyBox already supplies a required health-check command before
installing a duplicate package.

## Python virtual environment

```dockerfile
# syntax=docker/dockerfile:1.7
FROM python:3.13-slim AS build
WORKDIR /app
ENV VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:$PATH
RUN python -m venv "$VIRTUAL_ENV"
COPY requirements.txt ./
RUN --mount=type=cache,id=my-app-pip,target=/root/.cache/pip,sharing=locked \
    pip install --requirement requirements.txt
COPY . .

FROM python:3.13-slim AS runtime
ENV VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
COPY --from=build /opt/venv /opt/venv
COPY --from=build /app /app
WORKDIR /app
```

Use the repository's lock/constraints mechanism rather than silently changing dependency
resolution. Do not place registry credentials in pip configuration copied to the image.

## Compose build wrapper

```bash
build_project() {
    local compose_dir="$1"

    (
        cd "$compose_dir" || exit 1
        sudo docker-compose config --quiet &&
        sudo env DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 COMPOSE_PARALLEL_LIMIT=3 \
            docker-compose build &&
        sudo docker-compose up -d --remove-orphans --no-build &&
        sudo docker image prune --force
    )
}
```

Do not insert a trailing backslash followed by whitespace; the backslash must be the final byte
before the newline. Prefer `&&` without continuations when editing tools cannot preserve that
invariant. Validate the full profile with `bash -n` and inspect the function after reloading it.
