# BusinessCentral.AL.Language.Tests

> An executable specification proving AL language features work correctly in BC Cloud (SaaS).

[![AL Language Tests](https://github.com/StefanMaron/BusinessCentral.AL.Language.Tests/actions/workflows/ci.yml/badge.svg)](https://github.com/StefanMaron/BusinessCentral.AL.Language.Tests/actions/workflows/ci.yml)

## Why This Exists

AL behaves differently on BC Cloud than in local runtimes or the AL Runner. This repo answers one question per test: **does this AL language feature actually work in a BC Cloud tenant?**

Every test is a behavioral contract: a documented AL feature + the actual BC runtime + a passing assertion. If it passes, the feature is cloud-compatible. If it fails, the contract is broken.

**Primary goal:** Cloud compatibility. File operations, .NET interop, and `HttpClient` are out of scope for positive tests — each gets exactly one negative test confirming it throws in Cloud.

**Secondary goal:** Full coverage of the in-scope AL language surface.

**Runner gap path:** If `BusinessCentral.AL.Runner` handles something incorrectly, write the test here to prove the correct Cloud behavior. Once the runner is fixed, the test is promoted to its regression suite.

## Quick Start

**CI:** Push to any branch. GitHub Actions runs the full matrix over BC 27.5 and 28.1 automatically — no self-hosted runner required.

**Local development** (requires a bc-linux Docker container at `localhost`):

```bash
cd tests/al-language
al-compile && bc-publish && python3 run-bc-tests.py
```

Default local dev credentials: `BCRUNNER` / `Admin123!`

See [StefanMaron/MsDyn365Bc.On.Linux](https://github.com/StefanMaron/MsDyn365Bc.On.Linux) for container setup.

## Test Areas

149 test files, 128+ codeunits (ID range 60000–60999), target `Cloud`, runtime 16.1 (BC 27+).

| Area | Description |
|------|-------------|
| `record/` | Record CRUD, filters, locking, keys, insert/modify/delete contracts |
| `recordref/` | Dynamic record access via RecordRef — field iteration, open/close, filters |
| `fieldref/` | FieldRef read/write, type coercion, option values |
| `codeunit/` | Codeunit instantiation, interface dispatch, run behavior |
| `collections/` | List, Dictionary, Queue, Stack — all collection types |
| `error-handling/` | Error/Commit semantics, nested try-functions, confirm behavior |
| `handlers/` | Message, Confirm, StrMenu, and page handler contracts |
| `json/` | JsonObject, JsonArray, JsonToken — parse, write, path traversal |
| `out-of-scope/` | One negative test each for File, .NET, HttpClient — confirms Cloud throws |
| `session/` | Session variables, UserSecurityId, Company behavior |
| `streams/` | InStream/OutStream, TempBlob, BLOB field contracts |
| `text/` | String operations, formatting, regex, encoding |
| `types/` | Primitive type behavior — Integer, Decimal, Date, Time, DateTime, Boolean |
| `xml/` | XmlDocument, XmlNode, namespace handling, serialization |
| `_fixtures/` | Shared fixture library (see below) |

## Fixture Library

All tests share a single fixture library — no per-test table definitions. The library lives in `_fixtures/` and includes 10 tables, 2 enums, 1 interface, 2 pages, 1 report, and 2 event codeunits.

Tests reference fixtures directly; they never define their own schema objects. This keeps test files focused on a single behavioral claim.

Full fixture reference: [PLAN.md](tests/al-language/PLAN.md)

## Contributing

### Writing a Test

Each test file makes exactly one behavioral claim. A test must **fail** if the method always returns a default value — assertions must be meaningful.

Structure:
1. One codeunit per file, named for the feature under test
2. A doc-link comment at the top pointing to the relevant BC documentation page
3. Procedures named as `Subject_Action_Context_Outcome`, e.g. `Record_Insert_DuplicateKey_Throws`
4. No local table definitions — use `_fixtures/` only

### Naming Convention

```
Record_Insert_DuplicateKey_Throws
Record_FindFirst_EmptyTable_ReturnsFalse
JsonObject_Get_MissingKey_Throws
```

Pattern: `Subject_Action_Condition_Outcome`. When there is no special condition, omit it: `Record_Insert_AssignsSystemId`.

### Runner Gap Contribution Path

1. Identify behavior the AL Runner gets wrong
2. Write a test here that passes against BC Cloud and documents the correct behavior
3. Open a PR referencing the runner issue
4. Once [BusinessCentral.AL.Runner](https://github.com/StefanMaron/BusinessCentral.AL.Runner) is fixed, the test is promoted to its regression suite

### References

- [PLAN.md](tests/al-language/PLAN.md) — design doc, naming conventions, fixture reference, build workflow
- [CLAUDE.md](CLAUDE.md) — agent and contributor instructions

## Related Repos

- [StefanMaron/MsDyn365Bc.On.Linux](https://github.com/StefanMaron/MsDyn365Bc.On.Linux) — BC runtime on Linux; powers local dev and CI
- [StefanMaron/BusinessCentral.AL.Runner](https://github.com/StefanMaron/BusinessCentral.AL.Runner) — AL Runner; tests here feed its regression suite
