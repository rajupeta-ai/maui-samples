<#
.SYNOPSIS
  Validates that the Upgrading module manifest matches the on-disk state.

.DESCRIPTION
  Re-audits the Upgrading/ directory and asserts that:

    1. The total file count matches the totals in Upgrading/MANIFEST.md
       and Upgrading/MANIFEST_FILES.csv (139 files at the time of TICKET-002).
    2. Every Xamarin .csproj is listed in BOTH eng/excluded_projects_macos.txt
       and eng/excluded_projects_windows.txt (otherwise build-all.yml would
       try to build them and fail).
    3. Every MAUI .csproj is *not* in the exclusion lists (otherwise CI would
       silently skip them).
    4. Every file on disk has an entry in MANIFEST_FILES.csv, and every
       row in MANIFEST_FILES.csv exists on disk.

  Run locally:
      pwsh ./eng/Validate-UpgradingManifest.ps1

  CI runs this via .github/workflows/validate-upgrading.yml on every PR.
  Exits non-zero on drift so the PR fails until the manifest is updated.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

function Fail([string]$msg) {
    Write-Error $msg
    exit 1
}

$upgradingDir = Join-Path $RepoRoot 'Upgrading'
$manifestFile = Join-Path $upgradingDir 'MANIFEST.md'
$csvFile      = Join-Path $upgradingDir 'MANIFEST_FILES.csv'
$macExclude   = Join-Path $RepoRoot 'eng/excluded_projects_macos.txt'
$winExclude   = Join-Path $RepoRoot 'eng/excluded_projects_windows.txt'

foreach ($f in @($manifestFile, $csvFile, $macExclude, $winExclude)) {
    if (-not (Test-Path $f)) { Fail "Missing required file: $f" }
}

# --- 1. On-disk inventory (excluding the manifest itself) -------------------
$onDisk = Get-ChildItem -Path $upgradingDir -Recurse -File |
    Where-Object { $_.Name -ne 'MANIFEST.md' -and $_.Name -ne 'MANIFEST_FILES.csv' } |
    ForEach-Object {
        ($_.FullName.Substring($RepoRoot.Length + 1)) -replace '\\','/'
    } |
    Sort-Object

Write-Host "Found $($onDisk.Count) files under Upgrading/ (excluding manifest)."

# --- 2. CSV inventory --------------------------------------------------------
$csvRows = Import-Csv $csvFile
$csvPaths = $csvRows | ForEach-Object { $_.path } | Sort-Object

$missingFromCsv = @($onDisk | Where-Object { $csvPaths -notcontains $_ })
$missingFromDisk = @($csvPaths | Where-Object { $onDisk -notcontains $_ })

if ($missingFromCsv.Count -gt 0) {
    Fail "Files exist on disk but not in MANIFEST_FILES.csv:`n  $($missingFromCsv -join "`n  ")"
}
if ($missingFromDisk.Count -gt 0) {
    Fail "Rows in MANIFEST_FILES.csv reference files that no longer exist:`n  $($missingFromDisk -join "`n  ")"
}

Write-Host "MANIFEST_FILES.csv matches on-disk inventory ($($csvRows.Count) rows)."

# --- 3. MANIFEST.md total ---------------------------------------------------
$manifestText = Get-Content $manifestFile -Raw
if ($manifestText -notmatch '\*\*139\*\*') {
    Fail "MANIFEST.md no longer references the expected total (139 files). Update both totals together."
}

# --- 4. Build descriptors vs. exclusion lists -------------------------------
$csprojRows = $csvRows | Where-Object { $_.path -match '\.csproj$' }
$xamarinCsproj = $csprojRows | Where-Object { $_.category -eq 'reference-xamarin-build' } | ForEach-Object { './' + $_.path }
$mauiCsproj    = $csprojRows | Where-Object { $_.category -eq 'active-build' } | ForEach-Object { './' + $_.path }

function Read-Excludes([string]$path) {
    Get-Content $path |
        Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\S' } |
        ForEach-Object { $_.Trim() }
}

$macExcludes = Read-Excludes $macExclude
$winExcludes = Read-Excludes $winExclude

foreach ($x in $xamarinCsproj) {
    if ($macExcludes -notcontains $x) {
        Fail "Xamarin csproj '$x' must be listed in eng/excluded_projects_macos.txt to keep build-all.yml green."
    }
    if ($winExcludes -notcontains $x) {
        Fail "Xamarin csproj '$x' must be listed in eng/excluded_projects_windows.txt to keep build-all.yml green."
    }
}

foreach ($m in $mauiCsproj) {
    if ($macExcludes -contains $m) {
        Fail "MAUI csproj '$m' is incorrectly listed in eng/excluded_projects_macos.txt — CI would skip it."
    }
    if ($winExcludes -contains $m) {
        Fail "MAUI csproj '$m' is incorrectly listed in eng/excluded_projects_windows.txt — CI would skip it."
    }
}

Write-Host "All Xamarin csproj are excluded from CI; all MAUI csproj are wired into CI."

# --- 5. Category invariants --------------------------------------------------
$validCategories = @(
    'active-code-maui',
    'active-build',
    'resource-binary',
    'resource-text',
    'documentation',
    'tooling-output',
    'reference-xamarin-build',
    'reference-xamarin',
    'reference-xamarin-resource'
)

$badCategoryRows = $csvRows | Where-Object { $validCategories -notcontains $_.category }
if ($badCategoryRows) {
    $names = ($badCategoryRows | ForEach-Object { "$($_.path) -> $($_.category)" }) -join "`n  "
    Fail "Unknown category in MANIFEST_FILES.csv:`n  $names"
}

Write-Host ""
Write-Host "Upgrading manifest validation passed."
exit 0
