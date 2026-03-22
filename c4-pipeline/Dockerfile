# CI/CD and media pipeline image — c4 + common tools.
#
# Includes: c4, git, curl, jq, ffprobe, bash
# Use for: build verification, media asset scanning, pipeline automation

ARG C4_VERSION=1.0.6
ARG TARGETARCH=amd64

FROM alpine:3.21

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    git \
    jq \
    ffmpeg

ARG C4_VERSION
ARG TARGETARCH
RUN if [ "$C4_VERSION" = "latest" ]; then \
      URL="https://github.com/Avalanche-io/c4/releases/latest/download/c4_linux_${TARGETARCH}.tar.gz"; \
    else \
      URL="https://github.com/Avalanche-io/c4/releases/download/v${C4_VERSION}/c4_v${C4_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    fi && \
    curl -fsSL "$URL" | tar xz -C /usr/local/bin c4

ENTRYPOINT ["/usr/local/bin/c4"]
