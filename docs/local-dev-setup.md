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

## Workspace-local cargo overrides

These repos depend on sibling crates through `git = "https://github.com/lagertha-rs/..."`, not `crates.io`.
That means `[patch.crates-io]` does nothing here.

Use a single workspace-local `.cargo/config.toml` at the shared workspace root instead:

```toml
[patch."https://github.com/lagertha-rs/rns-lang"]
rns-lang = { path = "rns-lang" }

[patch."https://github.com/lagertha-rs/lvm-class"]
lvm-class = { path = "lvm-class" }

[patch."https://github.com/lagertha-rs/lvm-common"]
lvm-common = { path = "lvm-common" }
```

From the example layout above, create this file at:

```text
lvm-workspace/.cargo/config.toml
```

Why root-level:

- stays local to one machine
- keeps all `Cargo.toml` files clean
- applies to every repo when you run Cargo inside the workspace tree

How it works:

- `rnsc` and `rns-lsp` use local `rns-lang`
- `rns-lang` uses local `lvm-class`
- `lvm-class` and `lagertha-vm` use local `lvm-common`

## Pre-commit hook for Cargo.lock

The local git-source overrides cause `Cargo.lock` to diverge from the committed remote-source version. Binary crates (`rnsc`, `rns-lsp`, `lagertha-vm`) track `Cargo.lock` in git, so this creates unwanted noise.

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
# Smart Cargo.lock handling for repos with local git-source overrides.
#
# When Cargo.lock is staged, this hook:
#   1. Moves workspace .cargo/config.toml aside (disabling local overrides)
#   2. Regenerates Cargo.lock from the clean registry sources
#   3. If the clean lockfile differs from HEAD, stages the real changes
#   4. If it matches HEAD, unstages it (it was just patch noise)
#   5. Restores .cargo/config.toml
#
# Use `git commit --no-verify` to bypass entirely.

WORKSPACE_CARGO_CONFIG="../.cargo/config.toml"
WORKSPACE_CARGO_CONFIG_BAK="../.cargo/config.toml.hook-bak"

# Only act if Cargo.lock is staged
git diff --cached --name-only | grep -q '^Cargo\.lock$' || exit 0

# If there's no workspace override config, nothing special to do
[ -f "$WORKSPACE_CARGO_CONFIG" ] || exit 0

# Ensure we always restore the config, even on failure
trap 'if [ -f "$WORKSPACE_CARGO_CONFIG_BAK" ]; then mv "$WORKSPACE_CARGO_CONFIG_BAK" "$WORKSPACE_CARGO_CONFIG"; fi' EXIT

# Move config aside to disable local overrides
mv "$WORKSPACE_CARGO_CONFIG" "$WORKSPACE_CARGO_CONFIG_BAK"

# Regenerate a clean lockfile from registry sources
cargo generate-lockfile --quiet 2>/dev/null

# Check if the clean lockfile differs from what's in HEAD
if git diff --quiet HEAD -- Cargo.lock; then
    # No real changes — this was purely patch noise
    echo "[pre-commit] Cargo.lock changes are local-override noise, unstaging."
    git restore --staged Cargo.lock
else
    # Real dependency changes — stage the clean version
    echo "[pre-commit] Cargo.lock has real changes, staging clean version."
    git add Cargo.lock
fi

# Restore local override config (handled by trap)
```

## Quick setup script

Run this from the workspace root to set up the shared config and hooks at once:

```sh
#!/bin/sh
# Run from the workspace root (parent of all repo dirs)

# Shared workspace Cargo override
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[patch."https://github.com/lagertha-rs/rns-lang"]
rns-lang = { path = "rns-lang" }

[patch."https://github.com/lagertha-rs/lvm-class"]
lvm-class = { path = "lvm-class" }

[patch."https://github.com/lagertha-rs/lvm-common"]
lvm-common = { path = "lvm-common" }
EOF

# Install pre-commit hook in binary crates
for repo in rnsc rns-lsp lagertha-vm; do
    cp docs/pre-commit-hook.sh "$repo/.git/hooks/pre-commit"
    chmod +x "$repo/.git/hooks/pre-commit"
done

echo "Done. Workspace cargo override and hooks installed."
```
