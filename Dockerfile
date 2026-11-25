ARG MAGPIE_IMAGE=ghcr.io/yetone/magpie:stable

FROM debian:13-slim AS agy-fetcher

ARG AGY_VERSION=latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tar gzip xz-utils unzip \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Fetching agy (${AGY_VERSION})..." \
    && mkdir -p /tmp/agy-home /out \
    && curl -fsSL https://antigravity.google/cli/install.sh \
       | HOME=/tmp/agy-home bash -s -- --dir /out \
    && test -x /out/agy \
    && chmod 755 /out/agy \
    && rm -rf /tmp/agy-home

FROM ${MAGPIE_IMAGE}

ARG AGY_VERSION=latest

COPY --from=agy-fetcher /out/agy /usr/local/bin/agy

ENV AGY_CLI_DISABLE_AUTO_UPDATE=true

USER 65532:65532

RUN set -eu; \
    mkdir -p /tmp/agy-smoke; \
    ACTUAL_VERSION="$(HOME=/tmp/agy-smoke /usr/local/bin/agy --version 2>&1)"; \
    printf 'Expected: %s; actual: %s\n' "$AGY_VERSION" "$ACTUAL_VERSION"; \
    test -n "$ACTUAL_VERSION"; \
    if [ "$AGY_VERSION" != latest ]; then test "$ACTUAL_VERSION" = "$AGY_VERSION"; fi; \
    rm -rf /tmp/agy-smoke
