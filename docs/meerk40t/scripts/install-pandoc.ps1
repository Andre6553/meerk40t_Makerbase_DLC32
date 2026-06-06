# One-time: install Pandoc from your Downloads zip into %LOCALAPPDATA%\Pandoc and add to user PATH.
$ZipRoot = "C:\Users\User\Downloads\pandoc-3.9.0.2-windows-x86_64"
$ExeSrc = Join-Path $ZipRoot "pandoc-3.9.0.2\pandoc.exe"
$InstallDir = "$env:LOCALAPPDATA\Pandoc"

if (-not (Test-Path $ExeSrc)) {
    Write-Host "Not found: $ExeSrc" -ForegroundColor Red
    Write-Host "Download from https://pandoc.org/installing.html (Windows zip) and adjust `$ZipRoot in this script."
    exit 1
}

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Copy-Item $ExeSrc $InstallDir -Force

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$InstallDir*") {
    $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $InstallDir } else { "$userPath;$InstallDir" }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
}

$env:Path = "$env:Path;$InstallDir"
Write-Host "Installed:" (Join-Path $InstallDir "pandoc.exe") -ForegroundColor Green
& "$InstallDir\pandoc.exe" --version
Write-Host ""
Write-Host "Close and reopen PowerShell so 'pandoc' works everywhere, then run build-ui-manual-pdf.ps1" -ForegroundColor Cyan
