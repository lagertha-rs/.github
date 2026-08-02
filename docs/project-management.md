# Project Management

This guide defines how the Lagertha organization tracks roadmap outcomes,
actionable work, implementation status, test coverage, decisions, and session
state. The process is optimized for one maintainer working irregularly with LLM
support. The maintainer writes production code and owns implementation
decisions. LLMs help with research, test planning and maintenance,
documentation, code review, and roadmap management. They do not own or
autonomously implement product code.

## Sources of Truth

Each kind of information has one owner. Issues are written for the human
maintainer who will implement them. They must explain intent and constraints as
normal engineering tasks, not as prompts for an autonomous coding agent.

| Information | Source of truth |
|---|---|
| Implemented capability | Repository feature registry |
| Integration test evidence | Snapshot metadata and generated coverage report |
| Roadmap outcomes | Outcome Issues in the organization Project |
| Actionable work | GitHub Issues |
| Priority and workflow state | Organization Project |
| Durable architecture decisions | Repository ADRs |
| Incomplete session state | Latest handoff comment on the active Issue |
| Released capability | Generated release reports |
| Current code health | CI |

Do not maintain the same state in multiple places. In particular, Markdown
roadmaps must not duplicate Project priority, and Issues must not duplicate the
complete feature inventory.

Lagertha's feature and integration test tracking design is documented in
`lagertha/docs/FEATURE_TRACKING.md` in the local workspace and at
<https://github.com/lagertha-rs/lagertha/blob/main/docs/FEATURE_TRACKING.md>.

## Organization Project

Use one public organization Project named `Lagertha Roadmap` for both:

- `lagertha-rs/lagertha`
- `lagertha-rs/runestaff`

The Project answers:

- What is being worked on now?
- What can start next?
- What is blocked?
- Which roadmap outcome does an Issue support?

Technical implementation truth remains in repository feature files and tests.

### Fields

| Field | Values |
|---|---|
| Status | Inbox, Ready, In progress, Blocked, Done |
| Horizon | Now, Next, Later |
| Work Type | Outcome, Feature, Bug, Test, Debt, Docs, Decision |
| Area | Execution, Class files, Loading, Runtime/JDK, Memory, Concurrency, Debugging, Runestaff, Tooling |
| Size | S, M |

Field meanings:

- `Horizon` provides priority without artificial deadlines.
- `S` means one focused session or pull request.
- `M` means several sessions but one coherent Issue.
- Work larger than `M` must be an Outcome with child Issues.
- Manual ordering within a Horizon resolves ties.

Do not add percentage-complete, due-date, or duplicate priority fields.

GitHub reserves `Type` for organization Issue Types. Use the custom
`Work Type` Project field unless the organization deliberately adopts and
configures Issue Types with the same values. Creating or changing organization
Issue Types requires `admin:org`; normal Project administration does not.

### Views

| View | Contents |
|---|---|
| Current | In progress and Blocked |
| Roadmap | Outcome items grouped by Horizon |
| Now | Horizon Now, excluding Done |
| Ready | Status Ready |
| Inbox | Status Inbox |
| By Area | Open items grouped by Area |
| Runestaff | Items from the Runestaff repository |
| LLM Support | Ready items carrying `llm-support` |
| Recently Done | Done items sorted by update time |

Use `Current` as the default view. Keep at most one primary Issue In progress.

## Work Hierarchy

Use two levels: roadmap Outcomes and actionable Issues.

```text
Outcome Issue
├── Actionable Lagertha Issue
├── Actionable Lagertha Issue
└── Supporting Runestaff Issue
```

Cross-repository Outcomes live in `lagertha-rs/lagertha` because runnable Java
programs on Lagertha are the main product goal. Supporting Runestaff work lives
in `lagertha-rs/runestaff` and links to the Lagertha Outcome.

Use GitHub sub-issues when available across repositories. Otherwise record the
relationship in both Issue bodies.

## Outcome Issues

An Outcome describes observable capability, not a code component.

Good Outcomes:

- Run Java programs using reference casts correctly.
- Load applications from JAR files.
- Execute Java 25 string concatenation.
- Remove accidental VM panics from supported bytecode.

Bad Outcomes:

- Improve runtime.
- Implement JVM.
- Opcode work.
- Fix TODOs.

Use this body:

```markdown
## Why

## User-visible result

## Scope

## Exit criteria

## Non-goals

## Child work

## Decisions
```

Assign every open Outcome a Horizon:

- `Now`: one or two active outcomes.
- `Next`: three to five likely outcomes.
- `Later`: broad future outcomes without scheduling promises.

## Choosing What Comes Next

Choose roadmap work by the runnable Java capability it enables. Specification
coverage and generated feature reports provide evidence about gaps; they do not
define priority by themselves. This avoids optimizing only for already tracked
features or completing isolated JVM components that do not advance an
end-to-end behavior.

The maintainer owns the final choice. An assisting LLM may research candidates,
compare them, and recommend one, but must not change Project priority before the
maintainer confirms the selection.

### Candidate Outcomes

Start with three to five candidate Outcomes. Each candidate must:

- Describe an observable capability of a runnable Java program or the launcher.
- Include a small program or concrete scenario that does not work yet.
- Advance the Java 25 compatibility target.
- Have testable exit criteria.
- Be coherent enough to decompose into `S` or `M` child Issues.

Candidate sources include:

- A representative Java program that fails on Lagertha.
- A limitation in the generated feature report that blocks richer programs.
- An untracked Java 25 capability required by a selected program.
- A dependency that blocks several useful capabilities.
- A correctness bug that breaks already claimed behavior.
- Runestaff work required to create exact Lagertha test evidence.

Do not derive the candidate list only from partial or missing registry entries.
The registry records declared scope, not the complete Java 25 feature universe.
Do not create registry entries or Issues for every discovered gap during
candidate research.

### Candidate Research

For each candidate, perform a bounded discovery pass and record:

| Question | Required evidence |
|---|---|
| What becomes runnable? | Failing program or exact observable scenario |
| Why is it useful now? | Compatibility unlocked or current blocker removed |
| What is missing? | Relevant feature IDs plus important untracked gaps |
| What does it depend on? | Lagertha, Runestaff, decision, or external dependencies |
| How large is it? | Likely child Issues and `S` or `M` estimates |
| How will it be proven? | Proposed integration behavior and reference-JDK comparison |
| What is uncertain? | Specification, architecture, or implementation risks |

Inspect current Project state, open Issues and handoffs, generated reports,
feature definitions, integration tests, relevant code, Java 25 specifications,
and sibling repositories where needed. Generated release reports may lag local
code, so confirm important claims against current feature definitions and tests.
Use the official Java SE 25 HTML specifications as the primary source through
Lagertha's ignored local specification cache. Search and read only the sections
needed for the candidate, and use canonical direct section links for persisted
references. Verify each page and fragment against the cached original HTML, as
required by the affected repository's instructions. Refresh the cache only when
it is missing or current upstream content must be reconfirmed. A local PDF may
support fallback search, but do not convert the complete specification into
project documentation.
The required generated report inputs are:

- The `Capability Index` in `lagertha/docs/features/README.md` for the minimal
  capability state and candidate feature IDs.
- Relevant sections of `lagertha/docs/features/TEST_COVERAGE.md` only when
  existing integration evidence affects research or validation planning.

Read capability details, feature YAML, tests, and implementation only for
shortlisted candidates or when needed to resolve an important claim. Use the
coverage report to plan validation, not to rank work by test count.

### Comparison Rules

Compare candidates in this order:

1. Prefer work that enables a richer representative Java program.
2. Prefer work that removes a dependency shared by several useful capabilities.
3. Prefer end-to-end semantic behavior over isolated component completeness.
4. Prefer work that produces clear integration evidence and reduces important
   technical uncertainty.
5. Prefer a bounded, coherent Outcome whose immediate work can be understood.
6. Prefer dependency-ready work over work with unresolved prerequisites.

Do not calculate a weighted priority score. It creates false precision for a
small, irregularly maintained project. When candidates remain comparable, the
maintainer's interest and learning goal resolve the tie.

### Selection Loop

Use this loop whenever the current `Now` Outcome completes, becomes blocked, or
new evidence invalidates the current ordering:

1. Review current Project state and the latest handoff.
2. Research and compare three to five candidate Outcomes.
3. Present one recommendation, alternatives, evidence, and uncertainties.
4. Ask the maintainer to select or revise the recommendation.
5. Put the selected Outcome in `Now` and keep three to five likely Outcomes in
   `Next`.
6. Decompose only the selected `Now` Outcome into immediate actionable Issues.
7. Define its first failing integration scenario before implementation starts.

The candidate comparison is a temporary decision aid, not another roadmap
artifact. Persist only the selected Outcome, its immediate child Issues, Project
fields, relevant decisions, and eventual feature and test evidence in their
existing sources of truth.

## Actionable Issues

Create an Issue when work is sufficiently understood and likely to be selected.
Do not create Issues for every missing opcode, unimplemented feature, untested
criterion, TODO, or generated report gap. The feature registry records those
facts until they become actionable.

Use this body:

```markdown
## Why

## Desired behavior

## Acceptance criteria

## Non-goals

## Feature IDs

## Dependencies

## Validation
```

The `Feature IDs` section links temporary work to permanent capability state:

```markdown
## Feature IDs

- `opcodes.arithmetic.frem`
- `primitives.floats.remainder`
```

Do not add planning status or Issue links to every feature file. Issues point to
features, not the reverse.

An Issue is Ready only when the maintainer can understand its desired behavior,
scope, acceptance criteria, and validation without reconstructing intent from
commit history. Write for implementation by a human, while including enough
context for an LLM to assist with research, tests, review, and project updates.
For Java behavioral Issues, acceptance and validation must be informed by a
bounded JVMS/JLS case matrix. Identify materially distinct success, precedence,
inheritance, access or flag, ambiguity, and specified-error branches in scope.
Record source-illegal, exact-classfile, and intentionally deferred cases rather
than treating one representative example as complete coverage.

## Workflow

```text
Inbox -> Ready -> In progress -> Done
                       |
                       v
                    Blocked
```

| Status | Meaning |
|---|---|
| Inbox | Captured but not evaluated |
| Ready | Scoped and immediately actionable |
| In progress | Current active work |
| Blocked | Waiting on a named dependency or decision |
| Done | Acceptance criteria met and merged |

When work becomes blocked, identify the dependency in an Issue comment. Move it
back to Ready or In progress when the dependency clears.

### Working an Outcome

The Outcome defines the observable result; its actionable children define the
implementation sequence. Work dependency-ready child Issues before closing the
Outcome:

1. Keep the selected Outcome in `Now` and `Ready` while child work is underway.
2. Choose the first dependency-ready child, assign it if useful, and move only
   that child to `In progress`.
3. Implement against the child acceptance criteria. Link the pull request with
   `Closes #<child>` and list affected feature IDs; do not close the parent
   Outcome from a child pull request.
4. After the child merges and passes completion review, close it and start the
   next dependency-ready child.
5. When all required children are done, review the parent Outcome against its
   user-visible result and exit criteria before closing it.

Children need not follow numeric order. Follow explicit dependencies. Do not
start every child concurrently merely because all are in `Now`; keep at most one
primary Issue `In progress`.

## Completion Review

Review completed work against its Issue before closing it. Passing tests or a
merged pull request alone does not prove completion. The review must establish
that the requested observable behavior, accepted scope, permanent capability
state, and required evidence agree.

For an actionable Issue:

1. Read the Issue body, discussion, latest handoff, linked pull requests, and
   repository instructions.
2. Map every acceptance criterion to merged code, observable behavior, or other
   direct evidence. Mark criteria with no evidence as unmet.
3. Confirm relevant Java behavior against verified direct Java SE 25
   specification sections. Distinguish specification requirements from
   reference-JDK or HotSpot behavior.
4. Reconstruct the relevant specification case matrix independently and check
   that materially distinct in-scope branches have explicit evidence. A single
   passing fixture does not prove an algorithm with precedence or failure
   branches.
5. Inspect the complete merged diff for scope omissions, regressions, and
   accidental behavior changes. Record unrelated discoveries as follow-up work.
6. Run focused validation and the required checks for every affected repository.
   Confirm linked CI is current and successful. Review changed snapshots for
   semantics rather than accepting them because they changed.
7. Verify affected feature definitions, fixtures, snapshots, generated reports,
   documentation, and ADRs are updated where the repository process requires
   them. Do not edit generated artifacts by hand.
8. Report a `Ready to close` or `Blocked` verdict with evidence for every
   criterion, validation results, residual risks, and follow-up Issues.

An assisting LLM may perform the review and recommend closure, but must not
close the Issue, alter acceptance criteria, or move it to Done without explicit
maintainer confirmation. Never weaken criteria merely to match the delivered
implementation. If agreed scope changed, document that decision before closure.
For an Outcome, also verify all required child work and the stated user-visible
result; closed child Issues alone do not prove the Outcome.

## Session Handoffs

Before stopping incomplete work, add this comment to the active Issue:

```markdown
## Handoff

Completed:
Current behavior:
Decision and reason:
Next exact step:
Validation run:
Blockers:
```

Before the next work session, the maintainer or assisting LLM must read the
Issue body, latest handoff, linked pull requests, and repository instructions.
Do not use a global work log or rely only on local branches and commit messages
for session state.

## Ideas and Inbox

Capture raw ideas as Project draft items. Draft items may remain in Inbox or
Later while they are vague.

During triage:

1. Delete irrelevant ideas.
2. Keep unscheduled ideas as drafts.
3. Convert understood, likely work into an Issue.
4. Attach actionable work to an Outcome where applicable.

Draft items must be converted to Issues before entering Ready or In progress.

## Decisions

Record small, local decisions in the relevant Issue discussion. Record durable
decisions that constrain future work as ADRs in the affected repository:

```text
docs/decisions/
├── 0001-example-decision.md
└── 0002-another-decision.md
```

Use this ADR structure:

```markdown
# Decision

## Context

## Decision

## Consequences

## Alternatives
```

Use Project Work Type `Decision` while a decision remains unresolved. Close the
Issue after recording the result in its discussion or an ADR.

## Pull Requests

Every behavioral pull request should:

1. Link its actionable Issue using `Closes` when it completes the Issue.
2. List affected feature IDs.
3. State observable behavior changes.
4. State validation performed.
5. Update feature definitions, fixtures, and snapshots when applicable.
6. Create linked follow-up Issues for discovered out-of-scope work.

Do not silently broaden Issue scope. Do not close partially completed Issues
without updating their acceptance criteria and documenting the decision.

## Releases and Milestones

Use repository milestones only for concrete release scope, such as:

- Lagertha v0.6.0
- Runestaff v0.4.0

Milestones are not the long-term roadmap. An Outcome may span several releases.
The release workflow generates released feature and integration coverage reports.

## Labels

Keep organization-wide process labels minimal:

- `llm-support`
- `needs-decision`
- `needs-research`

Project fields already own Work Type, Status, Horizon, Area, and Size. Do not
duplicate those values as labels.

## Automation

Configure Project workflows to:

- Add new Lagertha and Runestaff Issues to Inbox.
- Move closed Issues to Done.
- Move reopened Issues to Ready.
- Leave new draft items in Inbox.

LLMs may:

- Classify Inbox items.
- Set Work Type, Area, Horizon, and Size.
- Move selected work to In progress.
- Add handoff comments.
- Mark explicit blockers.
- Draft follow-up Issues.
- Update feature tracking, test plans, documentation, and Project metadata.
- Help create and review integration tests under maintainer direction.

LLMs must not:

- Autonomously implement production code.
- Write Issues as coding-agent prompts instead of human engineering tasks.
- Generate an Issue for every missing or untested feature.
- Redefine roadmap priority without explicit user direction.
- Treat TODO comments as roadmap commitments.
- Accept changed snapshots without semantic review.
- Duplicate Project state in repository documents.

## Local Repository Discovery

The expected local layout is:

```text
lagertha-org-workspace/
├── .github/
├── lagertha/
└── runestaff/
```

For cross-repository work, inspect sibling repositories before deciding scope or
creating Issues. Typical dependency direction:

```text
runestaff/rns-lang -> lagertha/lvm-class -> lagertha/lvm-common
lagertha VM tests -> released rnsc
```

Read repository-local `AGENTS.md` files first. Run validation in every repository
changed by the work.

## Setup Checklist

GitHub operational notes:

- `gh repo edit lagertha-rs/lagertha --enable-issues` enables Issues when the
  repository was created without them.
- `gh project create` creates a private Project by default. Explicitly run
  `gh project edit <number> --owner lagertha-rs --visibility PUBLIC`.
- New Projects start with `Todo`, `In Progress`, and `Done`. Rename and extend
  the Status options to the workflow defined above before adding work.
- `gh project link` makes the Project visible from a repository; it does not
  auto-add new repository Issues.
- `gh project` can create fields and add or edit items, but currently cannot
  configure view grouping or sorting, repository auto-add, or reopen workflows.
  Configure those settings in the GitHub web UI and verify them afterward with
  `gh project field-list`, `gh project item-list`, and GraphQL queries.

Initial organization setup:

1. Enable Issues on Lagertha.
2. Create public organization Project `Lagertha Roadmap`.
3. Add the fields and views defined above.
4. Configure auto-add, close, and reopen workflows.
5. Create one current Lagertha Outcome.
6. Add only its immediate actionable child Issues.
7. Add a small set of Next Outcomes.
8. Add broad Later Outcomes without decomposing all of them.
9. Trial the process for several work sessions before adding more fields.
