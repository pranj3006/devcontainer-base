# Direct Usage Example

This example shows the simplest way to consume the published `devcontainer-base` image
directly in a Dev Container, with no local build step.

## Usage

1. Copy the `.devcontainer/` folder into your project.
2. Update the `image` field in [`devcontainer.json`](.devcontainer/devcontainer.json) to
   point at the published image tag you want to use, for example:

   ```json
   "image": "docker.io/devpranj/devcontainer-base:1.0.0"
   ```

3. Open the project folder in VS Code and select **Reopen in Container** when prompted
   (or run **Dev Containers: Reopen in Container** from the command palette).
4. VS Code will pull the image and start the container. `pyenv` and `nvm` are already
   installed; `postCreateCommand` installs a default Python and Node.js version.

## When to use this approach

Use the direct approach when you don't need to add any OS packages or build steps on
top of the base image — you only need Python, Node.js, and the common developer
tooling already baked in.

If you need extra system packages or custom setup, see the
[`extended`](../extended/README.md) example instead.
