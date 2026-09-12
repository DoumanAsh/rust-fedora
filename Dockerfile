ARG FEDORA_VERSION=latest
FROM fedora:$FEDORA_VERSION

LABEL maintainer="Douman <douman@gmx.se>"

ARG INSTALLATION_TYPE

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
        rm -f rustup.sh; \
    fi && \
    dnf clean all
