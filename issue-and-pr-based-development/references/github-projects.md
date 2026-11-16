# GitHub Projects (v2) with `gh`

Load when setting up a project, editing items from scripts, or bulk-populating a board. Placeholders as in [SKILL.md](../SKILL.md#placeholders).

## Commands

Requires the `project` token scope (`gh auth refresh -h github.com -s project`).

### Create and link

```bash
gh project create --owner <org> --title "<title>" --format json --jq .number
gh project link <n> --owner <org> --repo <org>/<repo>
```

### Fields

```bash
gh project field-create <n> --owner <org> --name Size \
  --data-type SINGLE_SELECT --single-select-options "XS,S,M,L"
gh project field-create <n> --owner <org> --name Component \
  --data-type SINGLE_SELECT --single-select-options "<a>,<b>,<c>"
```

The built-in Status field already exists. Rename or add its options (Backlog, Ready, In progress, In review, Done) in the project settings; `gh` cannot edit options of an existing field.

Enable the built-in workflows **Item closed** and **Pull request merged** to set Status to Done.

### IDs

Scripts use node IDs. Read them once and cache them:

```bash
gh project view <n> --owner <org> --format json --jq .id            # project ID
gh project field-list <n> --owner <org> --format json --limit 100 \
  --jq '.fields[] | {name, id, options: [.options[]? | {name, id}]}' # field and option IDs
```

### Items

```bash
# Issue in the owning repository, then onto the board
url=$(gh issue create -R <org>/<repo> --title "<title>" --body-file <body.md> --label <label>)
item=$(gh project item-add <n> --owner <org> --url "$url" --format json --jq .id)

# Draft item (checkpoint, finished milestone)
item=$(gh project item-create <n> --owner <org> --title "<title>" \
  --body "$(cat <body.md>)" --format json --jq .id)

# Set a single-select field by ID (stable for scripts)
gh project item-edit --project-id <project-id> --id "$item" \
  --field-id <field-id> --single-select-option-id <option-id>
```

Recent `gh` releases also accept names: `gh project item-edit <n> --owner <org> --url "$url" --field Status --value "In review"`. Check `gh project item-edit --help` before relying on it. A non-draft item takes one field per call.

### Queries

```bash
gh project item-list <n> --owner <org> --limit 200 --query "status:\"In progress\""
gh project item-list <n> --owner <org> --format json --limit 500 \
  --jq '.items[] | select(.content.url == "<issue-url>") | .id'
```

## Bulk population

### Spec file

One JSON file lists every item. Every key under `fields` names a single-select field; every value names one of its options. `body` is a path to a Markdown file.

Optional `artifacts` attach repository files to issues as [issue artifacts](issue-artifacts.md). Top-level `artifacts` go on every non-draft item; an item's own `artifacts` go on that item only. `type` is `plan`, `generic` or `embedded_html` (default `generic`). Draft items take no artifacts. Create link artifacts by hand.

```json
{
  "project": { "org": "<org>", "number": 1 },
  "artifacts": [
    { "file": "tasks/plan.md", "name": "Implementation plan", "type": "plan" }
  ],
  "items": [
    { "key": "M00", "draft": true, "title": "Milestone 0 (done)",
      "body": "items/M00.md", "fields": { "Status": "Done" } },
    { "key": "T01", "repo": "<org>/<repo>", "title": "<task title>",
      "body": "items/T01.md",
      "fields": { "Status": "Backlog", "Size": "S", "Component": "<a>" },
      "artifacts": [
        { "file": "briefs/T01.md", "name": "Agent brief", "type": "generic" }
      ] },
    { "key": "C01", "draft": true, "title": "Checkpoint: after T01-T03",
      "body": "items/C01.md", "fields": { "Status": "Backlog" } }
  ]
}
```

### Script skeleton

`populate.sh <spec.json>` is a dry run. `populate.sh <spec.json> --apply` writes. State lives next to the spec as `<spec>.state.json`. Needs `gh` and `jq`; artifacts also need `gh` 2.103.0 or later and `shasum`.

Re-run with `--apply` after changing an artifact's source file, such as `tasks/plan.md` after its index is filled with item links. Step 3 edits only artifacts whose file changed since the last run.

```bash
#!/usr/bin/env bash
set -euo pipefail
spec=$1; apply=${2:-}
state=${spec%.json}.state.json
[ -f "$state" ] || echo '{}' > "$state"
org=$(jq -r .project.org "$spec"); num=$(jq -r .project.number "$spec")
pid=$(gh project view "$num" --owner "$org" --format json --jq .id)
fields=$(gh project field-list "$num" --owner "$org" --format json --limit 100)

opt_id() { jq -r --arg f "$1" --arg v "$2" \
  '.fields[] | select(.name==$f) | .options[]? | select(.name==$v) | .id' <<<"$fields"; }
fld_id() { jq -r --arg f "$1" '.fields[] | select(.name==$f) | .id' <<<"$fields"; }
save()   { jq "$@" "$state" > "$state.tmp" && mv "$state.tmp" "$state"; }

# 1. Validate every field and option name before any write.
bad=0
while IFS=$'\t' read -r f v; do
  [ -n "$(opt_id "$f" "$v")" ] || { echo "unknown field/option: $f=$v" >&2; bad=1; }
done < <(jq -r '.items[].fields // {} | to_entries[] | "\(.key)\t\(.value)"' "$spec" | sort -u)
# Artifact rows: key, file, name, type. Draft items are excluded.
arts=$(jq -r '.artifacts as $all | .items[] | select((.draft // false) | not) | .key as $k
  | (($all // []) + (.artifacts // []))[] | [$k, .file, .name, (.type // "generic")] | @tsv' "$spec")
while IFS=$'\t' read -r k f _ t; do
  [ -n "$k" ] || continue
  [ -f "$f" ] || { echo "missing artifact file: $f ($k)" >&2; bad=1; }
  case $t in plan|generic|embedded_html) ;; *) echo "bad artifact type: $t ($k)" >&2; bad=1 ;; esac
done <<<"$arts"
if [ -n "$arts" ] && ! gh issue artifact --help >/dev/null 2>&1; then
  echo "gh lacks 'issue artifact' (needs 2.103.0 or later)" >&2; bad=1
fi
[ "$bad" = 0 ] || exit 1

# 2. Create items; skip finished keys; finish partial ones.
while IFS= read -r it <&3; do
  key=$(jq -r .key <<<"$it"); title=$(jq -r .title <<<"$it"); body=$(jq -r .body <<<"$it")
  if [ "$(jq -r --arg k "$key" '.[$k].done // false' "$state")" = true ]; then
    echo "skip $key"; continue
  fi
  if [ "$apply" != "--apply" ]; then echo "would create $key: $title"; continue; fi

  iid=$(jq -r --arg k "$key" '.[$k].item // empty' "$state")
  if [ -z "$iid" ]; then
    if [ "$(jq -r '.draft // false' <<<"$it")" = true ]; then
      url=""
      iid=$(gh project item-create "$num" --owner "$org" --title "$title" \
        --body "$(cat "$body")" --format json --jq .id)
    else
      url=$(gh issue create -R "$(jq -r .repo <<<"$it")" --title "$title" --body-file "$body")
      sleep 1
      iid=$(gh project item-add "$num" --owner "$org" --url "$url" --format json --jq .id)
    fi
    save --arg k "$key" --arg u "$url" --arg i "$iid" '.[$k] = {url: $u, item: $i, done: false}'
    sleep 1
  fi

  while IFS=$'\t' read -r f v; do
    gh project item-edit --project-id "$pid" --id "$iid" \
      --field-id "$(fld_id "$f")" --single-select-option-id "$(opt_id "$f" "$v")" </dev/null >/dev/null
    sleep 1
  done < <(jq -r '.fields // {} | to_entries[] | "\(.key)\t\(.value)"' <<<"$it")

  save --arg k "$key" '.[$k].done = true'
  echo "done $key"
done 3< <(jq -c '.items[]' "$spec")

# 3. Attach or sync issue artifacts. Edit only when the source file changed.
art_num() { gh issue artifact list "$1" --json number,name |
  jq -r --arg n "$2" 'map(select(.name == $n)) | max_by(.number) | .number // empty'; }

while IFS=$'\t' read -r key file name type <&4; do
  [ -n "$key" ] || continue
  url=$(jq -r --arg k "$key" '.[$k].url // empty' "$state")
  if [ -z "$url" ]; then echo "no issue yet for $key; skip artifact $name"; continue; fi
  sum=$(shasum -a 256 "$file" | cut -d' ' -f1)
  rec=$(jq -c --arg k "$key" --arg n "$name" '.[$k].artifacts[$n] // {}' "$state")
  if [ "$(jq -r '.sha // ""' <<<"$rec")" = "$sum" ]; then echo "skip artifact $key/$name"; continue; fi
  if [ "$apply" != "--apply" ]; then echo "would attach or sync $key/$name from $file"; continue; fi

  anum=$(jq -r '.number // empty' <<<"$rec")
  [ -n "$anum" ] || anum=$(art_num "$url" "$name")   # recover after a crash between create and save
  if [ -z "$anum" ]; then
    gh issue artifact create "$url" --body-file "$file" --name "$name" --type "$type" >/dev/null
    sleep 1
    anum=$(art_num "$url" "$name")
  else
    gh issue artifact edit "$url" "$anum" --body-file "$file" >/dev/null
  fi
  save --arg k "$key" --arg n "$name" --arg a "$anum" --arg s "$sum" \
    '.[$k].artifacts[$n] = {number: $a, sha: $s}'
  echo "artifact $key/$name -> #$anum"
  sleep 1
done 4<<<"$arts"
```

Rules:

- The state file is written after each create, before fields are set, so a crash never duplicates an issue.
- Never delete the state file to "start fresh". If it is lost, rebuild it from `gh project item-list` before re-running.
- Commit the spec and the item bodies. Do not commit the state file if the team treats it as local.
- Artifacts are looked up by name before creation, so a crash between create and save does not duplicate one. Keep artifact names unique per issue.

## Other trackers

| Concept | GitHub Projects | GitLab | Jira | Linear |
| --- | --- | --- | --- | --- |
| Status flow | Status single-select | Board lists on scoped labels (`status::ready`) | Workflow statuses and transitions | Workflow states |
| Size and custom fields | Single-select fields | Scoped labels or weight | Story points, custom fields | Estimate, labels |
| Close on merge | `Closes #<i>` in PR body | `Closes #<i>` in MR description | Issue key in branch, commits and PR with the development integration; transition by automation | `Fixes <ID>` in PR description |
| CLI | `gh` | `glab` | Jira REST API or a CLI the team uses | Linear API |

Stacked pull requests and issue artifacts are GitHub features. On other trackers, merge dependent changes one at a time ([fallback](stacked-prs.md#fallback-without-stacks)) and link the plan from the issue body.

Keep the same contracts on any tracker: one issue per task, status moved by the same roles, PR closes the issue, evidence before close.
