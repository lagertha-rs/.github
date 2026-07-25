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
| Type | Outcome, Feature, Bug, Test, Debt, Docs, Decision |
| Area | Execution, Class files, Loading, Runtime/JDK, Memory, Concurrency, Debugging, Runestaff, Tooling |
| Size | S, M |

Field meanings:

- `Horizon` provides priority without artificial deadlines.
- `S` means one focused session or pull request.
- `M` means several sessions but one coherent Issue.
- Work larger than `M` must be an Outcome with child Issues.
- Manual ordering within a Horizon resolves ties.

Do not add percentage-complete, due-date, or duplicate priority fields.

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

Use Project Type `Decision` while a decision remains unresolved. Close the Issue
after recording the result in its discussion or an ADR.

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

Project fields already own Type, Status, Horizon, Area, and Size. Do not duplicate
those values as labels.

## Automation

Configure Project workflows to:

- Add new Lagertha and Runestaff Issues to Inbox.
- Move closed Issues to Done.
- Move reopened Issues to Ready.
- Leave new draft items in Inbox.

LLMs may:

- Classify Inbox items.
- Set Type, Area, Horizon, and Size.
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
