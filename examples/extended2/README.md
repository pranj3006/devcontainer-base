# Extended Compose Example

This example runs an application Dev Container with PostgreSQL, Redis, and pgAdmin
through Docker Compose. The application image extends `devpranj/devcontainer-base`.

## Files

- [Dockerfile-DevTeam](Dockerfile-DevTeam) defines the application image.
- [sample-dev-docker-compose.yml](sample-dev-docker-compose.yml) defines the
  application, PostgreSQL, Redis, and pgAdmin services. Copy it to
  `dev-docker-compose.yml` before use.
- [.devcontainer/docker-compose.yml](.devcontainer/docker-compose.yml) keeps the
  application container running for VS Code.
- [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) selects the
  application service and opens `/app` as the workspace.

## Setup

1. Copy this directory structure into the root of your application repository.
2. Copy `sample-dev-docker-compose.yml` to `dev-docker-compose.yml`.
3. Set the required database, pgAdmin, and Git build-argument values in
   `dev-docker-compose.yml`. Store credentials in an uncommitted `.env` file rather
   than in the Compose file.
4. Pin the `FROM` image in [Dockerfile-DevTeam](Dockerfile-DevTeam) to an available
   release tag, for example:

   ```dockerfile
   FROM devpranj/devcontainer-base:1.0.0
   ```

5. Open the repository in VS Code and run **Dev Containers: Rebuild Container**.

## Workspace Permissions

The application source is mounted from the host at `/app`. The Dev Container
configuration uses `remoteUser: devuser` and `updateRemoteUserUID: true`, so VS Code
updates `devuser` to match the host UID/GID when it creates the container. This lets
the container edit the mounted files without copying the repository or recursively
changing ownership during the image build.

After the rebuild, verify the mapping inside the container:

```bash
id
ls -ld /app
touch /app/.permission-check && rm /app/.permission-check
```

## Offline Base Image

If Docker Hub access is unavailable on the workstation, load a previously approved
archive and use a local image tag:

```bash
gunzip -c devcontainer-base-latest.tar.gz | docker load
docker tag devpranj/devcontainer-base:latest devcontainer-base:offline
```

Then set the first line of [Dockerfile-DevTeam](Dockerfile-DevTeam) to:

```dockerfile
FROM devcontainer-base:offline
```

## Corporate Certificates

Trust corporate root CAs in the Docker host or Docker Desktop before building, because
the Docker daemon performs image pulls. To trust a CA inside the application image as
well, add the following near the top of [Dockerfile-DevTeam](Dockerfile-DevTeam):

```dockerfile
USER root
COPY company-root-ca.pem /usr/local/share/ca-certificates/company-root-ca.crt
RUN update-ca-certificates
USER devuser
```

Keep `company-root-ca.pem` out of Git and distribute it through your organization's
approved mechanism. Container trust does not replace Docker host certificate trust.
