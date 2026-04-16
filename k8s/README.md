# Kubernetes Builds on NRP Nautilus

HighTide uses the [National Research Platform (NRP) Nautilus](https://nationalresearchplatform.org/nautilus/) Kubernetes cluster to build designs at scale. Each design is submitted as a separate K8s Job, and build results are uploaded to a shared GCS remote cache.

## Prerequisites

- `kubectl` configured with access to the NRP Nautilus cluster
- Namespace `vlsida` with the `gcs-bazel-cache` secret for cache uploads

See the [NRP Nautilus documentation](https://docs.nrp-nautilus.io/) for cluster access and configuration.

## Submitting Jobs

Each invocation of `run.sh` creates one K8s Job per matching design. Jobs clone the HighTide repo, install Bazel, and run the full RTL-to-GDSII flow plus stage image generation using bazel-orfs.

```bash
# Submit all designs, all platforms
./k8s/run.sh

# Submit all designs for a platform
./k8s/run.sh asap7

# Submit a single design
./k8s/run.sh asap7 lfsr

# Submit a design across all platforms
./k8s/run.sh --design lfsr

# Preview generated YAML without submitting
./k8s/run.sh --dry-run asap7
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--branch BRANCH` | `main` | Git branch to build |
| `--cpu NUM` | `8` | CPU request per job |
| `--mem SIZE` | `64Gi` | Memory request per job (limit is 2x) |
| `--upload-artifacts` | off | Upload `bazel-bin` artifacts to GCS for debug (see below) |
| `--dry-run` | | Print YAML without submitting |

## Monitoring Jobs

```bash
# Show status of all HighTide jobs and pods
./k8s/run.sh --status

# Stream logs for a specific job
kubectl logs -f job/hightide-asap7-lfsr -n vlsida
```

Job names follow the pattern `hightide-<platform>-<design>`, e.g., `hightide-asap7-lfsr`, `hightide-nangate45-bp-uno`.

## Deleting Jobs

Jobs can be deleted by platform, design, or both. Deletion uses Kubernetes label selectors on the `platform` and `design` labels attached to each job.

```bash
# Delete all HighTide jobs
./k8s/run.sh --delete

# Delete all jobs for a platform
./k8s/run.sh --delete asap7

# Delete a specific design on a platform
./k8s/run.sh --delete asap7 lfsr

# Delete a design across all platforms
./k8s/run.sh --delete --design lfsr
```

## Remote Cache

Jobs are configured with a GCS remote cache (`--remote_cache`). When the `gcs-bazel-cache` secret is present in the namespace, jobs upload build results after completion. This enables:

1. **Faster rebuilds** — subsequent jobs for the same design hit the cache
2. **Local fetching** — developers can pull baseline results without building locally

### Fetching Baseline Results

HighTide generates baseline build results for all designs. Users can fetch these locally using `tools/fetch_cache.sh`:

```bash
# Fetch all cached designs
./tools/fetch_cache.sh

# Fetch all cached designs for a platform
./tools/fetch_cache.sh asap7

# Fetch a specific design
./tools/fetch_cache.sh asap7 lfsr

# Fetch only through a specific stage (synth, floorplan, place, cts, route, final, all)
./tools/fetch_cache.sh --stage synth asap7

# Fetch full flow + stage images
./tools/fetch_cache.sh --stage all asap7
```

The script uses `--local_cpu_resources=0` to prevent local builds — it only succeeds if results are available in the remote cache. Each design reports `OK (remote)`, `OK (local)`, or `NOT CACHED`.

After fetching, view results with:

```bash
./tools/summary.sh
```

## Build Artifacts (Debug)

For debugging individual builds, K8s jobs can save their full `bazel-bin/<design>/` outputs (results, reports, logs) to persistent storage on Nautilus. Use `--upload-artifacts` when submitting:

```bash
./k8s/run.sh --upload-artifacts asap7 lfsr
```

Artifacts are stored on the `hightide-artifacts` PVC (CephFS, ReadWriteMany) at `/artifacts/designs/<platform>/<design>/`. When `--upload-artifacts` is enabled, `--remote_download_outputs=all` is also set to ensure all intermediate stage outputs are fetched from the cache, not just the final stage.

### Fetching Artifacts

`tools/fetch_artifacts.sh` copies artifacts from the PVC to a local `artifacts/` directory via a temporary pod. By default, artifacts are **deleted** from the PVC after a successful fetch (use `--keep` to preserve them).

```bash
# Fetch all available artifacts
./tools/fetch_artifacts.sh

# Fetch artifacts for a specific design
./tools/fetch_artifacts.sh asap7 lfsr

# Fetch and keep artifacts on the PVC
./tools/fetch_artifacts.sh --keep asap7 lfsr

# Fetch to a custom directory
./tools/fetch_artifacts.sh --output-dir debug asap7 lfsr
```

After fetching, the artifacts are at `artifacts/<platform>/<design>/` (containing `results/`, `reports/`, `logs/`).

### Deleting Artifacts

`tools/delete_artifacts.sh` removes artifacts from the PVC without fetching them. It prompts for confirmation by default (skip with `--yes`).

```bash
# Delete artifacts for a specific design
./tools/delete_artifacts.sh asap7 lfsr

# Delete all artifacts on a platform
./tools/delete_artifacts.sh asap7

# Delete all artifacts without confirmation
./tools/delete_artifacts.sh --yes
```

Both fetch and delete tools require `kubectl` access to the Nautilus cluster.

## Job Template

The job template (`job-template.yaml`) defines the K8s Job spec. Each job:

1. Clones the HighTide repo (init container using `alpine/git`)
2. Installs dependencies (`curl`, `git`, `build-essential`, `python3`, `python3-yaml`, `python3-numpy`, `time`)
3. Installs Bazelisk
4. Runs `bazel build` with the remote cache flags
5. Optionally copies artifacts to the `hightide-artifacts` PVC

The container uses `ubuntu:24.04` as a base image. ORFS tools are extracted from the Docker image by bazel-orfs at build time (via OCI layer extraction), matching the local build environment so that cache keys are compatible.

Jobs have `backoffLimit: 1` (one retry on failure) and `ttlSecondsAfterFinished: 3600` (auto-cleanup after 1 hour).

### Volumes

| Volume | Type | Purpose |
|--------|------|---------|
| `repo` | emptyDir | Cloned repo (ephemeral) |
| `gcs-key` | Secret (`gcs-bazel-cache`, optional) | GCS credentials for remote cache |
| `artifacts` | PVC (`hightide-artifacts`) | Persistent artifact storage for debug |
