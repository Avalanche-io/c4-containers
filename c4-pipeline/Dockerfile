# CI/CD and media pipeline image — c4 + common tools.
#
# Includes: c4, git, curl, jq, ffprobe, bash
# Use for: build verification, media asset scanning, pipeline automation

ARG C4_VERSION=v1.0.13

FROM golang:1.24-alpine AS build
ARG C4_VERSION
RUN apk add --no-cache git
WORKDIR /src
RUN git clone --depth 1 --branch "${C4_VERSION}" https://github.com/Avalanche-io/c4.git .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /c4 ./cmd/c4/

FROM alpine:3.21
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    git \
    jq \
    ffmpeg
COPY --from=build /c4 /usr/local/bin/c4
ENTRYPOINT ["/usr/local/bin/c4"]
