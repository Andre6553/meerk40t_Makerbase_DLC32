# Build MeerK40t UI manual: HTML (always) + PDF if MiKTeX/pdflatex is ready.
# First-time PDF: run prep-miktex-for-manual.ps1 once (avoids Install popups).

$DocsMeerk40t = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Workspace = (Resolve-Path (Join-Path $DocsMeerk40t "..\..")).Path
$Images = Join-Path $Workspace "images\meerk40t-ui-manual"
$Md = Join-Path $DocsMeerk40t "18-meerk40t-ui-manual.md"
$Html = Join-Path $DocsMeerk40t "MeerK40t-UI-Manual.html"
$Pdf = Join-Path $DocsMeerk40t "MeerK40t-UI-Manual.pdf"

$PandocDir = Join-Path $env:LOCALAPPDATA "Pandoc"
$MiktexBin = Join-Path $env:LOCALAPPDATA "Programs\MiKTeX\miktex\bin\x64"
foreach ($dir in @($PandocDir, $MiktexBin)) {
    if (Test-Path $dir) { $env:Path = "$dir;$env:Path" }
}

if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    Write-Host "Pandoc not found. Run install-pandoc.ps1" -ForegroundColor Red
    exit 1
}

$common = @(
    $Md, "--from", "markdown", "--toc", "--toc-depth=3",
    "--resource-path=$DocsMeerk40t;$Images"
)

Write-Host "Building HTML..." -ForegroundColor Cyan
pandoc @common -o $Html --standalone -V title="MeerK40t UI Manual (Meerkat)"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Created: $Html" -ForegroundColor Green

if (-not (Get-Command pdflatex -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "PDF skipped (pdflatex not on PATH)." -ForegroundColor Yellow
    Write-Host "Quick PDF: open HTML in Edge -> Ctrl+P -> Save as PDF" -ForegroundColor Yellow
    Write-Host "  $Html" -ForegroundColor Gray
    Write-Host "Or: winget install MiKTeX.MiKTeX then run prep-miktex-for-manual.ps1" -ForegroundColor Gray
    exit 0
}

# Quieter MiKTeX during build
$env:MIKTEX_ALLOW_UNSAFE_ADMIN_INSTALL = "1"

Write-Host "Building PDF (first run can take several minutes)..." -ForegroundColor Cyan
$log = Join-Path $env:TEMP "meerk40t-manual-pdf.log"
pandoc @common -o $Pdf `
    -V geometry:margin=2.5cm `
    -V documentclass=report `
    --pdf-engine=pdflatex 2>&1 | Tee-Object -FilePath $log

if ((Test-Path $Pdf) -and $LASTEXITCODE -eq 0) {
    Write-Host "Created: $Pdf" -ForegroundColor Green
    Get-Item $Pdf | ForEach-Object { Write-Host ("  Size: {0:N2} MB" -f ($_.Length / 1MB)) }
} else {
    Write-Host "PDF failed. Log: $log" -ForegroundColor Red
    Write-Host ""
    Write-Host "Easiest fix — use HTML (no MiKTeX):" -ForegroundColor Yellow
    Write-Host "  start `"$Html`"" -ForegroundColor Gray
    Write-Host "  Edge -> Ctrl+P -> Save as PDF" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or fix MiKTeX packages (one-time):" -ForegroundColor Yellow
    Write-Host "  powershell -File `"$PSScriptRoot\prep-miktex-for-manual.ps1`"" -ForegroundColor Gray
}

exit 0
