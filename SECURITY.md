# Security Policy

## Supported Versions

Only the most recently published `latest` tag and the most recent `x.y.z` release
receive security fixes. Older tags remain available for reproducibility but are not
actively patched.

| Version | Supported |
|---|---|
| `latest` | Yes |
| Latest `x.y.z` | Yes |
| Older tags | No |

## Reporting a Vulnerability

Please **do not** report security vulnerabilities through public GitHub issues.

Instead, report them privately using the GitHub security advisory channel:

- GitHub [private security advisory](../../security/advisories/new) for this repository

Please include:

- A description of the vulnerability and its potential impact
- Steps to reproduce, including the image tag/digest used
- Any relevant logs or proof-of-concept

You should expect an initial response within 5 business days. We will work with you
to validate, fix, and coordinate disclosure before any public announcement.

## Security Posture

This image is built with the following security practices:

- Runs as a non-root user (`devuser`) by default; `sudo` is available but must be
  invoked explicitly.
- Multi-arch images are built from the minimal `debian:bookworm-slim` base. Pin the
  published image by digest when strict supply-chain reproducibility is required.
- Every build is scanned with [Trivy](https://github.com/aquasecurity/trivy) in CI;
  critical/high findings are reported in the build logs.
- Dependencies (`pyenv`, `nvm`) are installed from pinned upstream release tags, not
  `HEAD`/`main`, to make builds more auditable.
- The image does **not** intentionally contain:
  - credentials or API keys
  - SSH private keys
  - application source code
  - personal configuration files

## Disclosure Policy

We follow coordinated disclosure. Once a fix is available, we will publish a patched
image, update [`CHANGELOG.md`](CHANGELOG.md), and credit the reporter (unless they
prefer to remain anonymous).
