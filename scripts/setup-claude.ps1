[CmdletBinding()]
param(
    [switch]$Strict
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$missing = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Test-RequiredCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$InstallUrl
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        $script:missing.Add("$Name missing. Install: $InstallUrl")
        Write-Host "[MISSING] $Name"
        return
    }

    Write-Host "[OK]      $Name -> $($command.Source)"
}

function Test-JsonFile {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required file missing: $RelativePath"
    }

    Get-Content -LiteralPath $path -Raw | ConvertFrom-Json | Out-Null
    Write-Host "[OK]      valid JSON -> $RelativePath"
}

function Test-DartVersion {
    $dart = Get-Command 'dart' -ErrorAction SilentlyContinue
    if ($null -eq $dart) {
        return
    }

    $rawVersion = (& dart --version 2>&1 | Out-String).Trim()
    if ($rawVersion -notmatch 'Dart SDK version:\s+(?<version>\d+\.\d+\.\d+)') {
        $script:warnings.Add("Could not parse Dart SDK version: $rawVersion")
        Write-Host "[WARN]    Could not parse Dart SDK version"
        return
    }

    $dartVersion = [version]$Matches.version
    Write-Host "[OK]      Dart SDK version -> $dartVersion"
    if ($dartVersion -lt [version]'3.9.0') {
        $script:missing.Add("Dart SDK $dartVersion is too old for Dart MCP. Install Dart 3.9 or later with Flutter: https://docs.flutter.dev/get-started/install/windows")
        Write-Host '[MISSING] Dart MCP requires Dart SDK 3.9 or later'
    }
}

Write-Host "Mascoteach Claude Code setup check"
Write-Host "Repository: $repoRoot"
Write-Host ''

Test-RequiredCommand -Name 'git' -InstallUrl 'https://git-scm.com/download/win'
Test-RequiredCommand -Name 'claude' -InstallUrl 'https://code.claude.com/docs/en/setup'
Test-RequiredCommand -Name 'flutter' -InstallUrl 'https://docs.flutter.dev/get-started/install/windows'
Test-RequiredCommand -Name 'dart' -InstallUrl 'Installed with Flutter: https://docs.flutter.dev/get-started/install/windows'
Test-DartVersion

Write-Host ''
Test-JsonFile -RelativePath '.mcp.json'
Test-JsonFile -RelativePath '.claude/settings.json'

$claudeMd = Join-Path $repoRoot 'CLAUDE.md'
if (-not (Test-Path -LiteralPath $claudeMd)) {
    throw 'Required file missing: CLAUDE.md'
}

$claudeMdBytes = (Get-Item -LiteralPath $claudeMd).Length
Write-Host "[OK]      CLAUDE.md -> $claudeMdBytes bytes"

if ($missing.Count -gt 0) {
    Write-Host ''
    Write-Warning 'Some prerequisites are missing:'
    foreach ($item in $missing) {
        Write-Host "  - $item"
    }
}

if ($warnings.Count -gt 0) {
    Write-Host ''
    Write-Warning 'Setup warnings:'
    foreach ($item in $warnings) {
        Write-Host "  - $item"
    }
}

Write-Host ''
Write-Host 'Next steps:'
Write-Host '  1. Start Claude Code from this repository.'
Write-Host '  2. Approve the project MCP servers when prompted.'
Write-Host '  3. Run /mcp to confirm context7 and dart are connected.'
Write-Host '  4. Run /verify-flutter after Dart changes.'
Write-Host ''
Write-Host 'Optional personal MCP integrations are available through /setup-team.'

if ($Strict -and $missing.Count -gt 0) {
    exit 1
}
