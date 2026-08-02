# Lagertha Organization

This repository contains organization-wide documentation and process. Read
[`docs/project-management.md`](docs/project-management.md) before creating,
updating, or closing roadmap items and Issues.

Use `gh` for GitHub Issues, Projects, pull requests, but for repository inspection prefer local workspace.

## LLM Role

The maintainer writes production code and owns implementation decisions. LLMs
support research, test planning, documentation, code review, and roadmap
management. Write Issues for the human maintainer who will implement them, not
as autonomous coding-agent prompts.

## Local Workspace

Organization repositories are cloned as siblings under one workspace root:

```text
lagertha-org-workspace/
├── .github/ (this repository)
├── lagertha/
└── runestaff/
```

Discover sibling repositories from the workspace root when work crosses
repository boundaries. Read each repository's own `AGENTS.md` and documentation
before changing its code. Repository-specific instructions override this file.

## Planning Rules

- Use the organization Project for priority and workflow state.
- Use Issues only for actionable work and roadmap outcomes.
- Put cross-repository outcome Issues in `lagertha-rs/lagertha`.
- Put implementation Issues in the repository where the change belongs.
- Do not create an Issue for every missing or untested feature.
- Keep one primary work Issue in progress at a time.
- Link pull requests to their Issues and list affected feature IDs.
- Add a handoff comment before stopping incomplete work.
- Record durable architectural decisions in repository ADRs.
- Never duplicate Project status in Markdown roadmaps or TODO lists.
- For Java behavioral work, derive a bounded JVMS/JLS case matrix before
  choosing tests. Cover distinct precedence, inheritance, access, flag, and
  error branches in scope; record intentionally deferred or source-illegal
  cases instead of stopping after the first failing example.
- Reconcile confirmed behavior gaps with affected feature definitions. Do not
  leave a feature marked implemented when a specification-required limitation
  has been demonstrated.
