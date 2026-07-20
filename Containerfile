# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Continuwuity" \
        org.opencontainers.image.description="Matrix Homeserver" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/continuwuity" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-continuwuity/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-continuwuity.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    CONTINUWUITY_VERSION="v26.6.2" \
    CONTINUWUITY_REPO_URL="https://forgejo.ellis.link/continuwuation/continuwuity"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    IMAGE_NAME="nfrastack/continuwuity" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-continuwuity/"

RUN echo "" && \
    BUILD_ENV=" \
                10-nginx/ENABLE_NGINX=FALSE \
                10-nginx/NGINX_MODE=proxy \
                10-nginx/NGINX_PROXY_URL=http://localhost:[env:LISTEN_PORT] \
                10-nginx/NGINX_SITE_ENABLED=continuwuity \
              " \
              && \
    CONTINUWUITY_BUILD_DEPS_ALPINE=" \
                                    build-base \
                                    cargo \
                                    clang \
                                    clang-dev \
                                    clang22-static \
                                    cmake \
                                    git \
                                    libffi-dev \
                                    linux-headers \
                                    liburing-dev \
                                    llvm22 \
                                    llvm22-static \
                                    ncurses-static \
                                    openssl-dev \
                                    pkgconfig \
                                    zlib-static \
                                    zstd-static \
                                  " \
                                  && \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user continuwuity 8008 continuwuity 8008 /dev/null && \
    package update && \
    package upgrade && \
    package install \
                        CONTINUWUITY_BUILD_DEPS \
                        && \
    \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --profile minimal --default-toolchain 1.97.1 && \
    . "$HOME/.cargo/env" && \
    \
    export LIBCLANG_PATH="/usr/lib/llvm22/lib" && \
    export RUSTFLAGS="-L /usr/lib" && \
    printf '#!/bin/sh\nLLVMDIR=/usr/lib/llvm22/lib\ncase "$1" in\n  --version) echo "22.1.3" ;;\n  --prefix) echo "/usr/lib/llvm22" ;;\n  --libdir) echo "$LLVMDIR" ;;\n  --includedir) echo "/usr/lib/llvm22/include" ;;\n  --libs) for f in "$LLVMDIR"/libLLVM*.a; do n=$(basename "$f" .a); echo -n "-l${n#lib} "; done; echo -n "-lzstd" ;;\n  --system-libs) echo "-lzstd" ;;\n  --components) echo "all" ;;\n  --shared-mode) echo "static" ;;\n  *) exit 1 ;;\nesac\n' > /usr/local/bin/llvm-config && \
    chmod +x /usr/local/bin/llvm-config && \
    export PATH="/usr/local/bin:$PATH" && \
    \
    clone_git_repo "${CONTINUWUITY_REPO_URL}" "${CONTINUWUITY_VERSION}" /usr/src/continuwuity && \
    cd /usr/src/continuwuity && \
    cargo build --release \
        --no-default-features \
        --features "brotli_compression,direct_tls,element_hacks,gzip_compression,io_uring,media_thumbnail,url_preview,zstd_compression,sentry_telemetry,otlp_telemetry,console,ring,bindgen-static" \
        && \
    strip target/release/conduwuit && \
    cp target/release/conduwuit /usr/local/bin/ && \
    mkdir -p /container/data/continuwuity/ && \
    cp conduwuit-example.toml /container/data/continuwuity/conduwuit.toml.sample && \
    container_build_log add "Continuwuity" "${CONTINUWUITY_VERSION}" "${CONTINUWUITY_REPO_URL}" && \
    \
    package remove \
                    CONTINUWUITY_BUILD_DEPS \
                    && \
    package cleanup && \
    rm -rf \
        /root/.cargo \
        /root/.rustup \
        /usr/src/continuwuity

COPY rootfs /
