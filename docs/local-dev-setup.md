# Local Development Setup

This guide explains how to set up cross-repo local development so changes in one crate are immediately reflected in dependent crates without publishing to crates.io.

## Prerequisites

Clone all repos into a shared workspace directory:

```sh
mkdir lvm-workspace && cd lvm-workspace
gh repo clone lagertha-rs/lvm-common
gh repo clone lagertha-rs/lvm-class
gh repo clone lagertha-rs/rns-lang
gh repo clone lagertha-rs/rnsc
gh repo clone lagertha-rs/rns-lsp
gh repo clone lagertha-rs/lagertha-vm
```

## Patch overrides (.cargo/config.toml)

Cargo's `[patch.crates-io]` in `.cargo/config.toml` redirects crates.io dependencies to local paths. This file is gitignored so it stays local-only.

Create `.cargo/config.toml` in each repo that has crates.io dependencies on sibling crates:

### lvm-class

```toml
[patch.crates-io]
lvm-common = { path = "../lvm-common" }
```

### rns-lang

```toml
[patch.crates-io]
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
```

### rnsc

```toml
[patch.crates-io]
rns-lang = { path = "../rns-lang" }
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
```

### rns-lsp

```toml
[patch.crates-io]
rns-lang = { path = "../rns-lang" }
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
```

### lagertha-vm

```toml
[patch.crates-io]
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
```

### lvm-common

No `.cargo/config.toml` needed (no internal dependencies).

## Pre-commit hook for Cargo.lock

The patch overrides cause `Cargo.lock` to diverge from the registry version. Binary crates (`rnsc`, `rns-lsp`, `lagertha-vm`) track `Cargo.lock` in git, so this creates unwanted noise.

Install the following pre-commit hook in each binary crate repo. It automatically handles `Cargo.lock` on commit:

- If `Cargo.lock` changes are **only** from patch overrides, they are silently unstaged
- If there are **real** dependency changes, a clean lockfile (without patches) is generated and staged
- Use `git commit --no-verify` to bypass the hook entirely

### Installation

Save the script below as `.git/hooks/pre-commit` and make it executable:

```sh
chmod +x .git/hooks/pre-commit
```

### Hook script

```sh
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
```

## Quick setup script

Run this from the workspace root to set up all config files and hooks at once:

```sh
#!/bin/sh
# Run from the workspace root (parent of all repo dirs)

# lvm-class
mkdir -p lvm-class/.cargo
cat > lvm-class/.cargo/config.toml << 'EOF'
[patch.crates-io]
lvm-common = { path = "../lvm-common" }
EOF

# rns-lang
mkdir -p rns-lang/.cargo
cat > rns-lang/.cargo/config.toml << 'EOF'
[patch.crates-io]
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
EOF

# rnsc
mkdir -p rnsc/.cargo
cat > rnsc/.cargo/config.toml << 'EOF'
[patch.crates-io]
rns-lang = { path = "../rns-lang" }
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
EOF

# rns-lsp
mkdir -p rns-lsp/.cargo
cat > rns-lsp/.cargo/config.toml << 'EOF'
[patch.crates-io]
rns-lang = { path = "../rns-lang" }
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
EOF

# lagertha-vm
mkdir -p lagertha-vm/.cargo
cat > lagertha-vm/.cargo/config.toml << 'EOF'
[patch.crates-io]
lvm-class = { path = "../lvm-class" }
lvm-common = { path = "../lvm-common" }
EOF

# Install pre-commit hook in binary crates
for repo in rnsc rns-lsp lagertha-vm; do
    cp docs/pre-commit-hook.sh "$repo/.git/hooks/pre-commit"
    chmod +x "$repo/.git/hooks/pre-commit"
done

echo "Done. All patch configs and hooks installed."
```
