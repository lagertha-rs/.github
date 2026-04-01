# lagertha-rs

A hobby project written in Rust that I work on after hours and on weekends. Everything here is at an early stage and can do very little, but the ultimate goal is to build something that can honestly be called a JVM.

## Lagertha VM

Named after my cat. Targets the latest Java version with ambitions to eventually support most features: garbage collection, JDWP debugging, threads, and more. It's very much a work in progress. For current status, see the [lagertha-vm](https://github.com/lagertha-rs/lagertha-vm) repo.

## Runestaff (RNS)

A Java assembly language. The name comes from Old English — a runestaff is a letter written in runes, which fits the Viking theme and the idea of Java assembly: runes as small building blocks (instructions) forming letters (classes).

RNS is used to assemble and disassemble Java class files. The assembler produces arbitrary Java bytecode, which is mainly useful for testing and getting more comfortable with the class file format. The disassembler exists because it was straightforward to build and I don't like `javap`.

## Crates

Published to crates.io primarily to make multi-repo development easier and to reserve the names.

| Crate | Description | crates.io |
|-------|-------------|-----------|
| [lvm-common](https://github.com/lagertha-rs/lvm-common) | Shared JVM types: descriptors, signatures, jtypes, error handling, utilities | [![crates.io](https://img.shields.io/crates/v/lvm-common.svg)](https://crates.io/crates/lvm-common) |
| [lvm-class](https://github.com/lagertha-rs/lvm-class) | JVM class file parser | [![crates.io](https://img.shields.io/crates/v/lvm-class.svg)](https://crates.io/crates/lvm-class) |
| [rns-lang](https://github.com/lagertha-rs/rns-lang) | RNS compiler library (lexer, parser, codegen) | [![crates.io](https://img.shields.io/crates/v/rns-lang.svg)](https://crates.io/crates/rns-lang) |
| [rnsc](https://github.com/lagertha-rs/rnsc) | RNS compiler CLI | [![crates.io](https://img.shields.io/crates/v/rnsc.svg)](https://crates.io/crates/rnsc) |
| [rns-lsp](https://github.com/lagertha-rs/rns-lsp) | RNS language server (LSP) | [![crates.io](https://img.shields.io/crates/v/rns-lsp.svg)](https://crates.io/crates/rns-lsp) |
| [lagertha-vm](https://github.com/lagertha-rs/lagertha-vm) | The VM itself | - |

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
