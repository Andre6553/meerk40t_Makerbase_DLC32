# MeerK40t UI manual — screenshot helper (Andre / Meerkat workspace)
# Run while MeerK40t is open. Each prompt: capture active window, save to the folder shown.
# Windows: Win+Shift+S (snip) or use ShareX/Greenshot; name files exactly as listed for PDF build.

$Workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$OutDir = Join-Path $Workspace "images\meerk40t-ui-manual"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

$shots = @(
    "01-main-window-default-layout.png",
    "02-scene-zoom-pan.png",
    "03-ribbon-tools.png",
    "04-elements-tree-context-menu.png",
    "05-operations-tree-classify.png",
    "06-laser-panel-connect-arm.png",
    "07-navigation-jog-pulse.png",
    "08-properties-element.png",
    "09-properties-operation-cut.png",
    "10-device-manager.png",
    "11-device-configuration-grbl.png",
    "12-console-pane.png",
    "13-job-spooler.png",
    "14-simulation-window.png",
    "15-material-manager.png",
    "16-material-test.png",
    "17-preferences-general.png",
    "18-view-menu-draw-modes.png",
    "19-edit-menu.png",
    "20-file-menu.png",
    "21-network-menu.png",
    "22-alignment-window.png",
    "23-node-edit-tool.png",
    "24-status-bar-widgets.png",
    "25-unassigned-warning.png",
    "26-execute-job-progress.png"
)

Write-Host "Save screenshots to:" -ForegroundColor Cyan
Write-Host $OutDir
Write-Host ""
foreach ($f in $shots) {
    $path = Join-Path $OutDir $f
    if (Test-Path $path) { Write-Host "[OK]  $f" -ForegroundColor Green }
    else { Write-Host "[ -- ] $f" -ForegroundColor Yellow }
}
Write-Host ""
Write-Host "Tip: Maximize MeerK40t, reset panes (Window menu -> reset positions), then capture." -ForegroundColor Gray
Write-Host "After all files exist, run: docs\meerk40t\scripts\build-ui-manual-pdf.ps1" -ForegroundColor Gray
