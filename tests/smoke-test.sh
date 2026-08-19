#!/usr/bin/env bash
#
# Smoke test for the devcontainer-base image.
# Verifies that the core toolchain (pyenv, nvm, git, non-root user) works as expected.
#
# Usage: ./tests/smoke-test.sh [image-tag]

set -euo pipefail

IMAGE="${1:-devcontainer-base:test}"

pass=0
fail=0

echo "Running smoke tests against image: ${IMAGE}"
echo "============================================="

if docker run --rm "${IMAGE}" bash -s > /tmp/smoke-test.log 2>&1 <<'CONTAINER_SCRIPT'
set -euo pipefail

pass=0
fail=0

check() {
    local description="$1"
    local command="$2"

    if bash -c "${command}"; then
        echo "PASS: ${description}"
        pass=$((pass + 1))
    else
        echo "FAIL: ${description}"
        fail=$((fail + 1))
    fi
}

check "runs as non-root user" '[ "$(id -u)" -ne 0 ]'
check "sudo is available" 'command -v sudo'
check "git is installed" 'command -v git'
check "curl is installed" 'command -v curl'
check "pyenv is installed" 'command -v pyenv'
check "pyenv-virtualenv plugin is present" '[ -d "$PYENV_ROOT/plugins/pyenv-virtualenv" ]'
check "nvm is installed" 'source "$NVM_DIR/nvm.sh" && command -v nvm'
check "python can be installed via pyenv" 'pyenv install --list | grep "3.12" >/dev/null'
check "workspace directory exists" '[ -d /workspace ]'
check "bash is the default shell" '[ "$SHELL" = "/bin/bash" ] || echo "$0" | grep bash >/dev/null'

echo "============================================="
echo "Results: ${pass} passed, ${fail} failed"

if [ "${fail}" -ne 0 ]; then
    exit 1
fi
CONTAINER_SCRIPT
then
    cat /tmp/smoke-test.log
else
    cat /tmp/smoke-test.log
    exit 1
fi

