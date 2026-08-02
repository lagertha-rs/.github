---
name: prepare-issue-tdd
description: Creates failing Lagertha integration tests or Runestaff language/tooling tests from an active GitHub Issue. Use when asked to start an Issue with TDD, generate integration tests for an Issue, write a failing JVM or RNS test, or prepare red-phase evidence.
---

# Prepare Issue TDD

Translate an active Issue owned by `lagertha-rs/lagertha` or
`lagertha-rs/runestaff` into the smallest sufficient fixture set that fails for
the intended behavioral reason. Derive coverage from the relevant specification
or tool contract rather than stopping after the first failing example. Stop at
the red phase so the maintainer can implement production code.

## Repository Routing

Resolve the Issue's owning repository before reading or changing files. Never
infer the target from the current working directory; this workspace contains
both repositories.

1. Parse the repository and Issue number from the supplied URL, or query the
   explicit `owner/repo` with `gh issue view`.
2. Support only `lagertha-rs/lagertha` and `lagertha-rs/runestaff`. If the Issue
   belongs elsewhere, stop and report that this skill does not support it.
3. Set the target repository to the repository that owns the active Issue.
   Linked Issues identify dependencies, not an automatic second test target.
4. Read the target repository's `AGENTS.md` and relevant local guides before
   designing fixtures. For cross-repository work, read the sibling repository's
   `AGENTS.md` and the linked Issue or latest handoff when it defines required
   class-file behavior.

| Issue owner | Red-test target | Test contract |
|---|---|---|
| `lagertha-rs/lagertha` | `lagertha/vm/tests/testdata` | Java 25 behavior, exact bytecode, VM result, and Lagertha feature tracking |
| `lagertha-rs/runestaff` | `runestaff/rns-lang/test_data/unit/lexer` or `runestaff/rnsc/test_data` | RNS syntax, diagnostics, class-file output, disassembly, CLI behavior, and Runestaff snapshots |

When a Runestaff Issue supports a Lagertha Issue, use the Lagertha Issue and
handoff to derive required class-file shape, but create tests in Runestaff only
unless the active acceptance criteria explicitly require coordinated changes in
both repositories. Do not add Lagertha feature metadata to Runestaff fixtures.

## Authority

- Read `.github/docs/project-management.md` from the workspace root first.
- Read the target repository's `AGENTS.md` and relevant test/build guides before
  changing tests. For Lagertha, this means `lagertha/docs/TESTING.md`,
  `lagertha/docs/FEATURE_TRACKING.md`, and `lagertha/docs/SPECIFICATIONS.md`.
  For Runestaff, `runestaff/AGENTS.md` defines fixture placement, diagnostics,
  snapshot, and validation conventions; read `runestaff/README.md` when its
  feature contract is relevant.
- Read the active Issue, its parent Outcome, latest handoff, dependencies,
  linked pull requests, Project fields, and affected feature definitions when
  the target repository has them.
- Use the Issue's repository in every `gh issue` command. Check Project status
  separately from the GitHub Issue state.
- The maintainer owns implementation decisions and production code. Create or
  edit integration fixtures, test support, required Lagertha feature metadata,
  and test documentation only.
- Do not implement production behavior, weaken assertions, accept snapshots,
  mark feature work complete, or close Issues.
- Keep existing user changes. If they conflict with the test, stop and ask.

## Preconditions

1. Confirm one actionable Issue is `In progress` and the requested test belongs
   to its acceptance criteria. If it is `Ready`, do not silently start it.
2. For a Lagertha Issue, identify one existing primary feature ID for each
   fixture. Read the Capability Index first, then only relevant feature details
   and YAML.
3. If a Lagertha fixture has no suitable feature ID, propose the smallest
   durable capability entry and ask before adding it. Do not invent IDs silently.
4. For a Runestaff Issue, do not require or invent a Lagertha feature ID;
   Runestaff currently has no corresponding feature registry.
5. Identify named dependencies or decisions that prevent a meaningful failing
   test. Report a blocker instead of creating speculative fixtures.

## Derive Test Behavior

1. Map Issue acceptance criteria to observable behavior in the target
   repository.
2. For Lagertha behavior, verify requirements against direct Java SE 25 HTML
   sections through Lagertha's ignored local specification cache. Use the JVMS
   first; use the JLS for source-language or launcher behavior. Verify persisted
   links.
3. For Runestaff behavior, verify the RNS syntax, diagnostic, class-file, and
   disassembler contract against `runestaff/AGENTS.md`, existing fixtures, and
   the linked JVMS requirement when applicable.
4. Distinguish specification requirements from `javac`, `rnsc`, `javap`, the
   reference JDK, or HotSpot behavior. Use `javap` when exact class-file output
   matters; use `javap -c -p` when emitted instructions matter.
5. Translate each relevant algorithm or contract into a bounded case matrix.
   For JVM behavior check applicable dimensions: direct versus inherited
   declarations, precedence and recursive lookup, receiver versus symbolic
   owner, access and flags, abstract/default/static/private forms, ambiguity,
   boundaries, and specified linkage or run-time errors. For Runestaff syntax
   or writer behavior also check top-level versus nested context, repeatability
   and declaration order, valid versus invalid placement, missing/trailing or
   invalid operands, duplicate declarations, explicit type-hint overrides, and
   assemble/disassemble round trips.
6. Classify every matrix row as Java-source legal, exact-classfile only,
   RNS-source legal, implementation-defined, out of scope, or deferred. Verify
   surprising cases rather than inferring them from source-language intuition.
7. Design the smallest fixture set that covers every distinct in-scope branch.
   Group closely related assertions only when all execute independently; split
   fixtures when an earlier failure masks another branch or expected outcomes
   differ. One red fixture is insufficient when the contract has other
   materially different branches.
8. State every untested row and its reason. Do not silently omit source-illegal,
   exact-classfile, or tooling-blocked cases.
9. For Lagertha, reconcile confirmed missing behavior with affected feature
   YAML. If a required behavior is absent, change `implemented` to `partial`
   and add a precise limitation; do not wait for production implementation.
   Do not apply Lagertha feature-tracking rules to Runestaff.

## Choose Fixture Form

- For a Lagertha Issue, use Java for normal source-level behavior emitted by
  Java 25 `javac`; use RNS for exact bytecode, malformed class files, verifier
  behavior, or input `javac` cannot emit. Place fixtures by capability under
  `lagertha/vm/tests/testdata`. Follow `TESTING.md` for discovery and
  `FEATURE_TRACKING.md` for metadata, identity, category, and one-feature
  ownership. Use `success` or `error` for intended final behavior on both VMs;
  never use `error` as an expected-failure marker for missing Lagertha behavior.
- For a Runestaff Issue, place lexer fixtures under
  `runestaff/rns-lang/test_data/unit/lexer`, parser/assembler/disassembler
  fixtures under `runestaff/rnsc/test_data/rns_integration`, and CLI fixtures
  under `runestaff/rnsc/test_data/cli_integration`. Follow
  `runestaff/AGENTS.md`: syntax errors belong under `error/parser`,
  warning-only cases under `rns_warn`, and silent successful assembly under
  `general`. Use its two-line RNS header convention, not Lagertha's three
  metadata comments.
- Do not implement Runestaff production changes in this workflow. Inspect the
  generated class, disassembly, diagnostics, or CLI result to prove the red
  behavior.

## Create The Red Test

1. Add the minimum fixture and helper sources needed for the observable result.
2. Apply target-specific entry conventions. Lagertha `*Test.java` and `*Test.rns`
   entries need the exact three metadata comments first; Runestaff `.rns` files
   need the header required by `runestaff/AGENTS.md`, and no feature metadata.
   Helpers must not end in `Test` or carry entry metadata where the target
   harness uses entry metadata.
3. Encode expected semantics in program assertions, exit behavior, diagnostics,
   parsed declarations, class-file inspection, or disassembly whenever possible.
   A new or changed snapshot alone is not sufficient red evidence.
4. Compile and inspect generated bytecode when the Issue depends on instruction
   choice, symbolic owner, descriptor, flags, interfaces, constant-pool shape,
   or another class-file detail.
5. Run the focused test for the target repository:

   ```bash
    cargo test -p vm --test integration_test <fixture-name-substring>
    ```

   For Runestaff use the applicable command:

   ```bash
   cargo test -p rnsc --test rns_test -- <fixture-name-substring>
   cargo test -p rnsc --test cli_test -- <fixture-name-substring>
   cargo test -p rns-lang <test-name-substring>
   ```

6. Confirm failure comes from the missing target behavior, not compilation,
   metadata, fixture discovery, unrelated startup behavior, or stale snapshots.
   For Runestaff snapshot tests, a missing or changed snapshot is only harness
   evidence; compare generated output against the intended contract and add a
   direct assertion or inspection step when the snapshot mismatch alone would
   not identify the missing behavior.
7. For Lagertha, run the compiled fixture manually on the Java 25 reference JDK
   when the harness stops after Lagertha's category assertion. Confirm the
   intended result with assertions enabled. For Runestaff, inspect generated
   `.class` files with `javap -v -p`, and verify disassembly or diagnostics
   directly when those are acceptance criteria.
8. If the target already satisfies the behavior, do not manufacture a red test.
   Report the unexpected evidence and identify whether the Issue or test scope
   needs revision.
9. Do not stop after the first red result. Complete validation for every fixture
   in the bounded matrix, including reference-JDK, bytecode, disassembly, and
   diagnostic evidence where applicable.

## Stop At Red

- Leave the focused test failing for the exact target-repository behavioral
  reason.
- Do not accept or hand-create a snapshot. Snapshot approval belongs after the
  implementation reaches intended behavior. This applies to Lagertha snapshots
  and Runestaff Insta snapshots.
- For Lagertha, do not run feature-tracking validation expecting success while
  the new fixture has no approved snapshot. Run it after snapshot acceptance in
  the green phase. For Runestaff, do not accept `.snap.new` files or update
  generated artifacts in the red phase.
- Do not update generated feature, coverage, or snapshot reports.
- Add a handoff comment to the active Issue before stopping:

  ```markdown
  ## Handoff

   Target repository: `lagertha-rs/<repo>`.
   Completed: Added failing fixture(s) and verified target behavior.
   Current behavior: Exact target failure and reference/tool output.
   Decision and reason: Fixture form, scope, feature ID or Runestaff contract, and important spec rule.
   Next exact step: First production behavior needed to make the fixture pass.
   Validation run: Commands, `javap`/disassembly evidence when relevant, and results.
   Blockers: Named blockers or none.
  ```

Keep the Issue `In progress`. Change Project state only when a named dependency
or maintainer decision blocks implementation. Do not mark a Runestaff Issue's
linked Lagertha feature complete; downstream feature state belongs to Lagertha.

## Output

Return:

```markdown
## Red Evidence

Target repository, fixture paths, asserted behavior, target failure, and
reference/tool output.

## Coverage

Case matrix, Issue criteria covered, primary feature IDs when the target is
Lagertha, and explicitly deferred, source-illegal, or tooling-blocked cases.

## Validation

Commands and results, including bytecode, disassembly, diagnostics, or reference
JDK inspection when relevant.

## Next Step

Smallest production behavior for the maintainer to implement.
```

Include the handoff URL when one was added. State any unverified requirement or
environment limitation directly.
