# Minimal c4 CLI image — scratch base, static binary, certs, tzdata.
#
# Build:
#   docker build --build-arg C4_VERSION=v1.0.12 -t avalancheio/c4:1.0.12 c4/

ARG C4_VERSION=v1.0.12

FROM golang:1.24-alpine AS build
ARG C4_VERSION
RUN apk add --no-cache ca-certificates tzdata git
WORKDIR /src
RUN git clone --depth 1 --branch "${C4_VERSION}" https://github.com/Avalanche-io/c4.git .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /c4 ./cmd/c4/

FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build /c4 /c4
ENTRYPOINT ["/c4"]
