Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $ProjectRoot

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Title,

        [Parameter(Mandatory = $true)]
        [string] $Command,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $Arguments
    )

    Write-Host ""
    Write-Host "==> $Title" -ForegroundColor Cyan
    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "$Title failed with exit code $LASTEXITCODE"
    }
}

if (-not (Test-Path (Join-Path $ProjectRoot ".env"))) {
    throw ".env file was not found in $ProjectRoot"
}

Invoke-Step "Flutter clean" "flutter" "clean"
Invoke-Step "Flutter pub get" "flutter" "pub" "get"
Invoke-Step "Build Android app bundle" "flutter" "build" "appbundle" "--release" "--dart-define-from-file=.env"
Invoke-Step "Build Flutter web" "flutter" "build" "web" "--release" "--dart-define-from-file=.env"
Invoke-Step "Copy web redirects" "dart" "tool/copy_web_redirects.dart"
Invoke-Step "Deploy to Netlify production" "netlify" "deploy" "--prod"

Write-Host ""
Write-Host "Release build and Netlify production deploy completed." -ForegroundColor Green
