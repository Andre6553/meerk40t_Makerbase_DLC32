# Wake MKS DLC32 on LAN before MeerK40t TCP connect (ESP32 may not answer until HTTP/ping).
param(
    [string]$Ip = "192.168.10.90",
    [int]$GrblPort = 8080,
    [int]$Attempts = 8,
    [int]$TimeoutSec = 3
)

$ErrorActionPreference = "SilentlyContinue"
for ($i = 1; $i -le $Attempts; $i++) {
    $null = Test-Connection -ComputerName $Ip -Count 1 -Quiet -TimeoutSeconds $TimeoutSec
    try {
        Invoke-WebRequest -Uri "http://$Ip/" -TimeoutSec $TimeoutSec -UseBasicParsing | Out-Null
        $tcp = Test-NetConnection -ComputerName $Ip -Port $GrblPort -WarningAction SilentlyContinue
        if ($tcp.TcpTestSucceeded) {
            Write-Host "DLC32 reachable: http://$Ip/ and GRBL TCP port $GrblPort (attempt $i)"
            exit 0
        }
        Write-Host "Web OK at http://$Ip/ but port $GrblPort closed (attempt $i); retrying..."
    } catch {
        Start-Sleep -Milliseconds 500
    }
}
Write-Host "DLC32 not ready at http://$Ip/ or TCP $GrblPort after $Attempts attempts"
exit 1
