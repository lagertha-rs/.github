# lagertha-rs

A JVM implementation and the RNS programming language, written in Rust.

## Crates

| Crate | Description | crates.io |
|-------|-------------|-----------|
| [lvm-common](https://github.com/lagertha-rs/lvm-common) | Shared JVM types: descriptors, signatures, jtypes, error handling, utilities | [![crates.io](https://img.shields.io/crates/v/lvm-common.svg)](https://crates.io/crates/lvm-common) |
| [lvm-class](https://github.com/lagertha-rs/lvm-class) | JVM class file parser | [![crates.io](https://img.shields.io/crates/v/lvm-class.svg)](https://crates.io/crates/lvm-class) |
| [rns-lang](https://github.com/lagertha-rs/rns-lang) | RNS language compiler (lexer, parser, codegen) | [![crates.io](https://img.shields.io/crates/v/rns-lang.svg)](https://crates.io/crates/rns-lang) |
| [rnsc](https://github.com/lagertha-rs/rnsc) | RNS compiler CLI | [![crates.io](https://img.shields.io/crates/v/rnsc.svg)](https://crates.io/crates/rnsc) |
| [rns-lsp](https://github.com/lagertha-rs/rns-lsp) | RNS language server (LSP) | [![crates.io](https://img.shields.io/crates/v/rns-lsp.svg)](https://crates.io/crates/rns-lsp) |
| [lagertha-vm](https://github.com/lagertha-rs/lagertha-vm) | The JVM implementation | - |

## Dependency graph

```
lvm-common          (no deps)
lvm-class         → lvm-common
rns-lang          → lvm-class → lvm-common
rnsc              → rns-lang, lvm-class
rns-lsp           → rns-lang
lagertha-vm       → lvm-common, lvm-class
```

## License

All crates are dual-licensed under [MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE).
