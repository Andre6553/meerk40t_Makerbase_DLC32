# DLC32 Wi-Fi health check before MeerK40t jobs (see docs/meerk40t/17-meerkat-dlc32-workflow.md section 8.6)
param(
    [string]$Ip = "192.168.10.90",
    [int]$GrblPort = 8080,
    [int]$StreamSeconds = 15
)

$ErrorActionPreference = "Stop"
$issues = @()

function Test-GrblTcpStream {
    param([string]$Address, [int]$Port, [int]$Seconds)
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $tcp.Connect($Address, $Port)
        $stream = $tcp.GetStream()
        $writer = New-Object System.IO.StreamWriter($stream)
        $reader = New-Object System.IO.StreamReader($stream)
        $writer.Write("`r`n")
        $writer.Flush()
        [void]$reader.ReadLine()
        $deadline = (Get-Date).AddSeconds($Seconds)
        $ok = 0
        $fail = 0
        $n = 0
        while ((Get-Date) -lt $deadline) {
            $n++
            $writer.Write("G0 X$($n % 50) Y$($n % 50)`r`n")
            $writer.Flush()
            $resp = $reader.ReadLine()
            if ($resp -eq "ok") { $ok++ } else { $fail++; break }
            Start-Sleep -Milliseconds 80
        }
        return @{ Ok = $ok; Fail = $fail }
    } finally {
        $tcp.Close()
    }
}

Write-Host "=== DLC32 Wi-Fi check ($Ip) ===" -ForegroundColor Cyan

if (-not (Test-Connection -ComputerName $Ip -Count 1 -Quiet)) {
    $issues += "Ping failed - board offline or wrong IP."
}

try {
    $esp = Invoke-WebRequest -Uri "http://$Ip/command?commandText=%5BESP420%5D" -TimeoutSec 8 -UseBasicParsing
    $body = $esp.Content
    Write-Host $body
    if ($body -match "Signal:\s+(\d+)%") {
        $sig = [int]$Matches[1]
        if ($sig -lt 60) {
            $issues += "Wi-Fi signal weak (${sig}%) - move PC/router closer or use 2.4 GHz near the laser."
        }
    }
    if ($body -match "Sleep mode:\s+Modem") {
        Write-Host "Note: ESP32 modem sleep is ON (normal). MeerK40t pings during jobs." -ForegroundColor DarkYellow
    }
    if ($body -notmatch "Data port:\s+8080") {
        $issues += "GRBL data port is not 8080 - set MeerK40t Interface port to match ESP420."
    }
} catch {
    $issues += "HTTP wake failed: $($_.Exception.Message)"
}

$tcpOk = Test-NetConnection -ComputerName $Ip -Port $GrblPort -WarningAction SilentlyContinue
if (-not $tcpOk.TcpTestSucceeded) {
    $issues += "TCP port $GrblPort closed - close other GRBL clients, open http://${Ip}/ once, retry."
} else {
    Write-Host "Streaming G-code for ${StreamSeconds}s on TCP $GrblPort..." -ForegroundColor DarkGray
    $stream = Test-GrblTcpStream -Address $Ip -Port $GrblPort -Seconds $StreamSeconds
    Write-Host "Stream result: $($stream.Ok) ok, $($stream.Fail) fail"
    if ($stream.Fail -gt 0 -or $stream.Ok -lt 5) {
        $issues += "TCP stream test failed - only one client on port $GrblPort (close ESP32-WEB / phone app)."
    }
}

Write-Host ""
if ($issues.Count -eq 0) {
    Write-Host "Wi-Fi path looks OK for MeerK40t." -ForegroundColor Green
    Write-Host "Before jobs: Connect in MeerK40t, close ESP32-WEB, watch Job progress on Laser tab."
    exit 0
}

Write-Host "Issues found:" -ForegroundColor Yellow
$issues | ForEach-Object { Write-Host "  - $_" }
exit 1
