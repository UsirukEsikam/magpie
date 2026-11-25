FROM ghcr.io/yetone/magpie:stable

# 传入 agy 版本号并在 RUN 中引用，确保 BuildKit 准确击穿缓存
ARG AGY_VERSION=latest

USER root

# HOME 必须写在 bash 前；最后以临时 HOME 做一次构建期冒烟测试
RUN echo "Installing agy (${AGY_VERSION})..." \
    && mkdir -p /tmp/agy-install \
    && curl -fsSL https://antigravity.google/cli/install.sh \
       | HOME=/tmp/agy-install bash -s -- --skip-aliases --skip-path \
    && mv /tmp/agy-install/.local/bin/agy /usr/local/bin/agy \
    && chmod 755 /usr/local/bin/agy \
    && rm -rf /tmp/agy-install \
    && HOME=/tmp AGY_CLI_DISABLE_AUTO_UPDATE=true /usr/local/bin/agy --version

# 关闭容器内非 root 用户的内置自更新（官方要求值为 true）
ENV AGY_CLI_DISABLE_AUTO_UPDATE=true

USER 65532:65532
