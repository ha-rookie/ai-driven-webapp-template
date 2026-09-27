# Security Policy

## Scope

This document covers security issues in this repository itself: its template files, scripts, GitHub Actions workflows, documentation, and repository governance.

Application-specific security design for projects created from this template is documented separately in `docs/SECURITY_BASELINE.md` and related project documentation.

## Supported versions

Until formal Git tags / GitHub Releases are operated, the supported security baseline is the current default branch.

| Version | Security support |
| --- | --- |
| current `main` | Supported |
| historical commits / untagged snapshots | No formal support commitment |

This policy may be revised when tagged releases are introduced.

## Reporting a vulnerability

Please do not publish secrets, exploit steps, proof-of-concept payloads, or details that would make an unpatched vulnerability easier to abuse in a public Issue, Pull Request, Discussion, or comment.

Preferred reporting path:

1. Open the repository's **Security** tab
2. If **Report a vulnerability** / private vulnerability reporting is available, use that private channel
3. Include enough information to reproduce and assess the issue without adding unrelated sensitive data

Useful details include:

- affected file, workflow, script, or behavior
- security impact
- reproducible conditions
- whether the issue affects this template itself or only a derived application
- a minimal proof of concept when it can be shared privately
- any known mitigation

If a private vulnerability-reporting route is not available, do **not** post the technical vulnerability details publicly. Open a minimal public Issue requesting a private security contact channel, without secrets, exploit code, vulnerable payloads, or other abuse-enabling details.

## What not to report here

The following are normally project-specific rather than vulnerabilities in this template:

- an application's own credentials or leaked secrets
- a project's authentication or authorization bug introduced after using the template
- application-specific business logic defects
- a deployment configuration that differs from this repository's documented baseline
- optional security headers that were intentionally not enabled for a project

Those should be handled in the affected project's own security process unless the root cause is a defect in this template.

## Handling expectations

Security reports should be evaluated against repository evidence and the actual affected revision. A report should not be considered fixed only because documentation changed or a CI check passed; the relevant behavior must be verified at the appropriate layer.

For fixes that change repository files, the normal Change Contract, Planned Files, CI, Convergence, and Human Merge Gate still apply. Sensitive details may need to remain outside public Issue/PR text until disclosure is safe.

## Disclosure

Please allow time for a fix or mitigation to be prepared before public disclosure. Once a vulnerability is resolved and disclosure is safe, the public record may summarize the issue, affected scope, remediation, and any user action required without exposing unnecessary sensitive material.
