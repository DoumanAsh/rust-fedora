ARG FEDORA_VERSION=latest
FROM quay.io/fedora/fedora:$FEDORA_VERSION

LABEL maintainer="Douman <douman@gmx.se>"

ARG INSTALLATION_TYPE
ARG CARGO_AUDITABLE=0.7.7

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    CMAKE_GENERATOR="Ninja"

RUN dnf -y install rust cargo cmake ninja; \
    if [ "${INSTALLATION_TYPE}" = "rustup" ]; then \
        dnf -y remove --no-autoremove  rust cargo ; \
        curl -fsSL -o rustup.sh https://sh.rustup.rs && \
        chmod +x rustup.sh && \
        ./rustup.sh -y --profile minimal && \
        find $RUSTUP_HOME -type f -executable -exec strip --strip-unneeded {} \; && \ 
        find $RUSTUP_HOME -name *.so -exec strip --strip-unneeded {} \; && \
        find $RUSTUP_HOME -name *.rlib -exec strip -d {} \; && \ 
        find $RUSTUP_HOME -name *.a -exec strip -d {} \; && \
        rm -f rustup.sh; \
    fi ;\
    systemArch="$(uname -m)"; \
    case "$systemArch" in \
        x86_64) rustArch='x86_64-unknown-linux-musl' ;; \
        aarch64) rustArch='aarch64-unknown-linux-musl' ;; \
        *) echo >&2 "unsupported architecture: $systemArch"; exit 1 ;; \
    esac; \
    mkdir -p $CARGO_HOME/bin ;\
    curl -L -o /tmp/cargo-auditable-${rustArch}.tar.xz  https://github.com/rust-secure-code/cargo-auditable/releases/download/v$CARGO_AUDITABLE/cargo-auditable-${rustArch}.tar.xz ;\
    tar -xf /tmp/cargo-auditable-${rustArch}.tar.xz -C $CARGO_HOME/bin/ --strip-components=1 cargo-auditable-${rustArch}/cargo-auditable ;\
    rm /tmp/cargo-auditable-${rustArch}.tar.xz ;\
    chmod +x $CARGO_HOME/bin/cargo-auditable ;\
    dnf clean all
