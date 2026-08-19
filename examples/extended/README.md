# Extended Usage Example

This example shows how to extend `devcontainer-base` with your own Dockerfile when you
need additional system packages, build-time tool installation, or other customization.

## Usage

1. Copy the `.devcontainer/` folder into your project.
2. Update the `FROM` line in [`Dockerfile`](.devcontainer/Dockerfile) to pin the base
   image tag you want to build on, for example:

   ```dockerfile
   FROM docker.io/<DOCKERHUB_USERNAME>/devcontainer-base:1.0.0
   ```

3. Add any additional `apt-get install`, `pyenv install`, or `nvm install` steps your
   project needs.
4. Open the project folder in VS Code and select **Reopen in Container** (or run
   **Dev Containers: Reopen in Container** from the command palette). VS Code will
   build your extended image locally using the published base image as its starting
   layer.

## When to use this approach

Use the extended approach when your project needs:

- Additional OS packages (compilers, database clients, etc.)
- A specific Python/Node.js version baked into the image at build time
- Any other customization on top of the base tooling

For simple cases where the base image is sufficient as-is, see the
[`direct`](../direct/README.md) example instead.
