# devcontainer-base

[![Build and Publish](https://github.com/<GITHUB_USERNAME>/devcontainer-base/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/<GITHUB_USERNAME>/devcontainer-base/actions/workflows/docker-publish.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/<DOCKERHUB_USERNAME>/devcontainer-base)](https://hub.docker.com/r/<DOCKERHUB_USERNAME>/devcontainer-base)

A lightweight, reusable Debian-based development container image with
[`pyenv`](https://github.com/pyenv/pyenv) and [`nvm`](https://github.com/nvm-sh/nvm)
pre-installed, intended as a common base for [Dev Containers](https://containers.dev/)
across any polyglot Python/Node.js project.

## Features

- Debian Bookworm (slim) base
- `pyenv` + `pyenv-virtualenv` for managing multiple Python versions
- `nvm` for managing multiple Node.js versions
- Common build toolchain (`build-essential`, `gcc`, `g++`, `make`)
- Git, curl, wget, jq, and other everyday CLI utilities
- PostgreSQL client libraries (`libpq-dev`, `postgresql-client`)
- Non-root `devuser` (UID/GID 1000) with passwordless `sudo`
- Multi-arch images: `linux/amd64` and `linux/arm64`
- Published to [Docker Hub](https://hub.docker.com/) from the `main` branch and version tags; pull requests are built and scanned without publishing

## Quick Start

Pull the image directly:

```bash
docker pull <DOCKERHUB_USERNAME>/devcontainer-base:latest
docker run --rm -it <DOCKERHUB_USERNAME>/devcontainer-base:latest bash
```

Or reference it from a `.devcontainer/devcontainer.json`:

```json
{
  "name": "my-project",
  "image": "<DOCKERHUB_USERNAME>/devcontainer-base:latest",
  "remoteUser": "devuser"
}
```

See [`examples/`](examples/) for complete, ready-to-copy configurations.

## Using as a Dev Container

Two supported approaches are provided in [`examples/`](examples/):

| Approach | Use when | Example |
|---|---|---|
| **Direct** | The base image already has everything you need | [`examples/direct`](examples/direct) |
| **Extended** | You need extra OS packages or build-time customization | [`examples/extended`](examples/extended) |

Open either example folder in VS Code and choose **Reopen in Container**, or run the
**Dev Containers: Reopen in Container** command.

## Installing Python with pyenv

`pyenv` is installed and on `PATH` for `devuser`. Install and select a Python version:

```bash
pyenv install 3.12.4
pyenv global 3.12.4
python --version
```

Create an isolated virtual environment with `pyenv-virtualenv`:

```bash
pyenv virtualenv 3.12.4 myproject
pyenv activate myproject
```

## Installing Node with nvm

`nvm` is installed under `$NVM_DIR` and sourced automatically in interactive and
non-interactive Bash shells. `pyenv` is available in all shells through `PATH`;
interactive shells also load its shims and virtualenv integration:

```bash
nvm install --lts
nvm alias default lts/*
node --version
```

## Extending the Image

To add project-specific system packages or preinstall specific language versions,
build your own image `FROM` this one:

```dockerfile
FROM <DOCKERHUB_USERNAME>/devcontainer-base:1.0.0

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        default-jre-headless \
    && rm -rf /var/lib/apt/lists/*
USER devuser

RUN pyenv install 3.12.4 && pyenv global 3.12.4
RUN bash -lc 'nvm install --lts'
```

See the full [`examples/extended`](examples/extended) sample for a working reference.

## Supported Platforms

Images are built and published for:

- `linux/amd64`
- `linux/arm64`

## Configuration

The image supports the following build arguments (set via `--build-arg` or the
`build.args` field of `devcontainer.json`):

| Argument | Default | Description |
|---|---|---|
| `USERNAME` | `devuser` | Name of the non-root development user |
| `USER_UID` | `1000` | UID of the development user |
| `USER_GID` | `1000` | GID of the development user |
| `PYENV_VERSION` | `2.8.1` | `pyenv` release tag to install |
| `NVM_VERSION` | `0.40.6` | `nvm` release tag to install |

Relevant environment variables set inside the container:

| Variable | Value |
|---|---|
| `PYENV_ROOT` | `/home/${USERNAME}/.pyenv` |
| `NVM_DIR` | `/home/${USERNAME}/.nvm` |
| `BASH_ENV` | `/home/${USERNAME}/.bash_env` |

## Image Tags

Published to [`<DOCKERHUB_USERNAME>/devcontainer-base`](https://hub.docker.com/r/<DOCKERHUB_USERNAME>/devcontainer-base) on Docker Hub:

| Tag | Description |
|---|---|
| `latest` | Latest build from the `main` branch |
| `x.y.z` | Immutable release matching a Git tag `vx.y.z` |
| `x.y` | Latest patch release within a minor version |
| `sha-<shortsha>` | Build from a specific commit |

Pin to an exact version tag (`x.y.z`) for a stable dependency reference; use `latest`
only when you explicitly want the newest published image.

## Security

See [SECURITY.md](SECURITY.md) for the vulnerability disclosure process and a summary
of the security posture of this image (non-root user, no embedded secrets, automated
scanning).

## Troubleshooting

**`pyenv: command not found` in a non-interactive shell**
`PATH` already includes `pyenv`'s `bin`/`shims` directories via `ENV`, so this should
not occur in derived images. If you overwrite `PATH` in your own `Dockerfile`, make
sure to append rather than replace it.

**`nvm: command not found`**
`nvm` is loaded via `BASH_ENV`, which only applies to `bash` shells. Ensure your
`RUN`/`postCreateCommand` invocations use `bash -lc "..."` rather than `sh -c "..."`.

**Permission denied writing to `/workspace`**
Confirm your bind-mounted host directory is owned by (or writable by) UID/GID
`1000`, matching the container's `devuser`.

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for local build,
test, and PR guidelines.

## License

Released under the [MIT License](LICENSE).