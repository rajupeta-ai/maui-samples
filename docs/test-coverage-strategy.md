# Test Coverage Strategy

This document defines what "tested" means for every top-level module in the
`maui-samples` repository. It exists so contributors and reviewers can answer
two questions quickly:

1. **Which modules require executable tests, and which do not?**
2. **How is each module verified in CI?**

The repository is a collection of .NET MAUI **sample applications**, **upgrade
guidance**, and **engineering tooling**. Coverage expectations therefore differ
by module type, not by uniform line-coverage thresholds.

## Module classification

Every top-level directory falls into one of three categories:

| Category | Coverage expectation |
| --- | --- |
| **Sample code** | Must build cleanly on every supported OS in CI. UI smoke tests are encouraged where Appium harnesses already exist. |
| **Documentation / assets** | No executable tests. Verified by review and Markdown / link checks if/when added. |
| **Tooling / CI configuration** | No unit tests. Verified by the workflow execution itself plus optional `actionlint` linting. |

## Per-module coverage matrix

The seven top-level modules flagged by the analyzer are addressed below.

### `9.0/` — Sample code (versioned)

- **Category:** Sample code.
- **Tested by:** `.github/workflows/build-all.yml` and `.github/workflows/build-pr.yml` —
  both workflows discover every `*.csproj` recursively under `9.0/` and run
  `dotnet build` on Windows and macOS. Build success is the contract.
- **UI tests:** `9.0/UITesting/BasicAppiumNunitSample/UITests.{Android,iOS,Windows,macOS}`
  and `9.0/UITesting/BrowserStackAppiumMaui/BasicAppiumNunitSample/UITests.{...}`
  are executable Appium/NUnit projects. They are built in CI; running them
  requires device/simulator infrastructure and is a manual / on-demand activity
  documented in each sample's `README.md`.
- **Coverage gate:** A PR that breaks any `9.0/` `*.csproj` build fails CI.

### `10.0/` — Sample code (versioned)

- **Category:** Sample code.
- **Tested by:** `.github/workflows/build-all.yml` and `.github/workflows/build-pr.yml`
  (same matrix as `9.0/`).
- **UI tests:** `10.0/UITesting/BasicAppiumNunitSample/UITests.{Android,iOS,Windows,macOS}`
  and `10.0/UITesting/BrowserStackAppiumMaui/BasicAppiumNunitSample/UITests.{...}`.
  These are built in CI; physical execution requires device infrastructure.
- **Coverage gate:** A PR that breaks any `10.0/` `*.csproj` build fails CI.

### `11.0/` — Sample code (versioned, in-progress)

- **Category:** Sample code.
- **Tested by:** `.github/workflows/build-all.yml` and `.github/workflows/build-pr.yml`.
  The workflow's `setup-dotnet` step explicitly installs the `11.0.x` SDK
  (`dotnet-quality: preview`), so any `*.csproj` added under `11.0/` is built
  automatically.
- **UI tests:** None yet — `11.0/` currently contains only `UserInterface/`
  samples. When UITesting samples are ported to `11.0/`, they should follow the
  same pattern as the `9.0/` and `10.0/` UITesting projects and be picked up by
  the same workflow.
- **Coverage gate:** A PR that breaks any `11.0/` `*.csproj` build fails CI.

### `.github/` — Tooling / CI configuration

- **Category:** Tooling.
- **Tested by:** GitHub itself. Workflow YAML is parsed and validated by the
  Actions runner on every push; a malformed workflow fails to start. Optional
  static linting via [`actionlint`](https://github.com/rhysd/actionlint) can be
  added locally (`actionlint .github/workflows/*.yml`) but is not required for
  merge.
- **No executable tests required because** the contents are declarative
  workflow files and Markdown prompts; they have no runtime behavior to assert
  beyond GitHub's own schema validation.

### `Upgrading/` — Documentation

- **Category:** Documentation.
- **Tested by:** Code review.
- **No executable tests required because** this directory holds long-form
  guidance (`README.md`) and a small reference renderer (`CustomRenderer/`)
  that documents an upgrade path. The `CustomRenderer` `*.csproj`, if present,
  is still picked up by `build-all.yml` and `build-pr.yml`, so any code there
  is verified by the standard build matrix; the prose itself is verified by
  human review.

### `Images/` — Static assets

- **Category:** Documentation / assets.
- **Tested by:** N/A.
- **No executable tests required because** this directory contains binary
  image assets (e.g. `campus.jpg`) referenced from Markdown documentation.
  Asset integrity is verified implicitly by the documentation it backs.

### `eng/` — Engineering configuration

- **Category:** Tooling.
- **Tested by:** The CI workflows that consume it. `build-all.yml` and
  `build-pr.yml` read `eng/excluded_projects_macos.txt` and
  `eng/excluded_projects_windows.txt` on every run; a malformed exclusion
  file would cause excluded projects to build (or excluded ones to be skipped
  incorrectly) and would surface as a build failure or unexpected build
  inclusion in the workflow's job summary.
- **No executable unit tests required because** the directory contains plain
  text exclusion lists. Their semantics are observed end-to-end by the build
  workflow on every PR.

## CI matrix summary

| Module | OS matrix (CI) | Verification mechanism |
| --- | --- | --- |
| `9.0/` | windows-latest, macos-26 | `dotnet build` on every `*.csproj` |
| `10.0/` | windows-latest, macos-26 | `dotnet build` on every `*.csproj` |
| `11.0/` | windows-latest, macos-26 | `dotnet build` on every `*.csproj` |
| `.github/` | n/a | GitHub Actions schema validation |
| `Upgrading/` | windows-latest, macos-26 (if `*.csproj` present) | Build via the same workflow; prose by review |
| `Images/` | n/a | Review only |
| `eng/` | n/a | Consumed by `build-all.yml` and `build-pr.yml` at run time |

## Adding a new module

When you add a new top-level directory:

1. Decide the category (sample code / documentation / tooling).
2. Add an entry to this document with a one-line statement of how it is
   tested **or** why executable tests are not required.
3. If the module contains buildable code, confirm it is picked up by
   `.github/workflows/build-all.yml` (the discovery loop is recursive, so
   new `*.csproj` files are normally included automatically).
4. If the module needs to be excluded on a specific OS, add it to
   `eng/excluded_projects_macos.txt` or `eng/excluded_projects_windows.txt`
   with a comment explaining why.

## Running tests locally

- **Build a single sample:** `dotnet build path/to/Sample.csproj`
- **Build everything (mirrors CI):** iterate `*.csproj` under `9.0/`, `10.0/`,
  `11.0/` and run `dotnet build`. The CI script in
  `.github/workflows/build-all.yml` is the source of truth.
- **Run UI tests (manual):** see the `README.md` next to each
  `UITesting/...Sample` directory; they require Appium and a configured
  device/simulator.

## Source findings addressed

This strategy responds to the following analyzer findings:

- `test_quality-no-tests-9.0`
- `test_quality-no-tests-10.0`
- `test_quality-no-tests-11.0`
- `test_quality-no-tests-.github`
- `test_quality-no-tests-Upgrading`
- `test_quality-no-tests-Images`
- `test_quality-no-tests-eng`

Each "no tests" finding was a false positive in the sense that the analyzer
expected a uniform unit-test suite per module. This document records the
intentional, module-specific verification policy.
