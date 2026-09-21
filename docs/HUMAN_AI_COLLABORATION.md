# Human / AI Collaboration Guardrails

## Purpose

This document defines cross-project guardrails for collaboration between the Human owner and ChatGPT/AI when working with GitHub, binary assets, and generative design work.

These rules are **not application-specific**. They apply to every Repository and project that uses this template.

Repository-specific design rules may add constraints, but must not silently weaken these guardrails.

## STOP Gate

Before any GitHub handoff, binary Asset operation, or generative image action, AI must check the applicable rules below. If a STOP condition is met, do not continue to the action.

## GR-001 GitHub URL presentation

When presenting a GitHub URL to the Human:

- Do not use Markdown links.
- Do not use clickable/rich URL formatting.
- Put the raw GitHub URL in a fenced code block so it can be copied and opened in a browser without intentionally invoking the GitHub app.
- This applies across all repositories and projects.

**STOP:** If the GitHub URL is about to be emitted as a clickable link, stop and convert it to a raw URL in a code block.

## GR-002 Binary files use Human Upload by default

For images and other binary files, do not assume AI can reliably upload the file to GitHub.

Default flow:

1. AI creates or identifies the Issue-specific branch.
2. AI creates the upload destination folder when a folder must exist first.
3. AI tells the Human the branch, folder, expected filenames, and copyable raw GitHub URL.
4. Human uploads the binary files.
5. Human reports completion.
6. AI verifies the actual files in GitHub before continuing.
7. AI records hash/SHA/dimensions/format when required by the Asset workflow.

Do not repeatedly retry AI-side binary upload merely because a connector/API exposes a possible transport route.

**STOP:** If AI is about to choose direct binary upload as the default path, stop and use Human Upload.

## GR-003 Image generation requires explicit approval

Do not generate a new image merely because an image may be useful.

Before generation, confirm that the Human has explicitly requested/approved generation and that the intended direction is sufficiently agreed:

- purpose
- composition / primary subject
- required and prohibited elements
- color / brightness / texture
- text presence
- size / aspect ratio
- relationship to existing design
- scope of the current iteration

If the Human explicitly says to create/generate the already-agreed image, generation may proceed.

**STOP:** No explicit generation approval, or unresolved material design direction -> do not invoke image generation.

## GR-004 “Continue” is scoped

“Continue” authorizes continuation of the currently agreed workflow. It does not automatically authorize:

- a new visual concept
- a new image
- a new destructive GitHub operation
- Production release
- Merge where Human approval is required
- expansion into a different project/scope

**STOP:** If continuation crosses one of these boundaries, obtain the required Human decision first.

## GR-005 Do not re-ask after Human Upload

When the Human says an upload is complete:

- inspect GitHub first
- do not ask the Human to upload again unless verification actually fails
- distinguish “not found,” “wrong branch/path,” and “connector limitation”

## GR-006 Repository rules and collaboration rules are separate

Repository documentation defines product architecture, file placement, build/deploy behavior, and project-specific constraints.

This document defines Human/AI collaboration behavior.

Do not rewrite a collaboration preference as an application architecture decision. If both apply, satisfy both.

## Recurrence handling

When the Human reports a repeated violation:

1. identify the violated GR-ID
2. identify why the STOP gate failed
3. strengthen the guardrail or its mandatory entry point
4. do not merely add another duplicate rule
5. verify related templates/documents for conflicting instructions

Repeated mistakes are treated as a guardrail failure, not as a reminder problem.
