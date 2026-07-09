# C4 Containers

Container images and deployment examples for the [C4](https://github.com/Avalanche-io/c4) content-addressable identification system.

## Images

### `avalancheio/c4` — Minimal CLI

Scratch-based image with just the static c4 binary (~3MB), TLS certificates, and timezone data. Works with local storage or S3-compatible object stores.

```bash
# Identify a directory
docker run -v $(pwd):/data avalancheio/c4 id /data

# Scan with local store
docker run -v $(pwd):/data -v c4store:/store -e C4_STORE=/store \
  avalancheio/c4 id -s /data

# Scan with S3 store
docker run -v $(pwd):/data \
  -e C4_STORE=s3://bucket/prefix?region=us-west-2 \
  -e AWS_ACCESS_KEY_ID=... \
  -e AWS_SECRET_ACCESS_KEY=... \
  avalancheio/c4 id -s /data

# Reconcile a directory to match a c4m manifest
docker run -v ./manifest.c4m:/manifest.c4m:ro -v ./target:/data \
  -v c4store:/store -e C4_STORE=/store \
  avalancheio/c4 patch /manifest.c4m /data/

# Diff two directories
docker run -v ./old:/old:ro -v ./new:/new:ro \
  avalancheio/c4 diff /old /new
```

### `avalancheio/c4-pipeline` — CI/CD and Media

Alpine-based with c4 + git, curl, jq, ffprobe. For build pipelines, media asset management, and automation scripts.

```bash
docker run -v $(pwd):/data avalancheio/c4-pipeline id /data
```

### `avalancheio/c4-s3worker` — S3 Bucket Scanner

Scans an S3 bucket and produces a c4m manifest. Downloads objects via the AWS CLI, then computes C4 IDs with the c4 binary. Works with any S3-compatible provider.

```bash
docker run \
  -e S3_BUCKET=my-bucket \
  -e S3_PREFIX=assets/ \
  -e AWS_ACCESS_KEY_ID=... \
  -e AWS_SECRET_ACCESS_KEY=... \
  -v ./output:/output \
  avalancheio/c4-s3worker
# Output: ./output/manifest.c4m
```

## Compose Examples

### Scanner — capture a directory state

```bash
C4_INPUT=/path/to/scan docker compose -f compose/scanner.yml up
```

Produces `./output/manifest.c4m` with content stored in a Docker volume.

### S3 Pipeline — scan, store, materialize

```bash
cp compose/.env.example compose/.env
# Edit .env with your S3 credentials
docker compose -f compose/s3-pipeline.yml run scan
docker compose -f compose/s3-pipeline.yml run materialize
docker compose -f compose/s3-pipeline.yml run verify
```

Full workflow: scan a directory, store content to S3, ship the c4m file, materialize at the destination, verify the result.

### Materializer — hydrate from stored content

```bash
C4_MANIFEST=./target.c4m docker compose -f compose/materializer.yml up
```

## Kubernetes Examples

### Render Pipeline (`k8s/render-pipeline.yaml`)

Full VFX/media render workflow:
1. **Init container** materializes assets from S3 to shared volume
2. **Render container** processes assets
3. **Sidecar** captures output to S3 store + c4m artifact

The c4m manifest is the contract: `assets.c4m` defines inputs (checked into source control), `output.c4m` captures outputs (build artifact). Content lives in S3.

### Scanner CronJob (`k8s/scanner-cronjob.yaml`)

Daily snapshot of a PersistentVolume. Diff consecutive snapshots to see exactly what changed.

### Materializer Job (`k8s/materializer-job.yaml`)

Hydrate a PersistentVolume from a c4m manifest. Pre-flight check ensures all content is available before writing.

## Building

```bash
# From release binary (default: v1.0.15)
docker build --build-arg C4_VERSION=1.0.15 -t avalancheio/c4:1.0.15 c4/

# From source (run from the c4 repo root)
docker build -f c4-containers/c4/Dockerfile.build -t avalancheio/c4 .
```

## S3-Compatible Stores

All images support any S3-compatible object store:

| Provider | Endpoint |
|----------|----------|
| AWS S3 | (default, no endpoint needed) |
| MinIO | `S3_ENDPOINT=http://minio.local:9000` |
| Backblaze B2 | `S3_ENDPOINT=https://s3.us-west-002.backblazeb2.com` |
| Wasabi | `S3_ENDPOINT=https://s3.wasabisys.com` |
| Ceph RGW | `S3_ENDPOINT=http://ceph-rgw.local` |

## License

Apache 2.0
