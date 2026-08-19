# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-18

### Added

- Debian Bookworm Slim base
- pyenv
- pyenv-virtualenv
- nvm
- Git
- PostgreSQL client
- Development utilities
- Non-root devuser
- GitHub Actions workflow to lint, build, scan, and publish multi-arch images to Docker Hub
- Direct and extended Dev Container usage examples
- Smoke test suite

### Security

- No credentials included
- No application source included
- Images scanned with Trivy on every build
