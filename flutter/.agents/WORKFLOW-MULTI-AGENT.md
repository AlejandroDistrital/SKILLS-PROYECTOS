# Multi-Agent Workflow & Operating Model

This document defines the operating protocol for a 5-agent specialized development team building
a **Flutter mobile application**, integrated with **Notion** (backlog & board) and **GitHub**
(version control & PRs), guaranteeing full human control and visibility into every instruction.

Per-agent detailed rules live in companion files:
`rules/orchestrator-agent.md`, `rules/backend-agent.md`, `rules/frontend-agent.md`,
`rules/qa-agent.md`, and `rules/devops-agent.md`. This document covers topology, the end-to-end
flow, and cross-cutting governance.

---

## 1. Agent Topology & Roles

```
                      ┌───────────────────────────┐
                      │           USER             │
                      │      (Full Control)        │
                      └─────────────┬─────────────┘
                                    │ Communicates exclusively with
                                    ▼
                      ┌───────────────────────────┐
                      │  AGENT 1: ORCHESTRATOR    │ ◄─── Connected to Notion & GitHub
                      │   (Coordinator & Lead)     │
                      └─────────────┬─────────────┘
                                    │
          Issues explicit order     │ (Visible to the User before execution)
         ┌──────────────────────────┼──────────────────────────┐
         ▼                          ▼                          ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│ AGENT 2: BACKEND │       │AGENT 3: FRONTEND │       │ AGENT 4: TESTING │
│(API, DB, Logic)  │       │(Flutter Clean UI)│       │  (Unit/Widget/QA)│
└──────────────────┘       └──────────────────┘       └──────────────────┘
                                                               │
                                                               ▼
                                                      ┌──────────────────┐
                                                      │  AGENT 5: DEVOPS │
                                                      │  (Azure / CI/CD) │
                                                      │    [STANDBY]     │
                                                      └──────────────────┘
```

| Agent | Owns | Never touches |
|---|---|---|
| Orchestrator | Notion sync, order issuance, Git branch/PR lifecycle | Feature code |
| Backend | `data/`, `domain/` | `presentation/`, widgets |
| Frontend | `presentation/` (MVVM) | Network clients, DB, DTOs |
| QA | Test suites, quality gate | Merges to base branches |
| DevOps *(standby)* | CI/CD, secrets infra, release pipelines | Feature/business logic |

---

## 2. End-to-End Flow (Notion → Git → Code → Test → PR)

```
[NOTION]          [ORCHESTRATOR]        [SPECIALIST]         [QA]              [GITHUB]
   │                    │                     │                 │                │
   │ 1. Task in To Do   │                     │                 │                │
   ├───────────────────►│                     │                 │                │
   │                    │ 2. Create branch    │                 │                │
   │                    ├───────────────────────────────────────────────────────►│ feat/NOTION-123
   │                    │ 3. → In Progress    │                 │                │
   │◄───────────────────┤                     │                 │                │
   │                    │ 4. Issue ORDER      │                 │                │
   │                    │ (visible to User)   │                 │                │
   │                    ├────────────────────►│                 │                │
   │                    │                     │ 5. Write code   │                │
   │                    │                     ├─────────────────────────────────►│ Atomic commit
   │                    │ 6. Request tests    │                 │                │
   │                    ├──────────────────────────────────────►│                │
   │                    │                     │                 │ 7. Run tests   │
   │                    │                     │                 ├───────────────►│ Test commit
   │                    │ 8. Open Pull Request (only on QA APPROVED)             │
   │                    ├───────────────────────────────────────────────────────►│ PR → develop
   │ 9. → Done          │                     │                 │                │
   │◄───────────────────┤                     │                 │                │
```

### Step by step

1. **Backlog intake (Notion)** — The User asks the Orchestrator to process a specific ticket
   (e.g. *"Process ticket NOTION-101"*). The Orchestrator reads title, description, and
   acceptance criteria, and confirms the ticket meets the **Definition of Ready**
   (see `rules/orchestrator-agent.md`).

2. **Branch creation (GitHub)** — The Orchestrator creates a branch following
   `feat/<NOTION_ID>-<short-description>` or `fix/<NOTION_ID>-<short-description>`, then moves the
   Notion card to `In Progress` with the branch name linked.

3. **Order issuance & execution** — The Orchestrator posts the explicit order block for the
   assigned specialist (Backend and/or Frontend). The specialist implements strictly within
   `flutter-clean-code` boundaries and the scope defined in the order. The User can interject at
   any point before or during execution.

4. **Mandatory validation (QA)** — The Orchestrator hands context to the QA Agent. QA writes/runs
   unit and widget tests against the coverage matrix in `rules/qa-agent.md`. Any failure returns the
   ticket to the responsible specialist with a structured report — the loop repeats until QA
   issues an explicit `APPROVED` report.

5. **Pull Request & closure** — Commits follow Conventional Commits (`feat:`, `fix:`, `test:`,
   `refactor:`, `chore:`). The Orchestrator opens the PR against the integration branch
   (`develop` or `main`) only after QA approval, then updates Notion to `In Review` and finally
   `Done` once the PR is merged.

---

## 3. Cross-Cutting Governance Rules

1. **The User retains control at all times**
   - Every inter-agent order is printed in chat before execution — nothing happens silently.
   - No destructive Git action (`push --force`, history rewrite, branch deletion on
     `main`/`develop`) without explicit human confirmation for that specific action.

2. **Single backlog in Notion**
   - No loose local task files (`TODO.md`, `tasks.md`, etc.). Notion is the only source of truth
     for task state.

3. **Zero secrets in code**
   - No agent ever writes tokens, private URLs, or API keys into Dart source or commits. Runtime
     user tokens use `flutter_secure_storage`; backend credentials remain server-side.
     `--dart-define-from-file` / CI vault variables may carry only public build configuration —
     never secrets.

4. **Architecture is non-negotiable**
   - Strict layering: `presentation → domain ← data`. No agent — including the Orchestrator —
     authorizes a shortcut that bypasses this dependency direction.

5. **Quality gate is structural, not optional**
   - No PR is opened and no ticket reaches `Done` without QA's explicit `APPROVED` report
     (`rules/qa-agent.md`, Rule 1 and Rule 5). Local agent execution hooks intercept terminal
     PR creation attempts, while final enforcement is guaranteed by repository branch protection
     and required passing CI status checks (`rules/devops-agent.md`).

6. **Traceability**
   - Every commit references its Notion ID. Every PR description links back to the originating
     ticket and lists the QA evidence (test counts, coverage notes).