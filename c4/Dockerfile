# Minimal c4 CLI image — scratch base, static binary, certs, tzdata.
#
# Build:
#   docker build --build-arg C4_VERSION=1.0.6 -t avalancheio/c4:1.0.6 c4/
#
# Or build from source:
#   docker build -f c4/Dockerfile.build -t avalancheio/c4 .

ARG C4_VERSION=1.0.6
ARG TARGETARCH=amd64

FROM golang:1.26-alpine AS certs
RUN apk add --no-cache ca-certificates tzdata

FROM alpine:3.21 AS fetch
ARG C4_VERSION
ARG TARGETARCH
RUN apk add --no-cache curl
RUN if [ "$C4_VERSION" = "latest" ]; then \
      URL="https://github.com/Avalanche-io/c4/releases/latest/download/c4_linux_${TARGETARCH}.tar.gz"; \
    else \
      URL="https://github.com/Avalanche-io/c4/releases/download/v${C4_VERSION}/c4_v${C4_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    fi && \
    curl -fsSL "$URL" | tar xz -C /usr/local/bin c4

FROM scratch
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=certs /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=fetch /usr/local/bin/c4 /c4
ENTRYPOINT ["/c4"]
