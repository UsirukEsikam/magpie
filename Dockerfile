FROM debian:13-slim AS agy-fetcher

ARG AGY_VERSION=latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tar gzip xz-utils unzip \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Fetching agy (${AGY_VERSION})..." \
    && mkdir -p /tmp/agy-home /out \
    && curl -fsSL https://antigravity.google/cli/install.sh \
       | HOME=/tmp/agy-home bash -s -- --dir /out \
    && (test -x /out/agy || (echo "Unexpected install layout:" && ls -laR /out && exit 1)) \
    && chmod 755 /out/agy \
    && rm -rf /tmp/agy-home

FROM ghcr.io/yetone/magpie:stable

COPY --from=agy-fetcher /out/agy /usr/local/bin/agy

ENV AGY_CLI_DISABLE_AUTO_UPDATE=true

# 以最终运行用户 (65532) 执行冒烟测试，验证权限与动态链接库依赖，同时不留临时文件
USER 65532:65532
RUN mkdir -p /tmp/agy-smoke \
    && HOME=/tmp/agy-smoke /usr/local/bin/agy --version \
    && rm -rf /tmp/agy-smoke
