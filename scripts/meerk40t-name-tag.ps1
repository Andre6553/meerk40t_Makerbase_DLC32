# Name tag: Papper preset (_default) — rectangle -> C1 Cut, bitmap text -> R1 Raster (centered in box).
# Requires MeerK40t running with consoleserver (port 23).
#
# Bitmap elem text cannot be assigned to E1 Engrave (vector-only). Papper R1 is the correct op.
#
# Example:
#   .\scripts\meerk40t-name-tag.ps1 -Clear
#   .\scripts\meerk40t-name-tag.ps1 -Name "Sarah" -Clear -Spool
#   .\scripts\meerk40t-name-tag.ps1 -Clear -ClearSpool -Verify
#
param(
    [string]$Name = "Andre",
    [string]$RectX = "20mm",
    [string]$RectY = "20mm",
    [string]$RectW = "60mm",
    [string]$RectH = "30mm",
    [string]$FontSize = "17",
    [string]$Material = "_default",
    [string]$CutStroke = "#ff0000",
    [int]$TextOpIndex = 0,
    [switch]$Clear,
    [switch]$ClearSpool,
    [switch]$Spool,
    [switch]$Verify
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$cmd = Join-Path $scriptDir "meerk40t-cmd.ps1"

if (-not (Test-Path $cmd)) {
    Write-Error "Missing helper: $cmd"
    exit 1
}

function ConvertTo-MmNumber {
    param([string]$Value)
    if ($Value -match '^([\d.]+)\s*mm?$') { return [double]$Matches[1] }
    if ($Value -match '^([\d.]+)$') { return [double]$Matches[1] }
    throw "Invalid length: $Value"
}

$rx = ConvertTo-MmNumber $RectX
$ry = ConvertTo-MmNumber $RectY
$rw = ConvertTo-MmNumber $RectW
$rh = ConvertTo-MmNumber $RectH
$bx0 = "${rx}mm"
$by0 = "${ry}mm"
$bx1 = "$($rx + $rw)mm"
$by1 = "$($ry + $rh)mm"

# Root tree: 0=Operations, 1=Elements. After rect then text: 1.0=rect, 1.1=text.
$textPath = "1.1"
$textOpPath = "0.$TextOpIndex"

$commands = [System.Collections.Generic.List[string]]::new()
if ($ClearSpool) {
    $commands.Add("spool clear")
}
$commands.Add("operation* clear_all")
$commands.Add("material load $Material")
if ($Clear) {
    $commands.Add("element* delete")
}
$commands.Add("rect $RectX $RectY $RectW $RectH stroke $CutStroke classify")
$commands.Add("text `"$Name`" -s $FontSize")
# Select text only; align ref uses rectangle bounds (align first fails when both are selected).
$commands.Add("element1 select")
$commands.Add("align ref -b $bx0 $by0 $bx1 $by1 center")
$commands.Add("tree dnd $textPath $textOpPath")
if ($Spool) {
    $commands.Add("plan0 clear copy preprocess validate blob spool")
}

Write-Host "Sending $($commands.Count) command(s) to MeerK40t (pipe batch, wait for completion)..." -ForegroundColor Yellow
& $cmd -PipeBatch -MaxWaitMs 120000 -MinCommandMs 4500 -Command $commands
if (-not $?) {
    Write-Error "MeerK40t command batch failed."
    exit 1
}

if ($Verify) {
    Write-Host ""
    Write-Host "Tree after build:" -ForegroundColor Yellow
    & $cmd -Command @("tree list")
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "  Rectangle ($RectW x $RectH) -> C1 Cut (stroke $CutStroke + classify)"
Write-Host "  Bitmap text `"$Name`" -> R1 Raster (tree dnd $textPath -> $textOpPath), centered in box"
Write-Host "  (E1 Engrave is vector-only; bitmap text uses R1 on the Papper preset.)"
if (-not $Spool) {
    Write-Host "Add -Spool to queue the job."
}
if (-not $ClearSpool) {
    Write-Host "If the laser shows Busy Error, clear old jobs: .\scripts\meerk40t-name-tag.ps1 -ClearSpool -Clear"
}
