# Contributing

Thank you for considering a contribution to this repository.

This repository is not only a collection of files. It is a delivery-governance template for AI-assisted and human-reviewed web application development. Contributions should preserve that separation of responsibilities and the existing Human Merge Gate.

## Before you start

Confirm that the proposed change belongs in this repository.

This template focuses on lightweight web delivery and AI/Human development governance. Authentication, authorization, database migration, transactions, locking, idempotency, audit logging, and similar business-application concerns belong to the separate Business Application Template direction and should not be added here merely for completeness.

You do not need access to any private Notion, Google Drive, or other personal workspace to contribute. Public repository files are the authoritative contribution surface.

## Standard flow

1. Create or use one GitHub Issue as the Change Contract
2. Define the goal, scope, out-of-scope items, Planned Files, Risk Level, and Impact Flags
3. Create one branch from the latest `main`
4. Make the minimum coherent change needed for that Issue
5. Run the validation appropriate to the Impact Flags
6. Open one Pull Request that closes exactly one Change Contract Issue
7. Confirm Scope Guard and Repository validation
8. Confirm Development Convergence
9. Stop at the Human Merge Gate until a maintainer explicitly approves the merge

The default rule is:

```text
1 Issue = 1 Branch = 1 Pull Request
```

Do not modify `main` directly.

## Planned Files and scope

Every implementation Issue must contain a `Planned Files` section.

The repository's Scope Guard compares the Pull Request's changed files with that list. If implementation requires another file, update the Issue scope before adding the change. Do not bypass the guard with broad wildcards or unrelated cleanup.

Avoid mixing refactors, formatting changes, documentation rewrites, and feature changes unless they are required for the same coherent goal.

## Branches and Pull Requests

Use a branch name that makes the Issue and purpose identifiable, for example:

```text
feat/issue-123-short-purpose
bug/issue-123-short-purpose
docs/issue-123-short-purpose
release/issue-123-short-purpose
```

A Pull Request should:

- close exactly one Change Contract Issue
- explain the purpose and actual changes
- identify validation performed and validation not applicable
- list any unresolved risk or stop condition
- record the current head SHA when it matters for Human Review
- distinguish CI success from Production verification
- avoid claiming unexecuted checks as successful

Use `.github/PULL_REQUEST_TEMPLATE.md` as the default review structure.

## Validation

At minimum, allow `Repository validation` to run and confirm Scope Guard succeeds.

Additional validation depends on the change:

- documentation-only: consistency, links, required markers, Repository validation
- design/UI: visual review and Preview when applicable
- runtime: lint/test/build and relevant regression checks
- security/infrastructure: security-specific checks and rollback considerations
- production-affecting change: Production Verification after deployment

See:

- `docs/RISK_AWARE_CI.md`
- `docs/PLANNED_FILES_GUARD.md`
- `docs/CONVERGENCE_GATE.md`
- `docs/RELEASE_CHECKLIST.md`

## Human / AI collaboration

AI tools may assist with analysis, implementation, review, and documentation, but they do not remove the repository's evidence requirements or Human Merge Gate.

When using AI-assisted changes, follow `docs/HUMAN_AI_COLLABORATION.md`. In particular:

- do not treat unavailable checks as passed
- do not expand scope silently
- verify repository evidence when resuming interrupted work
- keep binary assets and generated images within the documented asset workflow

## Security-sensitive contributions

Do not publish secrets, credentials, private tokens, exploit details, or unpatched vulnerability information in a public Issue or Pull Request.

For suspected vulnerabilities in this repository, follow `SECURITY.md` before opening a public technical report.

## Licensing and third-party material

This repository is distributed under the MIT License.

Only submit code, documentation, and assets that you have the right to contribute. Clearly identify third-party material and its license when it is necessary to include it. Do not add material with unclear provenance or incompatible redistribution terms.
