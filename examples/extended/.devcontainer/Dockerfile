FROM docker.io/devpranj/devcontainer-base:latest

# Switch to root to install additional system packages
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        default-jre-headless \
        && rm -rf /var/lib/apt/lists/*

# Drop back to the non-root development user provided by the base image
USER devuser

# Example: install a specific Python and Node.js version at build time
RUN pyenv install --skip-existing 3.12.4 \
    && pyenv global 3.12.4

RUN bash -lc 'nvm install --lts && nvm alias default lts/*'
