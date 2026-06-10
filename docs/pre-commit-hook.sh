#!/bin/sh

# Shared pre-commit hook for Lagertha workspace repos.
#
# Behavior:
# 1. Run `cargo fmt --all` on all staged Rust sources.
# 2. Run `cargo clippy` with -D warnings.
# 3. Stop the commit if any check fails.

set -e

if git diff --cached --name-only --diff-filter=ACMR | grep -Eq '(^|/)(Cargo\.toml|.*\.rs)$'; then
    echo "[pre-commit] Running cargo fmt --all"
    pre_fmt_diff=$(git diff | git hash-object --stdin)
    cargo fmt --all
    post_fmt_diff=$(git diff | git hash-object --stdin)

    if [ "$pre_fmt_diff" != "$post_fmt_diff" ]; then
        echo "[pre-commit] cargo fmt updated files. Review and stage them, then commit again."
        exit 1
    fi
fi

echo "[pre-commit] Running cargo clippy..."
cargo clippy --workspace --all-targets --all-features -- -D warnings
