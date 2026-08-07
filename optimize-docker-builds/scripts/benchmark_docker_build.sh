#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
    printf 'Usage: %s <context> [dockerfile] [tag] [additional buildx options...]\n' "$0"
    printf 'Example: %s . Dockerfile docker-build-benchmark:local --build-arg APP_ENV=production\n' "$0"
}

if [ "$#" -lt 1 ]; then
    usage >&2
    exit 64
fi

benchmark_context=$1
benchmark_dockerfile=${2:-Dockerfile}
benchmark_tag=${3:-docker-build-benchmark:local}
if [ "$#" -ge 3 ]; then
    shift 3
else
    shift "$#"
fi
benchmark_extra_args=("$@")

if [ ! -d "$benchmark_context" ]; then
    printf 'Build context not found: %s\n' "$benchmark_context" >&2
    exit 66
fi

if [[ "$benchmark_dockerfile" = /* ]]; then
    benchmark_dockerfile_path=$benchmark_dockerfile
else
    benchmark_dockerfile_path="$benchmark_context/$benchmark_dockerfile"
fi

if [ ! -f "$benchmark_dockerfile_path" ]; then
    printf 'Dockerfile not found: %s\n' "$benchmark_dockerfile_path" >&2
    exit 66
fi

command -v docker >/dev/null 2>&1 || {
    printf 'docker is required.\n' >&2
    exit 69
}
docker buildx version >/dev/null

run_build() {
    local label=$1
    local started_at=$SECONDS

    printf '\n%s build\n' "$label"
    DOCKER_BUILDKIT=1 docker buildx build \
        --load \
        --progress=plain \
        --file "$benchmark_dockerfile_path" \
        --tag "$benchmark_tag" \
        "${benchmark_extra_args[@]}" \
        "$benchmark_context"

    printf '%s build elapsed: %ss\n' "$label" "$((SECONDS - started_at))"
}

run_build "First"
run_build "Identical warm"

benchmark_size_bytes=$(docker image inspect "$benchmark_tag" --format '{{.Size}}')
printf '\nImage: %s\nSize: %s bytes\n' "$benchmark_tag" "$benchmark_size_bytes"
printf 'The benchmark tag is retained for inspection; remove it explicitly when no longer needed.\n'
