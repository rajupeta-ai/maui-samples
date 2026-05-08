# .NET MAUI 11 Samples (`11.0/`)

This directory holds samples that target the **.NET MAUI 11** preview SDK. It
is an **active, wired** module of the repository.

- Top-level solution: [`Samples-11.0.sln`](./Samples-11.0.sln) — enumerates
  every `11.0/**/*.csproj` so the module cannot be silently dropped.
- SDK pin: [`global.json`](./global.json) — pins the .NET 11 preview SDK.
- Versions: [`Directory.Build.props`](./Directory.Build.props) — pins
  `MauiVersion` / `DotNetVersion` for the preview.
- CI coverage: every push and PR runs
  [`.github/workflows/verify-versioned-modules.yml`](../.github/workflows/verify-versioned-modules.yml),
  which fails if a `11.0/**/*.csproj` is missing from `Samples-11.0.sln`. The
  full matrix build at
  [`.github/workflows/build-all.yml`](../.github/workflows/build-all.yml) and
  PR build at
  [`.github/workflows/build-pr.yml`](../.github/workflows/build-pr.yml)
  pick up every project in this folder via recursive csproj discovery.

## Audit (ticket TICKET-001)

Source findings flagged this module as `unwired` and `dead_code`. The audit
below resolves both findings: every project here is intentional, every file
is accounted for, and CI references the module explicitly.

### Sample projects

| Sample | Project | Solution |
|---|---|---|
| Long-press gesture | [`UserInterface/Gestures/LongPressGesture/LongPressGesture/LongPressGesture.csproj`](./UserInterface/Gestures/LongPressGesture/LongPressGesture/LongPressGesture.csproj) | [`LongPressGesture.sln`](./UserInterface/Gestures/LongPressGesture/LongPressGesture.sln) + [`Samples-11.0.sln`](./Samples-11.0.sln) |
| Invalidate style demo | [`UserInterface/Styles/InvalidateStyleDemo/InvalidateStyleDemo.csproj`](./UserInterface/Styles/InvalidateStyleDemo/InvalidateStyleDemo.csproj) | [`Samples-11.0.sln`](./Samples-11.0.sln) |
| Map pin clustering | [`UserInterface/Views/Map/MapClustering/MapClustering.csproj`](./UserInterface/Views/Map/MapClustering/MapClustering.csproj) | [`MapClustering.sln`](./UserInterface/Views/Map/MapClustering.sln) + [`Samples-11.0.sln`](./Samples-11.0.sln) |

Each sample is referenced by an upstream PR in the project history (see
`git log --grep="MAUI 11"`).

### File accounting (95 files)

The 95 files reported in static analysis decompose as:

| Bucket | Count | Status |
|---|---:|---|
| Module-level config (`Directory.Build.props`, `global.json`, `Samples-11.0.sln`) | 3 | Active |
| Per-sample solution files (`*.sln`) | 2 | Active (LongPressGesture, MapClustering) |
| `*.csproj` project files | 3 | Active — all enumerated in `Samples-11.0.sln` |
| `*.cs` / `*.xaml` / `*.xaml.cs` source | 39 | Active sample sources |
| Platform manifests / Info.plist / Entitlements / launchSettings.json | 14 | Active platform config |
| Embedded resources (fonts, images, splash, app icon, styles) | 30 | Active sample resources |
| Per-sample `README.md` | 3 | Active sample docs |
| Module README (this file) | 1 | Audit doc |

Total: **95 files**, every one of which belongs to a wired sample project.

### Dead-code disposition

- **No files were removed.** All 95 are part of an active sample.
- **No files were archived.** No `archived/` or `deprecated/` subdir exists or
  was added — there are no abandoned artifacts in this module.
- The `dead_code-11.0-module-directory` and `unwired-11.0` findings are
  resolved by wiring the module into `Samples-11.0.sln` and into the dedicated
  CI workflow listed above.

## Adding a new 11.0 sample

When you add a new sample under `11.0/`:

1. Create the `.csproj` under an appropriately named folder (mirror the layout
   used by 9.0/10.0).
2. Add a `Project(...)` line for it to [`Samples-11.0.sln`](./Samples-11.0.sln)
   *and* a matching configuration block in `GlobalSection(ProjectConfigurationPlatforms)`.
3. Run [`eng/Verify-VersionedModules.ps1`](../eng/Verify-VersionedModules.ps1)
   locally — it will fail loudly if the new csproj is missing from the sln.
4. Update the **Sample projects** table above.
