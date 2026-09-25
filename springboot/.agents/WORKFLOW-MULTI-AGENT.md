# Multi-Agent Workflow & Operating Model

This document defines the operating protocol for a 5-agent specialized development team building
a **Spring Boot backend API**, integrated with **GitHub**
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
│(Spring API, DB)  │       │ (DISABLED)      │       │ (JUnit/API/QA)   │
└──────────────────┘       └──────────────────┘       └──────────────────┘
                                                               │
                                                               ▼
                                                      ┌──────────────────┐
                                                      │  AGENT 5: DEVOPS │
                                                      │ (GitHub Actions) │
                                                      │     [ACTIVE]     │
                                                      └──────────────────┘
```

| Agent | Owns | Never touches |
|---|---|---|
| Orchestrator | Requirements, order issuance, Git branch/PR lifecycle | Feature code |
| Backend | Controllers, services, repositories, entities, DTOs | CI/CD and frontend |
| Frontend *(disabled)* | None in this workspace | All backend work |
| QA | JUnit, MockMvc, integration tests, quality gate | Merges to base branches |
| DevOps | Maven CI/CD, secrets infra, release pipelines | Feature/business logic |

---

## 2. End-to-End Flow (Notion → Git → Code → Test → PR)

```
[REQUIREMENT]     [ORCHESTRATOR]        [BACKEND]            [QA]              [GITHUB]
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

1. **Requirement intake** — The User asks the Orchestrator to process a specific requirement from the exclusive backend board **`Sprint Backlog - Flurep Backend`** (`3d95943a-993d-8124-8840-d19f5f8e5522`).
   The Orchestrator confirms title, scope and acceptance criteria meet the **Definition of Ready**
   (see `rules/orchestrator-agent.md`).

2. **Branch creation (GitHub)** — The Orchestrator creates a branch following
   `feat/<NOTION_ID>-<short-description>` or `fix/<NOTION_ID>-<short-description>`, then moves the
   Notion card in `Sprint Backlog - Flurep Backend` to `In Progress` with the branch name linked.

3. **Order issuance & execution** — The Orchestrator posts the explicit order block for the
   Backend specialist. The specialist implements within Spring Boot boundaries and the scope defined in the order. The User can interject at
   any point before or during execution.

4. **Mandatory validation (QA)** — The Orchestrator hands context to the QA Agent. QA writes/runs
   unit, API and integration tests against the coverage matrix in `rules/qa-agent.md`. Any failure returns the
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
    - Local hooks are defense in depth only; GitHub branch protection and required CI checks are the
       authoritative enforcement boundary and must be verified as configured before the first PR.

2. **Requirement traceability**
   - No loose local task files (`TODO.md`, `tasks.md`, etc.). Every change must have a clear requirement and acceptance criteria.

3. **Zero secrets in code**
    - No agent ever writes tokens, private URLs, database passwords or API keys into source or commits.
       Runtime secrets come from environment variables, GitHub Actions secrets or a managed vault.

4. **Architecture is non-negotiable**
    - Strict layering: `controller → service → repository`, with DTOs at API boundaries.

5. **Quality gate is structural, not optional**
    - No PR is opened and no ticket reaches `Done` without QA's explicit `APPROVED` report
       (`rules/qa-agent.md`, Rule 1 and Rule 5). Local hooks intercept supported PR creation attempts,
       while final enforcement must be guaranteed by repository branch protection and required passing
       CI status checks (`rules/devops-agent.md`). If branch protection is not verified, the ticket cannot be marked Done.

6. **Traceability**
    - Every commit references its requirement ID when available. Every PR lists QA evidence.