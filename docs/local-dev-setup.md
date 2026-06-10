# Local Development Setup

This guide explains how to set up cross-repo local development so changes in one crate are immediately reflected in dependent crates without publishing to crates.io.

## Prerequisites

Clone both repos into a shared workspace directory:

```sh
mkdir lagertha-workspace && cd lagertha-workspace
gh repo clone lagertha-rs/lagertha
gh repo clone lagertha-rs/runestaff
```

## Workspace-local cargo overrides

The runestaff repo depends on lvm-class and lvm-common from the lagertha repo through crates.io.

Use a single workspace-local `.cargo/config.toml` at the shared workspace root to override with local paths:

```toml
[patch.crates-io]
lvm-common = { path = "lagertha/lvm-common" }
lvm-class = { path = "lagertha/lvm-class" }
```

From the example layout above, create this file at:

```text
lagertha-workspace/.cargo/config.toml
```

Why root-level:

- stays local to one machine
- keeps all `Cargo.toml` files clean
- applies to every repo when you run Cargo inside the workspace tree

How it works:

- `runestaff/rns-lang` uses local `lagertha/lvm-class`
- `lagertha/lvm-class` uses local `lagertha/lvm-common`

## Pre-commit hook

Both repos enforce `cargo fmt` and `cargo clippy` via pre-commit hooks.

### Installation

The hook script is in `.github/docs/pre-commit-hook.sh`. Install it in each repo:

```sh
cp .github/docs/pre-commit-hook.sh lagertha/.git/hooks/pre-commit
cp .github/docs/pre-commit-hook.sh runestaff/.git/hooks/pre-commit
chmod +x lagertha/.git/hooks/pre-commit
chmod +x runestaff/.git/hooks/pre-commit
```

What it does:

- runs `cargo fmt --all` when staged changes include Rust sources or `Cargo.toml`
- runs `cargo clippy --workspace --all-targets --all-features -- -D warnings`
- stops the commit if any check fails
- use `git commit --no-verify` to bypass it

## Quick setup script

Run this from the workspace root to set up the shared config and install the hook in both repos:

```sh
#!/bin/sh
# Run from the workspace root (parent of lagertha and runestaff)

# Shared workspace Cargo override
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[patch.crates-io]
lvm-common = { path = "lagertha/lvm-common" }
lvm-class = { path = "lagertha/lvm-class" }
EOF

# Install shared pre-commit hook in both repos
for repo in lagertha runestaff; do
    cp .github/docs/pre-commit-hook.sh "$repo/.git/hooks/pre-commit"
    chmod +x "$repo/.git/hooks/pre-commit"
done

echo "Done. Workspace cargo override and hooks installed."
```
