---
name: select-roadmap-next
description: Researches and recommends what Lagertha roadmap outcome should come next. Use when asked "what next", "choose next roadmap work", "prioritize the roadmap", or to plan Now and Next outcomes.
---

# Select Roadmap Next

Choose the smallest meaningful runnable Java capability that should advance the
Lagertha roadmap. Feature gaps and Java 25 specification coverage are evidence,
not automatic priority.

## Authority

- Read `.github/docs/project-management.md` from the workspace root first.
- Read every affected repository's `AGENTS.md` and relevant documentation.
- The maintainer owns priority and implementation decisions.
- Recommend one candidate, but do not create or update Issues, Project items,
  fields, or horizons until the maintainer explicitly confirms the choice.
- Do not implement production code.

## Discovery

1. Inspect organization Project state with `gh`, including `Current`, `Now`,
   `Next`, blocked work, and manual ordering.
2. Inspect open Issues, the active Issue's latest handoff, linked pull requests,
   and relevant CI failures.
3. Read only the `Capability Index` in `lagertha/docs/features/README.md` as the
   required minimal capability state. Use it to identify candidate areas and
   feature IDs.
4. For shortlisted candidates only, read their capability details when scope,
   limitations, or known gaps are needed.
5. Read only relevant sections of `lagertha/docs/features/TEST_COVERAGE.md` when
   existing integration evidence affects candidate research or validation
   planning. Test counts do not determine priority.
6. Inspect relevant files under `lagertha/features/`, integration fixtures, and
   implementation only when needed to resolve a decisive claim.
7. Inspect Runestaff when a candidate needs exact class-file generation or a
   cross-repository change.
8. Confirm behavioral requirements against direct sections in the official Java
   SE 25 HTML specifications. Use Lagertha's ignored local specification cache
   to search, read, and verify relevant pages and fragments. Refresh it only when
   missing or current upstream content must be reconfirmed. Do not load or
   convert the complete specification. Distinguish specification requirements
   from reference-JDK or HotSpot behavior.
9. Treat generated reports as release evidence that may lag local code. Verify
   decisive claims against current feature definitions and tests.
10. For each shortlisted Java behavior, derive a bounded JVMS/JLS case matrix
    far enough to expose materially distinct precedence, inheritance, access or
    flag, ambiguity, and specified-error branches. Use this to estimate scope
    and child work; do not estimate from one failing example.
11. If research conclusively demonstrates a required limitation in a feature
    marked `implemented`, update its YAML to `partial` with a precise limitation.
    This reconciles capability truth and does not select or prioritize the work.
    Do not update generated reports during candidate research.

If the organization Project or required Issue tracking is not configured,
report that setup gap. Continue candidate research when possible, but do not
pretend roadmap state exists.

## Candidate Set

Build three to five candidates from multiple sources:

- Representative Java programs or launcher scenarios that currently fail.
- Tracked partial limitations that block richer runnable behavior.
- Important untracked Java 25 capabilities required by those scenarios.
- Shared dependencies that unblock several capabilities.
- Correctness bugs that contradict claimed behavior.
- Runestaff capabilities required for exact integration evidence.

Each candidate must state:

- Observable runnable result.
- Minimal failing program or exact scenario.
- Compatibility value now.
- Relevant existing feature IDs.
- Important untracked gaps.
- Dependencies and blockers.
- Likely immediate child Issues with `S` or `M` size.
- Integration validation against the reference JDK.
- Important case-matrix branches, including exact-classfile-only or deferred
  cases that affect scope.
- Main uncertainties and decisions needed.

Reject candidates that are only component cleanup, TODO completion, report-count
improvement, or broad goals without testable exit criteria. Do not inventory the
whole JVM and do not create Issues or feature entries for every discovered gap.

## Comparison

Apply these rules in order; do not use a weighted score:

1. Enables a richer representative Java program.
2. Removes a dependency shared by several useful capabilities.
3. Delivers end-to-end semantics rather than isolated component completeness.
4. Produces clear integration evidence and reduces important uncertainty.
5. Forms a bounded, coherent Outcome with understandable immediate work.
6. Has resolved or manageable prerequisites.

Use maintainer interest and learning value as tie-breakers. Explicit maintainer
direction always overrides the recommendation.

## Output

Return this compact decision memo:

```markdown
## Current State

Active outcome, blockers, relevant recent evidence, and setup gaps.

## Candidates

| Candidate outcome | Runnable probe | Unlock | Gaps and dependencies | Size | Main risk |
|---|---|---|---|---|---|

## Recommendation

Recommended candidate and direct reasoning under the ordered comparison rules.

## Alternatives

Why each other candidate should wait or what evidence could move it first.

## Proposed Outcome

Draft Why, User-visible result, Scope, Exit criteria, Non-goals, Child work,
Decisions, Project fields, and affected feature IDs.

## Confirmation

Ask the maintainer to select the recommendation, select an alternative, or
revise constraints.
```

Use links or repository paths for decisive evidence. State unknowns rather than
guessing. Keep candidate research transient; do not write a Markdown roadmap.

## After Confirmation

1. Recheck Project and Issue state for concurrent changes.
2. Create or update the selected Outcome in `lagertha-rs/lagertha`.
3. Set its confirmed Horizon and other Project fields.
4. Create only immediate actionable child Issues, in the repository where each
   change belongs.
5. Link feature IDs, dependencies, Runestaff work, and the first failing
   integration scenario.
6. Put the bounded specification case matrix or its required branches into the
   selected Issue's acceptance and validation scope. Do not reduce it to the
   first failing scenario.
7. Keep at most one primary Issue `In progress`.
8. Offer to run `prepare-issue-tdd` for the selected `In progress` Issue. Keep
   roadmap selection and failing-test creation as separate workflows.
9. Report all created or changed GitHub URLs and fields.
