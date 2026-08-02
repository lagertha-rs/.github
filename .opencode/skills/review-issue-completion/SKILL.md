---
name: review-issue-completion
description: Reviews completed Lagertha or Runestaff work against its GitHub Issue and recommends whether it is ready to close. Use when asked to review a completed task, validate Issue completion, verify acceptance criteria, or close an Issue.
---

# Review Issue Completion

Determine whether delivered work satisfies an actionable Issue or roadmap
Outcome. Require observable evidence, not implementation presence or passing
tests alone.

## Authority

- Read `.github/docs/project-management.md` from the workspace root first.
- Read every affected repository's `AGENTS.md` and relevant build, test, and
  feature-tracking documentation.
- Use `gh` for Issue, pull request, Project, and CI state. Prefer local files for
  source and diff inspection.
- Review and recommend. Do not close the Issue, change acceptance criteria, move
  Project status to `Done`, or create follow-up Issues until the maintainer
  explicitly confirms those actions.
- Do not implement production code while performing this review. Report defects
  and missing work instead.

## Gather State

1. Read the Issue body, all scope-changing discussion, latest handoff, linked
   pull requests, reviews, and checks.
2. Identify the merged commits or pull requests claimed to complete the Issue.
   If work is unmerged, state that closure is premature unless the Issue defines
   a non-code result.
3. Inspect the complete Issue diff from its base, not only the latest commit.
4. Read linked parent or child Issues when their state affects completion.
5. Record the Issue type, affected repositories, feature IDs, required
   documentation, and stated validation.

If Issue tracking or Project state is unavailable, report the setup gap. Review
local evidence when possible, but do not infer remote state.

## Evaluate Criteria

Build a criterion-by-criterion evidence table. Include explicit acceptance
criteria plus requirements implied by the Issue's desired behavior and agreed
scope.

For each criterion, assign one status:

- `Met`: direct merged evidence and required validation exist.
- `Unmet`: behavior or required evidence is missing or incorrect.
- `Unclear`: wording, evidence, or scope decision is insufficient.
- `Out of scope`: only when Issue discussion explicitly records that decision.

Evidence may include code paths, tests, integration output, snapshots, feature
definitions, generated reports, documentation, ADRs, and verified CI. A test
name, enum variant, parser arm, interpreter arm, native registration, stub, or
closed child Issue is not sufficient by itself.

## Specification Review

For Lagertha Java behavior:

1. Use the official Java SE 25 HTML JVMS as the primary source and the JLS when
   source-language behavior matters.
2. Use Lagertha's ignored local specification cache to search and read only
   relevant sections. Do not load or convert the complete specification.
3. Verify every persisted page and fragment against the original cached HTML.
   Refresh the cache only when missing or current upstream content must be
   reconfirmed.
4. Distinguish Java specification requirements from reference-JDK, `javac`, or
   HotSpot behavior.
5. Independently derive a bounded case matrix from each relevant specification
   algorithm. Include applicable precedence, inheritance and recursive lookup,
   access and flag, ambiguity, boundary, and specified-error branches. Mark
   source-illegal and exact-classfile-only rows explicitly.
6. Compare the matrix with delivered fixtures and snapshots. Do not treat one
   representative passing test as complete evidence for a multi-branch
   algorithm, and do not let an early failing branch mask later rows.

## Validate Delivery

1. Run the narrowest tests that exercise each criterion.
2. Run repository-required formatting, lint, build, and test checks when
   practical. If a required check is not run, state why and treat the gap as a
   residual risk or blocker according to its relevance.
3. Check current linked CI rather than stale runs from unrelated commits.
4. Review changed snapshots and fixtures semantically. Never accept snapshot
   changes solely to make tests pass.
5. Verify feature YAML, integration metadata, generated feature and coverage
   reports, documentation, and ADRs follow repository rules. Never edit
   generated artifacts manually.
6. Inspect sibling repositories when public models, generated class files, or
   cross-repository behavior changed.
7. Check for regressions, accidental scope expansion, and missing negative or
   boundary tests suggested by the changed behavior.
8. Reconcile every confirmed limitation with affected feature YAML. Block
   closure when a feature remains `implemented` despite demonstrated missing
   required behavior, or when a removed limitation lacks focused green evidence.

## Verdict

Return this report:

```markdown
## Verdict

Ready to close | Blocked

## Acceptance Criteria

| Criterion | Status | Evidence |
|---|---|---|

## Validation

Commands and CI checks run, with results and omitted checks.

## Findings

Correctness defects, regressions, missing evidence, or scope problems ordered
by severity, with file and line references.

## Tracking

Feature IDs, limitation reconciliation, specification case matrix,
documentation, ADRs, child work, and Project state checked.

## Residual Risks

Unknowns and non-blocking follow-up work.

## Confirmation

Ask the maintainer whether to close and move the Issue to Done, or whether to
record blockers and continue work.
```

Use `Blocked` if any required criterion is `Unmet` or `Unclear`, required work
is unmerged, relevant required checks fail, or permanent tracking contradicts
the delivered behavior. Findings come before general summary when defects
exist. Do not weaken acceptance criteria to obtain a passing verdict.

## After Confirmation

If closure is confirmed and the verdict remains `Ready to close`:

1. Recheck Issue, pull request, CI, and Project state for concurrent changes.
2. Add a concise completion comment only when useful evidence is not already in
   the linked pull request or Issue discussion.
3. Close the Issue and confirm Project automation moved it to `Done`; update the
   field directly only when automation did not.
4. For an Outcome, close it only after separately verifying its user-visible
   result and required child work.
5. Report changed GitHub URLs and Project fields.

If continued work is confirmed:

1. Add a concise blocker or handoff comment with unmet criteria and the next
   exact step.
2. Keep the Issue `In progress` or mark it `Blocked` only when a named external
   dependency or decision prevents progress.
3. Create follow-up Issues only for confirmed out-of-scope work.
