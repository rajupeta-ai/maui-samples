<#
.SYNOPSIS
    Verifies every versioned-module csproj is wired into its module solution.

.DESCRIPTION
    The repo contains versioned MAUI sample modules (9.0/, 10.0/, 11.0/). The
    11.0 module ships a top-level Samples-11.0.sln that must enumerate every
    11.0/**/*.csproj so the module is never silently dropped from the build
    matrix. Run this script (locally or in CI) to assert that invariant.

    9.0 and 10.0 do not ship a top-level solution today; for those modules we
    only assert that csproj files exist (so a folder rename / accidental
    delete is caught).

    Exits with a non-zero code on any failure.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot ".."))
)

$ErrorActionPreference = 'Stop'

function Get-CsprojFiles {
    param([string]$ModulePath)
    if (-not (Test-Path $ModulePath)) { return @() }
    return Get-ChildItem -Path $ModulePath -Filter *.csproj -File -Recurse |
        ForEach-Object { $_.FullName }
}

function Assert-CsprojInSln {
    param(
        [string]$SlnPath,
        [string[]]$CsprojFullPaths,
        [string]$SlnDir
    )
    $slnContent = Get-Content -Raw -Path $SlnPath
    $missing = @()
    foreach ($csproj in $CsprojFullPaths) {
        # Solution files store the path relative to the sln, with backslashes.
        $rel = [System.IO.Path]::GetRelativePath($SlnDir, $csproj).Replace('/', '\')
        # Match the path inside a Project(...) line, case-insensitive.
        $escaped = [Regex]::Escape($rel)
        if ($slnContent -notmatch "(?i)$escaped") {
            $missing += $rel
        }
    }
    return ,$missing
}

$failures = @()

# --- 11.0 module: must have Samples-11.0.sln, must enumerate every csproj ---
$elevenDir   = Join-Path $RepoRoot '11.0'
$elevenSln   = Join-Path $elevenDir 'Samples-11.0.sln'
$elevenProjs = Get-CsprojFiles -ModulePath $elevenDir

if (-not (Test-Path $elevenSln)) {
    $failures += "Missing top-level solution: $elevenSln"
} elseif ($elevenProjs.Count -eq 0) {
    $failures += "11.0 module contains zero csproj files (folder may have been emptied)."
} else {
    $missing = Assert-CsprojInSln -SlnPath $elevenSln -CsprojFullPaths $elevenProjs -SlnDir $elevenDir
    if ($missing.Count -gt 0) {
        foreach ($m in $missing) {
            $failures += "11.0/Samples-11.0.sln does not enumerate: $m"
        }
    }
}

Write-Host "== 11.0 module =="
Write-Host "  Solution: $elevenSln"
Write-Host "  csproj count: $($elevenProjs.Count)"
foreach ($p in $elevenProjs) {
    $rel = [System.IO.Path]::GetRelativePath($RepoRoot, $p)
    Write-Host "    - $rel"
}

# --- 9.0 / 10.0 modules: must contain at least one csproj (sanity check) ---
foreach ($mod in @('9.0', '10.0')) {
    $modDir = Join-Path $RepoRoot $mod
    $projs  = Get-CsprojFiles -ModulePath $modDir
    Write-Host "== $mod module =="
    Write-Host "  csproj count: $($projs.Count)"
    if (-not (Test-Path $modDir)) {
        $failures += "Missing module directory: $modDir"
    } elseif ($projs.Count -eq 0) {
        $failures += "$mod module contains zero csproj files."
    }
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Verification FAILED:" -ForegroundColor Red
    foreach ($f in $failures) { Write-Host "  - $f" -ForegroundColor Red }
    exit 1
}

Write-Host ""
Write-Host "All versioned modules verified." -ForegroundColor Green
exit 0
