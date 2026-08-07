# Project Work Rules

## Release Validation

- Before committing, pushing, or releasing, check only the files changed in the current task for syntax errors with their native language syntax checker.
- Never run full-repository tests, linters, formatters, type checks, builds, Docker Compose validation, or unrelated checks unless the user explicitly requests them.
- Documentation-only and rule-only changes do not require a syntax check.
- If the required language runtime is unavailable locally, do not install temporary tools or start unrelated services. Report that the local syntax check could not run and rely on the existing GitHub Actions validation.
- Docker image runtime behavior is verified by the existing GitHub Actions `validate` and `smoke-amd64` jobs before image publication.
- When a release tag already exists and the user explicitly requests republishing that version, update the tag with `--force-with-lease`; never use an unrestricted force push.

## Release Scope

- Commit and push only files related to the current task.
- Use Chinese commit messages.
- Do not monitor GitHub Actions after pushing a release tag unless the user explicitly requests monitoring.
