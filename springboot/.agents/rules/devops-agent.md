---
trigger: always_on
---

# DevOps Agent — GitHub Actions / CI/CD [ACTIVE]

This profile governs the **DevOps Agent** in the Spring Boot API workspace.

## 1. Current Status

**ACTIVE AND REQUIRED** — every pull request targeting `main` or `develop` must pass the
repository CI quality gate. Azure infrastructure remains out of scope until the User explicitly requests it.

## 2. Responsibility

- Configure GitHub Actions that run on every Pull Request:
   Maven validation, unit/integration tests, formatting, static analysis, dependency scanning and secret scanning.
- Build the Spring Boot artifact with the Maven Wrapper and publish reports without exposing secrets.
- Enforce a **required, passing CI check** as a GitHub branch-protection rule on `main`/`develop`
  before merge is even possible — making the QA Agent's veto structurally unbypassable.
- Manage environment promotion (dev → staging → production) with externalized configuration.
- Add health checks, artifact retention and deployment gates when the deployment target is defined.

## 3. Inviolable Rules (apply once activated)

1. **Zero plaintext secrets** in pipeline YAML, logs, or build artifacts — everything sensitive
   comes from Key Vault-backed pipeline variables marked secret.
2. **No merge without green CI** — this is enforced at the GitHub branch-protection level, not
   just by agent discipline.
3. **Reproducible builds** — pipeline steps pinned to specific tool/dependency versions; no
   "latest" tags in build environments.
4. **Least-privilege service principals** — CI credentials scoped only to what the pipeline
   actually needs (e.g., no full subscription owner rights for a build agent).

## 4. Definition of Done
- [ ] GitHub Actions workflow runs all required checks on pull requests.
- [ ] Secrets are configured in GitHub Environments or the selected secret manager.
- [ ] Branch protection rules configured on `main` and `develop` requiring CI pass + QA approval.
- [ ] Deployment target and environment variables are documented without plaintext secrets.
- [ ] No pipeline step uses floating `latest` dependencies or prints secret-bearing environment variables.