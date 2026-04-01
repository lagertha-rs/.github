#!/bin/sh
# Smart Cargo.lock handling for repos with [patch.crates-io] local overrides.
#
# When Cargo.lock is staged, this hook:
#   1. Moves .cargo/config.toml aside (disabling patch overrides)
#   2. Regenerates Cargo.lock from the clean registry sources
#   3. If the clean lockfile differs from HEAD, stages the real changes
#   4. If it matches HEAD, unstages it (it was just patch noise)
#   5. Restores .cargo/config.toml
#
# Use `git commit --no-verify` to bypass entirely.

CARGO_CONFIG=".cargo/config.toml"
CARGO_CONFIG_BAK=".cargo/config.toml.hook-bak"

# Only act if Cargo.lock is staged
git diff --cached --name-only | grep -q '^Cargo\.lock$' || exit 0

# If there's no patch config, nothing special to do — let the staged lockfile through
[ -f "$CARGO_CONFIG" ] || exit 0

# Ensure we always restore the config, even on failure
trap 'if [ -f "$CARGO_CONFIG_BAK" ]; then mv "$CARGO_CONFIG_BAK" "$CARGO_CONFIG"; fi' EXIT

# Move config aside to disable patches
mv "$CARGO_CONFIG" "$CARGO_CONFIG_BAK"

# Regenerate a clean lockfile from registry sources
cargo generate-lockfile --quiet 2>/dev/null

# Check if the clean lockfile differs from what's in HEAD
if git diff --quiet HEAD -- Cargo.lock; then
    # No real changes — this was purely patch noise
    echo "[pre-commit] Cargo.lock changes are patch-override noise, unstaging."
    git restore --staged Cargo.lock
else
    # Real dependency changes — stage the clean version
    echo "[pre-commit] Cargo.lock has real changes, staging clean version."
    git add Cargo.lock
fi

# Restore the patched lockfile for local dev (config.toml restored by trap)
