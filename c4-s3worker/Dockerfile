# S3 bucket scanner — lists objects, downloads, computes C4 IDs, produces c4m.
#
# Scans an S3 bucket and produces a c4m manifest of its contents.
# Uses the AWS CLI for listing and c4 for identification.

FROM alpine:3.21

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    aws-cli

ARG C4_VERSION=1.0.6
ARG TARGETARCH=amd64
RUN if [ "$C4_VERSION" = "latest" ]; then \
      URL="https://github.com/Avalanche-io/c4/releases/latest/download/c4_linux_${TARGETARCH}.tar.gz"; \
    else \
      URL="https://github.com/Avalanche-io/c4/releases/download/v${C4_VERSION}/c4_v${C4_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    fi && \
    curl -fsSL "$URL" | tar xz -C /usr/local/bin c4

COPY scan-bucket.sh /usr/local/bin/scan-bucket
RUN chmod +x /usr/local/bin/scan-bucket

ENTRYPOINT ["/usr/local/bin/scan-bucket"]
