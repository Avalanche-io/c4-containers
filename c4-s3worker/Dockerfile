# S3 bucket scanner — lists objects, downloads, computes C4 IDs, produces c4m.
#
# Scans an S3 bucket and produces a c4m manifest of its contents.
# Uses the AWS CLI for listing and c4 for identification.

ARG C4_VERSION=v1.0.15

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
    aws-cli
COPY --from=build /c4 /usr/local/bin/c4
COPY scan-bucket.sh /usr/local/bin/scan-bucket
RUN chmod +x /usr/local/bin/scan-bucket
ENTRYPOINT ["/usr/local/bin/scan-bucket"]
