# Contributing

Thanks for your interest in improving `devcontainer-base`. This image is meant to be a
small, stable, widely reusable base — please keep contributions aligned with that goal.

## Getting Started

1. Fork the repository.
2. Create a feature branch from `main`.
3. Make your changes.

## Building Locally

```bash
docker build -t devcontainer-base:dev .
```

Build for a specific platform:

```bash
docker buildx build --platform linux/arm64 -t devcontainer-base:dev .
```

## Running the Smoke Tests

```bash
./tests/smoke-test.sh devcontainer-base:dev
```

All smoke tests must pass before a PR is merged.

## Linting

Dockerfile changes are linted with [Hadolint](https://github.com/hadolint/hadolint) in CI.
You can run it locally:

```bash
docker run --rm -i hadolint/hadolint < Dockerfile
```

## Guidelines

- Keep the image minimal — avoid adding packages that aren't broadly useful across
  Python/Node.js projects. Project-specific tooling belongs in an extended image
  (see [`examples/extended`](examples/extended)).
- Pin versions (build args, package versions) rather than floating on `latest`.
- Update [`CHANGELOG.md`](CHANGELOG.md) under `[Unreleased]` for any user-facing change.
- Update [`README.md`](README.md) if you change build args, environment variables, or
  supported behavior.
- Never commit secrets, credentials, or personal configuration.

## Submitting a Pull Request

1. Ensure the image builds and smoke tests pass locally.
2. Update documentation as needed.
3. Submit a pull request describing the change and its motivation.
4. CI will lint, build, smoke test, and vulnerability-scan the image automatically.

## Maintainers: Publishing Setup

Publishing to Docker Hub (the `publish` job in
[`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml)) runs on
every push to `main` and on `v*.*.*` tags. It requires the following configured on the
repository (Settings → Secrets and variables → Actions):

| Name | Type | Description |
|---|---|---|
| `DOCKERHUB_USERNAME` | Variable | Docker Hub username/namespace the image is pushed to |
| `DOCKERHUB_TOKEN` | Secret | Docker Hub [access token](https://hub.docker.com/settings/security) with read/write/delete scope |

Releases are tagged as `vx.y.z` on `main`; the workflow derives `latest`, `x.y.z`, and
`x.y` image tags automatically from the Git tag.

