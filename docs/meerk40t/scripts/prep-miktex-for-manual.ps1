# One-time MiKTeX setup for the UI manual PDF (run once, ~5–15 min, no clicking).
# Close any "Package Installation" popups first (Cancel is OK).

$MiktexBin = "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64"
if (-not (Test-Path "$MiktexBin\pdflatex.exe")) {
    Write-Host "MiKTeX not found. Run: winget install MiKTeX.MiKTeX" -ForegroundColor Red
    exit 1
}

$env:Path = "$MiktexBin;$env:Path"

# Add MiKTeX to user PATH permanently
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$MiktexBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$MiktexBin", "User")
    Write-Host "Added MiKTeX to user PATH." -ForegroundColor Green
}

# Install missing packages automatically (no dialog)
& "$MiktexBin\initexmf.exe" --set-config-value "[MPM] AutoInstall=1" | Out-Null
& "$MiktexBin\initexmf.exe" --set-config-value "[MPM] AlwaysInstall=1" | Out-Null
& "$MiktexBin\initexmf.exe" --set-config-value "[MPM] InstallMissingPackagesOnTheFly=yes" | Out-Null

# Satisfy "check for updates" prompt
& "$MiktexBin\miktex.exe" --version | Out-Null

$packages = @(
    "parskip", "geometry", "hyperref", "xcolor", "graphicx", "bookmark",
    "framed", "fancyvrb", "longtable", "booktabs", "enumitem", "fancyhdr",
    "microtype", "kvsetkeys", "kvoptions", "etoolbox", "ltxcmds", "hycolor",
    "letltxmacro", "refcount", "gettitlestring", "intcalc", "bitset",
    "bigintcalc", "pdftexcmds", "infwarerr", "auxhook", "hobsub", "nameref",
    "stringenc", "rerunfilecheck", "uniquecounter", "pdfescape", "caption",
    "amsmath", "amsfonts", "amssymb", "url", "ulem", "wrapfig"
)

Write-Host "Installing $($packages.Count) LaTeX packages (please wait)..." -ForegroundColor Cyan
$i = 0
foreach ($pkg in $packages) {
    $i++
    Write-Host "  [$i/$($packages.Count)] $pkg"
    & "$MiktexBin\mpm.exe" --install=$pkg --quiet 2>&1 | Out-Null
}

& "$MiktexBin\initexmf.exe" --update-fndb | Out-Null
Write-Host ""
Write-Host "Done. Uncheck 'Always show this dialog' in MiKTeX if it still pops up." -ForegroundColor Green
Write-Host "Then run: build-ui-manual-pdf.ps1" -ForegroundColor Cyan
