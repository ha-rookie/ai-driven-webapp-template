#!/usr/bin/env bash
set -euo pipefail

issue_number="${1:-${ISSUE_NUMBER:-}}"

if [[ -z "$issue_number" || ! "$issue_number" =~ ^[0-9]+$ ]]; then
  echo "Usage: scripts/derive-workflow-status.sh <issue-number>" >&2
  echo "   or: ISSUE_NUMBER=<number> scripts/derive-workflow-status.sh" >&2
  exit 2
fi

for command_name in gh jq; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 2
  fi
done

repo="${REPOSITORY:-${GITHUB_REPOSITORY:-}}"
if [[ -z "$repo" ]]; then
  repo="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
fi

if [[ ! "$repo" =~ ^[^/]+/[^/]+$ ]]; then
  echo "Repository must be owner/name: $repo" >&2
  exit 2
fi

array_to_json() {
  if [[ "$#" -eq 0 ]]; then
    printf '[]'
  else
    printf '%s\n' "$@" | jq -R . | jq -s .
  fi
}

blocked_reasons=()
unverified_checks=()
conflicts=()
evidence=()

issue_json="$(gh api "repos/${repo}/issues/${issue_number}")"
issue_state="$(jq -r '.state' <<<"$issue_json")"
issue_title="$(jq -r '.title' <<<"$issue_json")"
issue_url="$(jq -r '.html_url' <<<"$issue_json")"
evidence+=("$issue_url")

branch_hint="$(
  jq -r '
    (.body // "") as $body
    | try ($body | capture("(?m)^Branch:[[:space:]]*`?(?<value>[^`\\r\\n]+)`?[[:space:]]*$").value) catch ""
  ' <<<"$issue_json"
)"
pr_hint="$(
  jq -r '
    (.body // "") as $body
    | try ($body | capture("(?m)^PR:[[:space:]]*#?(?<value>[0-9]+)[[:space:]]*$").value) catch ""
  ' <<<"$issue_json"
)"

if [[ "$branch_hint" == *"<"*">"* || "$branch_hint" == *"作成後"* ]]; then
  branch_hint=""
fi

branches_json="$(gh api --paginate "repos/${repo}/branches?per_page=100" | jq -s 'add // []')"
issue_pattern="issue-${issue_number}-"

mapfile -t branch_candidates < <(
  jq -r --arg pattern "$issue_pattern" '.[] | select(.name | contains($pattern)) | .name' <<<"$branches_json"
)

branch=""
if [[ -n "$branch_hint" ]]; then
  if jq -e --arg branch "$branch_hint" '.[] | select(.name == $branch)' <<<"$branches_json" >/dev/null; then
    branch="$branch_hint"
  else
    conflicts+=("Issue branch hint does not exist: ${branch_hint}")
  fi
fi

if [[ -z "$branch" ]]; then
  if [[ "${#branch_candidates[@]}" -eq 1 ]]; then
    branch="${branch_candidates[0]}"
    if [[ -n "$branch_hint" && "$branch_hint" != "$branch" ]]; then
      conflicts+=("Using discovered branch ${branch}; Issue branch hint is stale")
    fi
  elif [[ "${#branch_candidates[@]}" -gt 1 ]]; then
    blocked_reasons+=("Multiple branches match Issue #${issue_number}; refusing to guess")
  fi
fi

head_sha=""
if [[ -n "$branch" ]]; then
  head_sha="$(jq -r --arg branch "$branch" '.[] | select(.name == $branch) | .commit.sha' <<<"$branches_json" | head -n 1)"
  evidence+=("https://github.com/${repo}/tree/${branch}")
fi

pr_json=""
pr_number=""
if [[ -n "$pr_hint" ]]; then
  set +e
  candidate_pr_json="$(gh pr view "$pr_hint" --repo "$repo" --json number,state,isDraft,mergedAt,headRefName,headRefOid,baseRefName,url,body,mergeable 2>/dev/null)"
  candidate_pr_rc=$?
  set -e
  if [[ "$candidate_pr_rc" -eq 0 && -n "$candidate_pr_json" ]]; then
    pr_json="$candidate_pr_json"
    pr_number="$pr_hint"
    candidate_head="$(jq -r '.headRefName' <<<"$pr_json")"
    if [[ -n "$branch" && "$candidate_head" != "$branch" ]]; then
      conflicts+=("Issue PR hint #${pr_hint} points to ${candidate_head}, not ${branch}")
    elif [[ -z "$branch" ]]; then
      branch="$candidate_head"
      head_sha="$(jq -r '.headRefOid' <<<"$pr_json")"
    fi
  else
    conflicts+=("Issue PR hint cannot be resolved: #${pr_hint}")
  fi
fi

if [[ -z "$pr_json" && -n "$branch" ]]; then
  prs_json="$(gh pr list --repo "$repo" --state all --head "$branch" --limit 20 --json number,state,isDraft,mergedAt,headRefName,headRefOid,baseRefName,url,body,mergeable)"
  pr_count="$(jq 'length' <<<"$prs_json")"
  if [[ "$pr_count" -eq 1 ]]; then
    pr_json="$(jq '.[0]' <<<"$prs_json")"
    pr_number="$(jq -r '.number' <<<"$pr_json")"
  elif [[ "$pr_count" -gt 1 ]]; then
    blocked_reasons+=("Multiple pull requests use branch ${branch}; use Issue PR tracking to disambiguate")
  fi
fi

pr_state="none"
pr_url=""
pr_merged_at=""
pr_mergeable=""
reported_development_convergence=""
reported_release_convergence=""
ci_status="not-applicable"
checks_json='[]'

if [[ -n "$pr_json" ]]; then
  pr_url="$(jq -r '.url' <<<"$pr_json")"
  evidence+=("$pr_url")
  pr_merged_at="$(jq -r '.mergedAt // ""' <<<"$pr_json")"
  pr_mergeable="$(jq -r '.mergeable // "UNKNOWN"' <<<"$pr_json")"
  if [[ -n "$pr_merged_at" ]]; then
    pr_state="merged"
  else
    pr_state="$(jq -r '.state | ascii_downcase' <<<"$pr_json")"
  fi
  head_sha="$(jq -r '.headRefOid' <<<"$pr_json")"

  reported_development_convergence="$(
    jq -r '
      (.body // "") as $body
      | try ($body | capture("(?m)Development Convergence:[[:space:]]*(?<value>[^\\r\\n]+)").value) catch ""
    ' <<<"$pr_json"
  )"
  reported_release_convergence="$(
    jq -r '
      (.body // "") as $body
      | try ($body | capture("(?m)Release Convergence:[[:space:]]*(?<value>[^\\r\\n]+)").value) catch ""
    ' <<<"$pr_json"
  )"

  if [[ "$pr_state" == "open" ]]; then
    set +e
    checks_json="$(gh pr checks "$pr_number" --repo "$repo" --json name,state,bucket,workflow 2>/dev/null)"
    checks_rc=$?
    set -e
    if [[ -z "$checks_json" || ! "$checks_json" =~ ^\[ ]]; then
      checks_json='[]'
    fi

    check_count="$(jq 'length' <<<"$checks_json")"
    if [[ "$check_count" -eq 0 ]]; then
      ci_status="not-reported"
      unverified_checks+=("No PR check results were reported")
    elif jq -e 'any(.[]; ((.bucket // "") | ascii_downcase) == "fail" or ((.bucket // "") | ascii_downcase) == "cancel")' <<<"$checks_json" >/dev/null; then
      ci_status="failed"
      blocked_reasons+=("One or more PR checks failed or were cancelled")
    elif jq -e 'any(.[]; ((.bucket // "") | ascii_downcase) == "pending")' <<<"$checks_json" >/dev/null; then
      ci_status="pending"
    elif jq -e 'all(.[]; (((.bucket // "") | ascii_downcase) == "pass") or (((.bucket // "") | ascii_downcase) == "skipping"))' <<<"$checks_json" >/dev/null; then
      ci_status="success"
    else
      ci_status="unknown"
      unverified_checks+=("PR check state could not be classified")
    fi

    if [[ "$checks_rc" -ne 0 && "$ci_status" == "success" ]]; then
      unverified_checks+=("gh pr checks returned a non-zero exit code despite pass/skipping buckets")
    fi
  fi
fi

phase="change-contract"
current_human_gate="none"

if [[ -n "${blocked_reasons[*]:-}" ]]; then
  phase="blocked"
elif [[ "$pr_state" == "merged" ]]; then
  if [[ "$reported_release_convergence" == Converged* ]]; then
    phase="release-converged"
  elif [[ "$reported_release_convergence" == "Not Applicable"* ]]; then
    phase="merged-release-not-applicable"
  else
    phase="merged-production-unverified"
    unverified_checks+=("Production / Release Convergence is not established by derived machine evidence")
  fi
elif [[ "$pr_state" == "open" ]]; then
  case "$ci_status" in
    failed)
      phase="blocked"
      ;;
    pending|not-reported|unknown)
      phase="ci-validation"
      ;;
    success)
      if [[ "$reported_development_convergence" == Converged* ]]; then
        phase="human-merge-gate"
        current_human_gate="merge-approval"
      else
        phase="development-convergence"
        unverified_checks+=("Development Convergence is not reported as Converged")
      fi
      ;;
  esac
elif [[ "$pr_state" == "closed" ]]; then
  phase="pr-closed-unmerged"
elif [[ -n "$branch" ]]; then
  phase="implementation"
elif [[ "$issue_state" == "closed" ]]; then
  phase="closed-without-derived-pr"
  unverified_checks+=("Issue is closed but no PR was derived")
fi

if [[ -n "$pr_json" && "$pr_state" == "open" && "$reported_development_convergence" == Converged* ]]; then
  unverified_checks+=("Development Convergence is reported in the PR body; verify its referenced evidence before Merge")
fi

preview_state="not-derived"
production_state="not-yet-applicable"
if [[ "$pr_state" == "merged" ]]; then
  if [[ "$reported_release_convergence" == Converged* ]]; then
    production_state="reported-release-converged"
  elif [[ "$reported_release_convergence" == "Not Applicable"* ]]; then
    production_state="not-applicable"
  else
    production_state="unverified"
  fi
fi

if [[ "${#conflicts[@]}" -gt 0 ]]; then
  unverified_checks+=("One or more tracking hints conflict with direct GitHub evidence; regenerate after correcting the hint if needed")
fi

blocked_json="$(array_to_json "${blocked_reasons[@]}")"
unverified_json="$(array_to_json "${unverified_checks[@]}")"
conflicts_json="$(array_to_json "${conflicts[@]}")"
evidence_json="$(array_to_json "${evidence[@]}")"
blocked_reason_json="null"
if [[ "${#blocked_reasons[@]}" -gt 0 ]]; then
  blocked_reason_json="$(jq -Rn --arg value "${blocked_reasons[0]}" '$value')"
fi

derived_at="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

jq -n \
  --arg schema_version "1" \
  --arg derived_at "$derived_at" \
  --arg repository "$repo" \
  --argjson authoritative false \
  --argjson issue_number "$issue_number" \
  --arg issue_state "$issue_state" \
  --arg issue_title "$issue_title" \
  --arg issue_url "$issue_url" \
  --arg branch "$branch" \
  --arg head_sha "$head_sha" \
  --arg pr_number "$pr_number" \
  --arg pr_state "$pr_state" \
  --arg pr_url "$pr_url" \
  --arg pr_mergeable "$pr_mergeable" \
  --arg pr_merged_at "$pr_merged_at" \
  --arg phase "$phase" \
  --arg current_human_gate "$current_human_gate" \
  --arg ci_status "$ci_status" \
  --arg reported_development_convergence "$reported_development_convergence" \
  --arg reported_release_convergence "$reported_release_convergence" \
  --arg preview_state "$preview_state" \
  --arg production_state "$production_state" \
  --argjson checks "$checks_json" \
  --argjson blocked_reasons "$blocked_json" \
  --argjson unverified_checks "$unverified_json" \
  --argjson conflicts "$conflicts_json" \
  --argjson evidence "$evidence_json" \
  --argjson blocked_reason "$blocked_reason_json" \
  '{
    schema_version: ($schema_version | tonumber),
    authoritative: $authoritative,
    derived_at: $derived_at,
    repository: $repository,
    issue: {
      number: $issue_number,
      state: $issue_state,
      title: $issue_title,
      url: $issue_url
    },
    branch: {
      name: (if $branch == "" then null else $branch end),
      head_sha: (if $head_sha == "" then null else $head_sha end)
    },
    pull_request: {
      number: (if $pr_number == "" then null else ($pr_number | tonumber) end),
      state: $pr_state,
      url: (if $pr_url == "" then null else $pr_url end),
      mergeable: (if $pr_mergeable == "" then null else $pr_mergeable end),
      merged_at: (if $pr_merged_at == "" then null else $pr_merged_at end)
    },
    phase: $phase,
    current_human_gate: $current_human_gate,
    ci: {
      status: $ci_status,
      checks: $checks
    },
    reported: {
      development_convergence: (if $reported_development_convergence == "" then null else $reported_development_convergence end),
      release_convergence: (if $reported_release_convergence == "" then null else $reported_release_convergence end)
    },
    preview: {
      state: $preview_state
    },
    production_verification: {
      state: $production_state
    },
    blocked_reason: $blocked_reason,
    blocked_reasons: $blocked_reasons,
    unverified_checks: $unverified_checks,
    conflicts: $conflicts,
    evidence: $evidence
  }'
