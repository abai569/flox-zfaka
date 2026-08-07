# Project Work Rules

## Release Validation

- Before committing, pushing, or releasing, run only the checks explicitly defined here:
  - `git diff --check`
  - `bash -n install.sh`
  - `sh -n docker/entrypoint.sh`
  - `docker compose --env-file .env.example config --quiet`
- Do not add ad hoc local validators such as temporary package installs, unrelated linters, formatters, LSP checks, or parser tools unless the user explicitly requests them.
- Docker image runtime behavior is verified by the existing GitHub Actions `validate` and `smoke-amd64` jobs before image publication.
- When a release tag already exists and the user explicitly requests republishing that version, update the tag with `--force-with-lease`; never use an unrestricted force push.

## Release Scope

- Commit and push only files related to the current task.
- Use Chinese commit messages.
- Do not monitor GitHub Actions after pushing a release tag unless the user explicitly requests monitoring.
