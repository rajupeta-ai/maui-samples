# Contributing to .NET MAUI Samples

Thanks for your interest in contributing! This repository is a curated set of
.NET MAUI sample applications and upgrade guidance. Most contributions take
the form of new samples, fixes to existing samples, or updates to the
upgrade documentation.

## Getting started

1. Fork the repository and create a feature branch from `main`.
2. Install the .NET SDK versions you intend to target. The CI matrix builds
   against the `9.0.x`, `10.0.x`, and `11.0.x` SDKs (preview channel) — see
   [`.github/workflows/build-all.yml`](.github/workflows/build-all.yml).
3. Install the .NET MAUI workload: `dotnet workload install maui`.
4. Build the sample(s) you touched with `dotnet build path/to/Sample.csproj`.

## Repository layout

| Directory | Purpose |
| --- | --- |
| `9.0/`, `10.0/`, `11.0/` | Sample applications, grouped by .NET version. |
| `.github/` | CI workflows, agent prompts, and issue templates. |
| `Upgrading/` | Long-form upgrade guidance and helper renderers. |
| `Images/` | Image assets referenced from Markdown documentation. |
| `eng/` | Engineering configuration consumed by CI (e.g. exclusion lists). |

## Testing

This repository does not have a single unit-test suite — it is a collection of
sample applications. Each top-level module has a defined verification
mechanism, documented in [`docs/test-coverage-strategy.md`](docs/test-coverage-strategy.md).

In short:

- **Sample modules (`9.0/`, `10.0/`, `11.0/`)** are tested by `dotnet build`
  in CI on Windows and macOS via `.github/workflows/build-all.yml` and
  `.github/workflows/build-pr.yml`. Every `*.csproj` is built; a build
  failure blocks the PR.
- **UI tests** under `9.0/UITesting/...` and `10.0/UITesting/...` are
  Appium/NUnit projects. They are built in CI; running them requires a
  configured device or simulator and is documented in each sample's
  `README.md`.
- **`.github/`, `Upgrading/`, `Images/`, and `eng/`** are intentionally not
  covered by executable tests. The reason for each is recorded in the
  test-coverage strategy document.

### Before opening a pull request

- Build the sample(s) you changed: `dotnet build`.
- If you excluded a project on a specific OS, add it to
  `eng/excluded_projects_macos.txt` or `eng/excluded_projects_windows.txt`
  with a one-line comment explaining why.
- If you add a new top-level directory, update
  [`docs/test-coverage-strategy.md`](docs/test-coverage-strategy.md) with its
  category and verification mechanism.

### Adding a new sample

1. Place the sample under the appropriate version directory (`9.0/`, `10.0/`,
   or `11.0/`).
2. Include a `README.md` describing what the sample demonstrates and how to
   run it.
3. Confirm `dotnet build path/to/YourSample.csproj` succeeds locally.
4. The CI workflows discover `*.csproj` files recursively, so no workflow
   change is normally required.

## Code style

- Follow the existing folder structure and naming conventions of nearby
  samples.
- Keep samples self-contained — avoid cross-sample dependencies.
- Prefer clarity over cleverness; these projects are teaching tools.

## Code of Conduct

This project follows the [Microsoft Open Source Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you agree to abide by its terms.

## Security

To report a security issue, follow the instructions in [SECURITY.md](SECURITY.md).
Do not open a public issue for security reports.
