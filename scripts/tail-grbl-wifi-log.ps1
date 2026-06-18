# Tail the GRBL Wi-Fi debug log while MeerK40t runs a job.
# In MeerK40t Console first: grbl_wifi_log on
$log = Join-Path $env:LOCALAPPDATA "MeerK40t\grbl-wifi-debug.log"
Write-Host "Watching: $log" -ForegroundColor Cyan
Write-Host "Enable in MeerK40t Console: grbl_wifi_log on" -ForegroundColor DarkGray
if (-not (Test-Path $log)) {
    Write-Host "Log not created yet — start MeerK40t and run grbl_wifi_log on" -ForegroundColor Yellow
}
Get-Content -Path $log -Wait -Tail 40 -ErrorAction SilentlyContinue
