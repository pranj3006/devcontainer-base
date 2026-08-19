FROM debian:bookworm-slim

# ============================================================
# Build arguments
# ============================================================

# hadolint ignore=DL3064
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000

ARG PYENV_VERSION=2.8.1
ARG NVM_VERSION=0.40.6

# ============================================================
# OCI image metadata
# ============================================================

LABEL org.opencontainers.image.title="devcontainer-base" \
      org.opencontainers.image.description="Reusable Debian-based Dev Container base image with pyenv and nvm" \
    org.opencontainers.image.source="https://github.com/pranj3006/devcontainer-base" \
    org.opencontainers.image.documentation="https://github.com/pranj3006/devcontainer-base/blob/main/README.md" \
      org.opencontainers.image.licenses="MIT"

# ============================================================
# Environment
# ============================================================

ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# pyenv
ENV PYENV_ROOT=/home/${USERNAME}/.pyenv

# nvm
ENV NVM_DIR=/home/${USERNAME}/.nvm

# Make pyenv available globally
ENV PATH=${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}

# ============================================================
# Shell
# ============================================================

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ============================================================
# System dependencies
#
# These are required mainly so that pyenv can compile
# different Python versions.
# ============================================================

# Debian package versions are resolved from the current Bookworm repositories;
# pinning every transitive build dependency would prevent normal security updates.
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    make \
    gcc \
    g++ \
    \
    # General development tools
    git \
    curl \
    wget \
    ca-certificates \
    gnupg \
    unzip \
    zip \
    jq \
    pkg-config \
    \
    # Editors / utilities
    vim \
    nano \
    less \
    procps \
    sudo \
    \
    # Python build dependencies
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    libgdbm-dev \
    libnss3-dev \
    uuid-dev \
    \
    # PostgreSQL development/client tools
    libpq-dev \
    postgresql-client \
    \
    # Useful networking/debugging tools
    iputils-ping \
    net-tools \
    dnsutils \
    \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Create development user
# ============================================================

RUN groupadd \
        --gid ${USER_GID} \
        ${USERNAME} \
    && useradd \
        --uid ${USER_UID} \
        --gid ${USER_GID} \
        --create-home \
        --shell /bin/bash \
        ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" \
        > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}


# ============================================================
# Install pyenv
# ============================================================

RUN git clone \
        --branch v${PYENV_VERSION} \
        --depth 1 \
        https://github.com/pyenv/pyenv.git \
        ${PYENV_ROOT} \
    && chown -R ${USERNAME}:${USERNAME} ${PYENV_ROOT}

# Install pyenv-virtualenv
RUN git clone \
        --branch v1.2.4 \
        --depth 1 \
        https://github.com/pyenv/pyenv-virtualenv.git \
        ${PYENV_ROOT}/plugins/pyenv-virtualenv \
    && chown -R ${USERNAME}:${USERNAME} \
        ${PYENV_ROOT}/plugins/pyenv-virtualenv

# ============================================================
# Install nvm
# ============================================================

RUN mkdir -p ${NVM_DIR} \
    && chown -R ${USERNAME}:${USERNAME} ${NVM_DIR}

# ============================================================
# System-wide shell init (root)
#
# Debian's /etc/profile unconditionally resets PATH for login
# shells, which would otherwise wipe out the pyenv/nvm PATH set
# via ENV above. Dropping a script in /etc/profile.d/ ensures
# pyenv and nvm are available in *both* login and non-login
# shells (interactive or not), which many CI and Dev Container
# lifecycle hooks rely on.
# ============================================================

RUN echo "export PYENV_ROOT=\"\${PYENV_ROOT:-\$HOME/.pyenv}\"" > /etc/profile.d/00-devtools.sh \
    && echo "export PATH=\"\$PYENV_ROOT/bin:\$PYENV_ROOT/shims:\$PATH\"" >> /etc/profile.d/00-devtools.sh \
    && echo 'if command -v pyenv >/dev/null 2>&1; then' >> /etc/profile.d/00-devtools.sh \
    && echo "    eval \"\$(pyenv init - --no-rehash bash)\"" >> /etc/profile.d/00-devtools.sh \
    && echo "    eval \"\$(pyenv virtualenv-init -)\"" >> /etc/profile.d/00-devtools.sh \
    && echo 'fi' >> /etc/profile.d/00-devtools.sh \
    && echo "export NVM_DIR=\"\${NVM_DIR:-\$HOME/.nvm}\"" >> /etc/profile.d/00-devtools.sh \
    && echo "if [ -s \"\$NVM_DIR/nvm.sh\" ]; then" >> /etc/profile.d/00-devtools.sh \
    && echo "    . \"\$NVM_DIR/nvm.sh\"" >> /etc/profile.d/00-devtools.sh \
    && echo 'fi' >> /etc/profile.d/00-devtools.sh \
    && echo "if [ -s \"\$NVM_DIR/bash_completion\" ]; then" >> /etc/profile.d/00-devtools.sh \
    && echo "    . \"\$NVM_DIR/bash_completion\"" >> /etc/profile.d/00-devtools.sh \
    && echo 'fi' >> /etc/profile.d/00-devtools.sh

# ============================================================
# Switch to development user
# ============================================================

USER ${USERNAME}

WORKDIR /workspace

# ============================================================
# Configure Bash environment
#
# BASH_ENV is important because Dev Containers and other
# tooling frequently execute non-interactive bash shells.
# ============================================================

ENV BASH_ENV=/home/${USERNAME}/.bash_env

# ============================================================
# Install nvm
# ============================================================

RUN curl -fsSL \
        https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh \
    | PROFILE=${BASH_ENV} bash \
    && echo '. /etc/profile.d/00-devtools.sh' >> ~/.bashrc \
    && echo "export NVM_DIR=\"\${NVM_DIR:-\$HOME/.nvm}\"" >> ${BASH_ENV} \
    && echo "if [ -s \"\$NVM_DIR/nvm.sh\" ]; then" >> ${BASH_ENV} \
    && echo "    . \"\$NVM_DIR/nvm.sh\"" >> ${BASH_ENV} \
    && echo 'fi' >> ${BASH_ENV} \
    # Drop nvm's own git history/test fixtures: irrelevant at runtime, bloats image and vuln scans
    && rm -rf ${NVM_DIR}/.git ${NVM_DIR}/test

# ============================================================
# Default container settings
# ============================================================

WORKDIR /workspace

EXPOSE 8000


CMD ["bash"]