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

These repos depend on sibling crates through `git = "https://github.com/lagertha-rs/..."`.

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

The local git-source overrides cause `Cargo.lock` to diverge from the committed remote-source version. Repos that track `Cargo.lock` in git will pick up that local noise unless the hook cleans it up.

Use the shared pre-commit hook from `.github/docs/pre-commit-hook.sh` in every local repo.

What it does:

- runs `cargo fmt --all` when staged changes include Rust sources or `Cargo.toml`
- stops the commit if formatting changed files, so you can review and stage the result
- cleans `Cargo.lock` noise caused by the workspace-local override config
- use `git commit --no-verify` to bypass it

### Installation

Copy the shared script into `.git/hooks/pre-commit` and make it executable:

```sh
cp .github/docs/pre-commit-hook.sh <repo>/.git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Quick setup script

Run this from the workspace root to set up the shared config and install the hook in all local repos:

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

# Install shared pre-commit hook in every local repo
for repo in lvm-common lvm-class rns-lang rnsc rns-lsp lagertha-vm; do
    cp .github/docs/pre-commit-hook.sh "$repo/.git/hooks/pre-commit"
    chmod +x "$repo/.git/hooks/pre-commit"
done

echo "Done. Workspace cargo override and hooks installed."
```
