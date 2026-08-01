---
name: comment-out-non-performant-scalers
description: "Safely inventory and comment out active Dart named arguments shaped as fontSize: AppConstants.scaledFontSize(...) in a confirmed Flutter source tree. Use when project typography is already prescaled at the theme root and the user explicitly wants redundant widget-scoped font scalers disabled without bulk rewrites or unrelated edits."
---

# Comment Out Non-Performant Scalers

Disable only the exact widget-scoped scaler arguments the user authorizes. Treat root-level theme prescaling as a project-specific premise to verify, not as a universal Flutter rule.

## Guardrails

- Read every applicable `AGENTS.md` and repository instruction before inspecting or editing.
- Confirm the requested application and target directory. Never substitute Rider, Driver, Admin, or another sibling repository by inference.
- Modify only confirmed Flutter `.dart` source. Stop on React, TypeScript, or another framework mismatch.
- Preserve all existing work. Never run `git checkout`, `git restore`, `git reset`, destructive cleanup, or an automatic stash.
- Never use Python, Perl, shell rewrite loops, regex replacement tools, IDE replace-all, generated patch scripts, or other bulk rewrites for this task.
- Use targeted `apply_patch` edits after manually resolving every expression boundary.
- Exclude generated files and files marked `Generated Code`, `DO NOT EDIT`, or equivalent. Report matching generated code instead of editing it.
- Comment out the requested argument; do not silently delete it or change unrelated typography.

## 1. Preflight the Framework and Scope

Set task-specific paths only after resolving them from the user's request:

```bash
scaler_app_root="/absolute/path/to/confirmed-flutter-app"
scaler_target_root="$scaler_app_root/lib/src/pages"

test -f "$scaler_app_root/pubspec.yaml"
test -d "$scaler_target_root"
rg -n '^[[:space:]]*flutter:' "$scaler_app_root/pubspec.yaml"
find "$scaler_target_root" -type f -name '*.dart' -print | sed -n '1,20p'
```

Also inspect the repository entry point, `pubspec.yaml`, theme construction, and at least two representative pages. Verify that the root theme actually applies the intended typography scaling:

```bash
rg -n --glob '*.dart' 'scaledFontSize|textTheme|TextScaler|textScaleFactor|MediaQuery' \
  "$scaler_app_root/lib"
```

Stop without editing when any of these conditions is true:

- the requested root is not the exact repository the user named;
- `pubspec.yaml` or its Flutter declaration is absent;
- the target directory has no Dart files;
- the supposed root-level prescaling cannot be verified;
- applicable instructions prohibit the change.

For a stopped run, report the evidence, the likely path mismatch, and that zero source files changed. Do not run Flutter validation against a non-Flutter repository.

## 2. Preserve the Worktree Baseline

Before editing, record the existing state without changing it:

```bash
git -C "$scaler_app_root" status --short
git -C "$scaler_app_root" diff --check
```

Treat every pre-existing modification and untracked file as user work. Inspect at least two target occurrences and their surrounding `TextStyle` or `copyWith` construction before proposing edits. If explicit edit approval is not already present, present the exact file inventory and obtain it before continuing.

## 3. Build an Exact Occurrence Ledger

Use a strict standalone active-candidate scan first. Its line anchor excludes conventional `//` comments, but `rg` cannot prove Dart lexical state across block comments; classify every result manually. Exclude common generated outputs:

```bash
rg -n -U \
  --glob '*.dart' \
  --glob '!**/*.g.dart' \
  --glob '!**/*.freezed.dart' \
  --glob '!**/*.gr.dart' \
  --glob '!**/*.mocks.dart' \
  --glob '!**/generated/**' \
  '^[[:space:]]*fontSize[[:space:]]*:[[:space:]]*AppConstants[[:space:]]*\.[[:space:]]*scaledFontSize[[:space:]]*\(' \
  "$scaler_target_root"
```

Then run the exhaustive literal scan to catch inline, oddly formatted, and already-commented candidates:

```bash
rg -n -U \
  --glob '*.dart' \
  --glob '!**/*.g.dart' \
  --glob '!**/*.freezed.dart' \
  --glob '!**/*.gr.dart' \
  --glob '!**/*.mocks.dart' \
  --glob '!**/generated/**' \
  'fontSize[[:space:]]*:[[:space:]]*AppConstants[[:space:]]*\.[[:space:]]*scaledFontSize[[:space:]]*\(' \
  "$scaler_target_root"
```

Classify every exhaustive result as:

- active standalone multiline;
- active standalone one-line;
- active inline with adjacent arguments or code;
- already line-commented or block-commented;
- generated or otherwise excluded;
- a string/comment false positive.

Record the file, starting line, ending line, classification, and complete expression boundary. A broad `AppConstants.scaledFontSize` match without the `fontSize:` property shape is not a target.

If both scans produce zero candidates, stop and report zero matches and zero changes. If classification finds no active targets, stop and report the already-commented or false-positive inventory without editing. Do not broaden the requested signature merely to create work.

## 4. Resolve Boundaries Manually

Start at the opening parenthesis of `AppConstants.scaledFontSize(` with a balance of one. Inspect Dart syntax manually, incrementing for nested opening parentheses and decrementing for closing parentheses while ignoring parentheses inside strings and comments. The target ends when that invocation returns to zero; include the named argument's trailing comma when present.

Do not confuse the invocation's closing `)` with an outer `copyWith`, `TextStyle`, widget, collection, or callback boundary. Inspect enough surrounding lines to prove the boundary before patching.

Handle each form deliberately:

- **Standalone multiline:** prefix every line from `fontSize:` through the invocation's closing parenthesis and property comma with `// `. The property comma must be commented with the property.
- **Standalone one-line:** prefix the entire property line with `// ` only when no unrelated syntax follows on that line.
- **Inline:** wrap only the exact named argument, including its comma, in `/* ... */`. Do this only after confirming the expression contains no nested block comment and that adjacent arguments remain syntactically valid.
- **Already commented:** leave it unchanged and retain it in the occurrence ledger.

Example standalone patch:

```dart
style: Theme.of(context).textTheme.labelMedium?.copyWith(
  color: colorScheme.onSecondary,
  // fontSize: AppConstants.scaledFontSize(
  //   Theme.of(context).textTheme.labelMedium,
  //   uniformScale,
  //   fallback: 14,
  // ),
  fontWeight: FontWeight.w600,
),
```

Example inline patch:

```dart
style.copyWith(color: color, /* fontSize: AppConstants.scaledFontSize(style, scale), */ fontWeight: FontWeight.w600)
```

Apply small, reviewable patches one file or one tightly related group at a time. Re-open the changed context after each patch.

## 5. Handle Imports Conservatively

After commenting the arguments, determine whether the relevant `AppConstants` import still supplies any active symbol in that file. Keep it when any active usage remains.

Remove an import only when all of the following are proven:

- the import became unused solely because of this change;
- no other symbol from that import is referenced;
- removing it is inside the user's approved scope.

For strict comment-only authorization, leave the import unchanged and report any analyzer warning rather than expanding scope silently.

## 6. Prove Completeness and Diff Scope

Re-run the strict standalone active-candidate scan from step 3. It must return no active result; any remaining output must reconcile to a pre-existing block comment or recorded false positive. Re-run the exhaustive scan and reconcile every result with the original ledger: each original target must still be present as a line or block comment, and no new target may appear.

Review only scoped changes:

```bash
git -C "$scaler_app_root" diff --check
git -C "$scaler_app_root" diff -- "$scaler_target_root"
git -C "$scaler_app_root" status --short
```

Confirm that:

- every approved active target is commented;
- already-commented targets and non-target scaler calls are untouched;
- no outer delimiter or unrelated comma was commented;
- no generated file, unrelated source, lockfile, or dependency changed;
- all pre-existing work remains present.

## 7. Validate with the Repository's Toolchain

Read repository instructions and configured scripts before choosing commands. In a Flutter application, prefer the project's wrapper or workspace command when one exists. Otherwise, from the confirmed Flutter root, run:

```bash
dart format --output=none --set-exit-if-changed path/to/each/modified.dart
flutter analyze
flutter test
```

The format command above is check-only. Do not run a formatter that rewrites unrelated files. If the repository has no tests, the relevant suite is prohibitively external, or baseline failures exist, report that precisely instead of weakening or inventing validation.

For a non-Flutter framework mismatch, make no scaler edits and use no Flutter commands. If a separate, framework-appropriate change is later authorized, use that repository's actual scripts—for example, its configured lint and build commands—rather than this Flutter workflow.

Finish with the exact changed-file list, occurrence counts by classification, validation results, and any unresolved warning or excluded generated match.
