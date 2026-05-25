# CI Update: preprocessor_symbols matrix + al_tool_version auto-derive

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `.github/workflows/ci.yml` to use the new `preprocessor_symbols` and auto-derived `al_tool_version` inputs added to the bc-linux reusable workflow.

**Architecture:** The `bc-test-from-source.yml` reusable workflow in `StefanMaron/MsDyn365Bc.On.Linux` now auto-derives `al_tool_version` and `runtime_version` from `bc_version`, and accepts `preprocessor_symbols` to pass `/preprocessorsymbols` to the AL compiler. The CI matrix must switch from a simple list to an `include:` matrix so each BC version leg can carry its own `preprocessor_symbols` value.

**Tech Stack:** GitHub Actions YAML; bc-linux reusable workflow (`StefanMaron/MsDyn365Bc.On.Linux/.github/workflows/bc-test-from-source.yml@master`)

---

### Task 1: Update `.github/workflows/ci.yml`

**Files:**
- Modify: `.github/workflows/ci.yml`

There are no unit tests for GitHub Actions YAML. Verification is by reading the diff carefully and confirming the matrix structure is syntactically correct.

- [ ] **Step 1: Update the matrix in the `prepare` job**

The `prepare` job currently emits `{"bc_version":["27.5","28.1"]}` which is a simple list. Switch it to an `include:` matrix so each leg carries `preprocessor_symbols`.

Replace the `prepare` job's `set` step `run` block:

```bash
OVERRIDE='${{ github.event.inputs.bc_version }}'
if [ -n "$OVERRIDE" ]; then
  # For an ad-hoc override, derive the major and build a minimal include entry.
  MAJOR=$(echo "$OVERRIDE" | cut -d. -f1)
  # Collect all symbols up to this major (e.g. 28 → BC27PLUS,BC28PLUS).
  SYMS=""
  for v in 27 28; do
    [ "$v" -le "$MAJOR" ] || break
    SYMS="${SYMS:+$SYMS,}BC${v}PLUS"
  done
  JSON=$(python3 -c "import json; print(json.dumps({'include':[{'bc_version':'$OVERRIDE','preprocessor_symbols':'$SYMS'}]}))")
else
  JSON='{"include":[{"bc_version":"27.5","preprocessor_symbols":"BC27PLUS"},{"bc_version":"28.1","preprocessor_symbols":"BC27PLUS,BC28PLUS"}]}'
fi
echo "matrix=$JSON" >> "$GITHUB_OUTPUT"
```

- [ ] **Step 2: Update the `test` job matrix reference and inputs**

In the `test` job:
- Change `matrix: ${{ fromJson(needs.prepare.outputs.matrix) }}` — no change needed, this still works with `include:` matrices
- Remove `al_tool_version: "16.2.28.57946"` — auto-derive handles it
- Add `preprocessor_symbols: ${{ matrix.preprocessor_symbols }}`
- Remove the stale comment about "runtime 16.1"

The updated `with:` block:

```yaml
with:
  bc_version:           ${{ matrix.bc_version }}
  bc_country:           "w1"
  app_dirs:             ""
  test_app_dirs:        "tests/al-language"
  codeunit_range:       "60000..60999"
  preprocessor_symbols: ${{ matrix.preprocessor_symbols }}
```

- [ ] **Step 3: Update the header comment**

Replace the "Adding a new BC version" comment at the top of the file to reflect the new approach (no manual `al_tool_version` — just append an `include:` entry with `preprocessor_symbols`):

```yaml
# Adding a new BC version:
#   1. In the prepare job, add an include entry to the else-branch JSON:
#      {"bc_version":"29.0","preprocessor_symbols":"BC27PLUS,BC28PLUS,BC29PLUS"}
#   2. If new API/keywords only exist from that version, guard tests with
#      #if BC29PLUS and define the symbol in the matrix include above.
#   al_tool_version and runtime_version are auto-derived from bc_version
#   by the bc-linux reusable workflow — no manual entry needed.
```

- [ ] **Step 4: Verify the YAML structure**

Read the final file and confirm:
- The `prepare` job emits an `include:`-based JSON (not a flat `bc_version` list)
- `preprocessor_symbols` appears in `with:` using `${{ matrix.preprocessor_symbols }}`
- `al_tool_version` does NOT appear in `with:`
- No reference to "runtime 16.1" remains in comments

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: use preprocessor_symbols matrix, remove al_tool_version pin

bc-linux reusable workflow now auto-derives al_tool_version and
runtime_version from bc_version. Switch to include-based matrix
so each BC version leg carries its own preprocessor_symbols."
```
