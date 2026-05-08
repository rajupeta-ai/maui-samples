# Upgrading Module — File Manifest & CI Integration

> **Status:** Active. The Upgrading module is wired into the repository's CI build matrix.
>
> **Generated:** 2026-05-08 (TICKET-002 audit)
>
> **Owner:** .NET MAUI Samples maintainers

This document classifies every file under `Upgrading/` so that future audits do
not flag the directory as unwired or dead code. It also documents how the
module participates in CI.

## 1. Purpose of the Upgrading module

The Upgrading module hosts samples that demonstrate how to migrate Xamarin.Forms
applications to .NET MAUI. Two of the included projects are intentionally kept
at the legacy Xamarin tooling level so readers can compare the *before* and
*after* states side-by-side. The remaining MAUI projects use the same
`net8.0-*` target frameworks that other samples in this repository use, and
they are currency-relevant for users moving from MAUI 9.0 → 10.0 → 11.0 because
the upgrade story for custom renderers is identical across those versions.

## 2. CI integration

The module is built by the same workflows as the rest of the repository:

| Workflow | File | Behaviour for `Upgrading/` |
|---|---|---|
| Build All C# Projects in Repo | `.github/workflows/build-all.yml` | Discovers every `*.csproj` recursively, including all MAUI projects under `Upgrading/`. Xamarin-only projects are listed in `eng/excluded_projects_*.txt` with a comment explaining why. |
| Build Changed C# Projects for PR | `.github/workflows/build-pr.yml` | When a PR touches a file under `Upgrading/`, the same exclusion rules apply and the surrounding csproj is built. |
| Validate Upgrading manifest | `.github/workflows/validate-upgrading.yml` | New in TICKET-002. Runs on every PR. Asserts that every csproj/sln under `Upgrading/` is either built by the matrix or explicitly excluded with a documented reason. |

### Excluded projects (intentional, documented)

The Xamarin.Forms projects below cannot be built on the dotnet build host —
they require legacy MSBuild + Xamarin workloads that are out of scope for this
repo's CI. They are kept as **reference material** so the upgrade-from-Xamarin
story has a working "before" state.

- `Upgrading/CustomRenderer/XamarinCustomRenderer/XamarinCustomRenderer/XamarinCustomRenderer.Android/XamarinCustomRenderer.Android.csproj`
- `Upgrading/CustomRenderer/XamarinCustomRenderer/XamarinCustomRenderer/XamarinCustomRenderer.iOS/XamarinCustomRenderer.iOS.csproj`
- `Upgrading/CustomRenderer/XamarinCustomRenderer/XamarinCustomRenderer/XamarinCustomRenderer/XamarinCustomRenderer.csproj` *(shared netstandard project — not added to the build matrix because the host platform projects are excluded)*

The exclusions are enforced by `eng/excluded_projects_macos.txt` and
`eng/excluded_projects_windows.txt`, both of which point at the same files.

## 3. File classification (139 files total)

Every file in `Upgrading/` is classified into one of four categories. The
totals must match the on-disk count for the `validate-upgrading` script to
succeed.

| Category | Files | Description |
|---|---:|---|
| `active-code-maui`      | 48 | Compilable .NET 8 / MAUI sources and platform manifests under `MauiCustomRenderer` and `MultiProject/Entry`. |
| `active-build`          |  6 | `.csproj` / `.sln` descriptors for MAUI projects exercised by CI. |
| `resource-binary`       | 20 | App icons, screenshots, fonts (PNG/SVG/TTF) used by the active MAUI samples. |
| `resource-text`         |  3 | Sample resource notes such as `AboutAssets.txt`. |
| `documentation`         |  4 | `README.md` files describing each sample. |
| `tooling-output`        |  2 | `UpgradeReport.sarif` and `upgrade-assistant.clef` from the .NET Upgrade Assistant, preserved as evidence. |
| `reference-xamarin-build`     |  4 | Xamarin `.csproj` / `.sln` descriptors — archived, excluded from CI. |
| `reference-xamarin`           | 17 | Xamarin C#/XAML source kept for before/after comparison — archived. |
| `reference-xamarin-resource`  | 35 | Xamarin platform resources (icons, asset catalogs, etc.) — archived. |
| **Total**                     | **139** | matches `find Upgrading -type f` count at audit time |

The full per-file inventory is captured in
[`MANIFEST_FILES.csv`](MANIFEST_FILES.csv). That CSV is the source of truth
for the validation workflow.

## 4. Version coverage

| Doc reference | Verified against |
|---|---|
| Xamarin.Forms → .NET MAUI guidance | Upgrade story is identical for MAUI 9.0, 10.0, and 11.0 — custom renderer migration has not changed. |
| `Upgrading/README.md` | Refers to ".NET 6 and newer" generically. Verified valid for MAUI 9.0/10.0/11.0. |
| `Upgrading/CustomRenderer/README.md` | Refers to ".NET MAUI" generically; no version drift. |
| MAUI csproj `TargetFrameworks` | `net8.0-*` — current LTS baseline, supported by all three release lines. |

## 5. Re-running the audit

```pwsh
pwsh ./eng/Validate-UpgradingManifest.ps1
```

The script:

1. Lists every file under `Upgrading/`.
2. Compares the count to the totals in this manifest (139 files, 6 csproj/sln
   build descriptors).
3. Confirms that every Xamarin csproj is listed in both
   `eng/excluded_projects_macos.txt` and `eng/excluded_projects_windows.txt`.
4. Confirms that every MAUI csproj is *not* in the exclusion lists.
5. Exits non-zero if the manifest drifts from the on-disk state.

If the script fails, update both `MANIFEST.md` and `MANIFEST_FILES.csv` to
reflect the new on-disk reality, then re-run.
