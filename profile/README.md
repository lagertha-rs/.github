# lagertha-rs

A hobby project written in Rust that I work on after hours and on weekends. Everything here is at an early stage and can do very little, but the ultimate goal is to build something that can honestly be called a JVM.

## Repositories

### [Lagertha](https://github.com/lagertha-rs/lagertha)

The main monorepo containing the VM and supporting libraries. Named after my cat. Targets the latest Java version with ambitions to eventually support most features: garbage collection, JDWP debugging, threads, and more.

**Crates inside:**
- `lvm-common` — Shared JVM types: descriptors, signatures, jtypes, error handling, utilities
- `lvm-class` — JVM class file parser and writer
- `vm` — The VM itself
- `javap` — Class file disassembler (like `javap` but in Rust)
- `runtime` — Runtime structures (deprecated, being replaced)
- `jimage` — JImage file parser

### [Runestaff](https://github.com/lagertha-rs/runestaff)

RNS (Rune Assembly) — a Java assembly language toolchain. The name comes from Old English — a runestaff is a letter written in runes, which fits the Viking theme and the idea of Java assembly: runes as small building blocks (instructions) forming letters (classes).

**Crates inside:**
- `rns-lang` — RNS compiler library (lexer, parser, assembler, disassembler)
- `rnsc` — RNS compiler CLI
- `rns-lsp` — RNS language server (LSP, POC only)

RNS is used to assemble and disassemble Java class files. The assembler produces arbitrary Java bytecode, which is mainly useful for testing and getting more comfortable with the class file format.

## Published Crates

| Crate | Description | crates.io |
|-------|-------------|-----------|
| [lvm-common](https://github.com/lagertha-rs/lagertha/tree/main/lvm-common) | Shared JVM types: descriptors, signatures, jtypes, error handling, utilities | [![crates.io](https://img.shields.io/crates/v/lvm-common.svg)](https://crates.io/crates/lvm-common) |
| [lvm-class](https://github.com/lagertha-rs/lagertha/tree/main/lvm-class) | JVM class file parser and writer | [![crates.io](https://img.shields.io/crates/v/lvm-class.svg)](https://crates.io/crates/lvm-class) |
| [rns-lang](https://github.com/lagertha-rs/runestaff/tree/main/rns-lang) | RNS compiler library (lexer, parser, codegen) | [![crates.io](https://img.shields.io/crates/v/rns-lang.svg)](https://crates.io/crates/rns-lang) |
| [rnsc](https://github.com/lagertha-rs/runestaff/tree/main/rnsc) | RNS compiler CLI | [![crates.io](https://img.shields.io/crates/v/rnsc.svg)](https://crates.io/crates/rnsc) |
| [rns-lsp](https://github.com/lagertha-rs/runestaff/tree/main/rns-lsp) | RNS language server (LSP) | [![crates.io](https://img.shields.io/crates/v/rns-lsp.svg)](https://crates.io/crates/rns-lsp) |

## Dependency graph

```
lagertha/
  lvm-common          (no deps)
  lvm-class         → lvm-common
  vm                → lvm-common, lvm-class
  javap             → lvm-class

runestaff/
  rns-lang          → lvm-class
  rnsc              → rns-lang
  rns-lsp           → rns-lang
```

## License

All crates are dual-licensed under [MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE).
