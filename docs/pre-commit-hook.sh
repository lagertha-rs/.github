#!/bin/sh

# Shared pre-commit hook for local Lagertha workspace repos.
#
# Behavior:
# 1. If staged changes include Rust sources or Cargo.toml, run `cargo fmt --all`.
# 2. If formatting changes the working tree, stop so the user can review and stage the result.
# 3. If Cargo.lock is staged and a workspace-local `.cargo/config.toml` exists, temporarily
#    disable the workspace override, regenerate a clean lockfile, then keep or unstage the
#    lockfile depending on whether it differs from HEAD.

set -e

repo_root=$(git rev-parse --show-toplevel)
workspace_root=$(dirname "$repo_root")
workspace_cargo_config="$workspace_root/.cargo/config.toml"
workspace_cargo_config_bak="$workspace_root/.cargo/config.toml.hook-bak"

unstaged_fingerprint() {
    git diff --binary | git hash-object --stdin
}

if git diff --cached --name-only --diff-filter=ACMR | grep -Eq '(^|/)(Cargo\.toml|.*\.rs)$'; then
    echo "[pre-commit] Running cargo fmt --all"
    pre_fmt_diff=$(unstaged_fingerprint)
    cargo fmt --all
    post_fmt_diff=$(unstaged_fingerprint)

    if [ "$pre_fmt_diff" != "$post_fmt_diff" ]; then
        echo "[pre-commit] cargo fmt updated files. Review and stage them, then commit again."
        exit 1
    fi
fi

# Only act on lockfile cleanup if Cargo.lock is staged.
git diff --cached --name-only | grep -q '^Cargo\.lock$' || exit 0

# No workspace override config means no local-source noise to clean up.
[ -f "$workspace_cargo_config" ] || exit 0

trap 'if [ -f "$workspace_cargo_config_bak" ]; then mv "$workspace_cargo_config_bak" "$workspace_cargo_config"; fi' EXIT

mv "$workspace_cargo_config" "$workspace_cargo_config_bak"

if ! cargo generate-lockfile --quiet 2>/dev/null; then
    echo "[pre-commit] cargo generate-lockfile failed."
    exit 1
fi

if git diff --quiet HEAD -- Cargo.lock; then
    echo "[pre-commit] Cargo.lock changes are local-override noise, unstaging."
    git restore --staged Cargo.lock
else
    echo "[pre-commit] Cargo.lock has real changes, staging clean version."
    git add Cargo.lock
fi
