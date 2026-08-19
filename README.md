# devcontainer-base

[![Build and Publish](https://github.com/pranj3006/devcontainer-base/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/pranj3006/devcontainer-base/actions/workflows/docker-publish.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/devpranj/devcontainer-base)](https://hub.docker.com/r/devpranj/devcontainer-base)

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
docker pull devpranj/devcontainer-base:latest
docker run --rm -it devpranj/devcontainer-base:latest bash
```

Or reference it from a `.devcontainer/devcontainer.json`:

```json
{
  "name": "my-project",
  "image": "devpranj/devcontainer-base:latest",
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
| **Extended with Compose** | Your project also runs services such as PostgreSQL or Redis | [`examples/extended2`](examples/extended2) |

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
FROM devpranj/devcontainer-base:1.0.0

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        default-jre-headless \
    && rm -rf /var/lib/apt/lists/*
USER devuser

RUN pyenv install 3.12.4 && pyenv global 3.12.4
RUN bash -lc 'nvm install --lts'
```

See the full [`examples/extended`](examples/extended) sample for a working reference.

## Offline and Restricted Networks

If a workstation cannot pull the image whenever a Dev Container is rebuilt, save a
copy after an approved pull:

```bash
docker pull devpranj/devcontainer-base:latest
docker save devpranj/devcontainer-base:latest | gzip > devcontainer-base-latest.tar.gz
```

Move the archive through your approved internal file-transfer process. On the target
workstation, load it into the local Docker daemon:

```bash
gunzip -c devcontainer-base-latest.tar.gz | docker load
docker tag devpranj/devcontainer-base:latest devcontainer-base:offline
```

Use the local tag in a derived Dockerfile to prevent Docker from contacting Docker
Hub during the build:

```dockerfile
FROM devcontainer-base:offline
```

The archive must be reloaded after Docker Desktop data is reset or the local image is
removed. Do not run image-prune commands that delete unused images if the local copy
must remain available.

## Corporate Certificates

Some corporate networks intercept HTTPS traffic. Configure the corporate root CA in
the Docker host or Docker Desktop first; this lets Docker trust Docker Hub and obtain
its authentication token. Do not disable TLS verification or configure Docker Hub as
an insecure registry.

For a Linux Docker Engine host, where `company-root-ca.pem` is the CA file:

```bash
sudo install -D -m 0644 company-root-ca.pem \
  /usr/local/share/ca-certificates/company-root-ca.crt
sudo update-ca-certificates
sudo install -D -m 0644 company-root-ca.pem \
  /etc/docker/certs.d/registry-1.docker.io/ca.crt
sudo systemctl restart docker
```

If the failure names `auth.docker.io`, install the same CA at
`/etc/docker/certs.d/auth.docker.io/ca.crt` and restart Docker. For Docker Desktop,
import the CA into the operating system's trusted-root certificate store, then restart
Docker Desktop.

To trust the same CA only inside a project-specific derived image, keep the PEM file
outside version control and add this before switching to `devuser`:

```dockerfile
FROM devpranj/devcontainer-base:1.0.0

USER root
COPY company-root-ca.pem /usr/local/share/ca-certificates/company-root-ca.crt
RUN update-ca-certificates
USER devuser
```

This changes trust for tools running *inside* the container. It does not fix Docker's
host-side pull authentication; the host or Docker Desktop must trust the CA separately.

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

Published to [`devpranj/devcontainer-base`](https://hub.docker.com/r/devpranj/devcontainer-base) on Docker Hub:

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

**Permission denied on a bind-mounted workspace**
For Dev Containers, set `"remoteUser": "devuser"` and
`"updateRemoteUserUID": true` in `devcontainer.json`, then use **Dev Containers:
Rebuild Container**. This aligns `devuser` with the host UID/GID when the container
is created. Do not use a broad `chown -R` on a bind-mounted workspace.

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for local build,
test, and PR guidelines.

## License

Released under the [MIT License](LICENSE).