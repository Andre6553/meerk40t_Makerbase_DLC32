# Send one or more commands to a running MeerK40t consoleserver (telnet).
# Run from PowerShell — NOT in the MeerK40t Console pane.
#
# Examples:
#   .\scripts\meerk40t-cmd.ps1 help
#   .\scripts\meerk40t-cmd.ps1 device
#   .\scripts\meerk40t-cmd.ps1 -Command @("tree list")
#   .\scripts\meerk40t-cmd.ps1 -PipeBatch -Command @("devinfo", "spool")
#
# Multi-command batches default to -SingleSession (one telnet connection, wait between
# commands). MeerK40t runs console commands on the GUI thread (~1-3s each).
#
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Command = @("help"),
    [string]$ServerHost = "127.0.0.1",
    [int]$Port = 23,
    [int]$IdleMs = 2500,
    [int]$MaxWaitMs = 60000,
    [int]$MinCommandMs = 4500,
    [int]$BatchSettleMs = 5000,
    [string]$DoneMarker = "MK_DONE",
    [switch]$SingleSession,
    [switch]$PipeBatch
)

$ErrorActionPreference = "Stop"

function Read-Meerk40tResponse {
    param(
        [System.Net.Sockets.NetworkStream]$Stream,
        [System.IO.StreamReader]$Reader,
        [string[]]$IgnoreEcho,
        [int]$IdleMs,
        [int]$MaxWaitMs,
        [string]$WaitForMarker
    )

    $deadline = [datetime]::UtcNow.AddMilliseconds($MaxWaitMs)
    $lastData = [datetime]::UtcNow
    $waitingForFirst = $true
    $markerSeen = [string]::IsNullOrWhiteSpace($WaitForMarker)

    while ([datetime]::UtcNow -lt $deadline) {
        if ($Stream.DataAvailable) {
            while ($Stream.DataAvailable) {
                $text = $Reader.ReadLine()
                if ($null -eq $text) { return $markerSeen }

                $trim = $text.Trim()
                if ($IgnoreEcho -contains $trim) { continue }
                if ($trim -match '^Listening console-server on port') { continue }

                Write-Host $text
                $waitingForFirst = $false
                if (-not $markerSeen -and $trim -eq $WaitForMarker) {
                    $markerSeen = $true
                }
            }
            $lastData = [datetime]::UtcNow
        } elseif ($markerSeen -and -not $waitingForFirst -and (([datetime]::UtcNow - $lastData).TotalMilliseconds -ge $IdleMs)) {
            break
        } elseif ([string]::IsNullOrWhiteSpace($WaitForMarker) -and -not $waitingForFirst -and (([datetime]::UtcNow - $lastData).TotalMilliseconds -ge $IdleMs)) {
            break
        } else {
            Start-Sleep -Milliseconds 50
        }
    }

    return $markerSeen
}

function Send-Meerk40tCommand {
    param(
        [string]$Line,
        [string]$ServerHost,
        [int]$Port,
        [int]$IdleMs,
        [int]$MaxWaitMs,
        [bool]$ReadGreeting,
        [string]$WaitForMarker,
        [string[]]$IgnoreEcho = @()
    )

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $client.ReceiveTimeout = $MaxWaitMs
        $client.SendTimeout = 5000
        $client.Connect($ServerHost, $Port)

        $stream = $client.GetStream()
        $writer = [System.IO.StreamWriter]::new($stream)
        $reader = [System.IO.StreamReader]::new($stream)
        $writer.NewLine = "`r`n"
        $writer.AutoFlush = $true

        Start-Sleep -Milliseconds 300
        if ($ReadGreeting) {
            [void](Read-Meerk40tResponse -Stream $stream -Reader $reader -IgnoreEcho @() -IdleMs $IdleMs -MaxWaitMs 3000)
        }

        Write-Host ">> $Line" -ForegroundColor Cyan
        $writer.WriteLine($Line.Trim())
        return (Read-Meerk40tResponse -Stream $stream -Reader $reader -IgnoreEcho $IgnoreEcho -IdleMs $IdleMs -MaxWaitMs $MaxWaitMs -WaitForMarker $WaitForMarker)
    }
    finally {
        if ($client.Connected) { $client.Close() }
    }
}

if (-not $Command -or $Command.Count -eq 0) {
    Write-Error "No command given. Example: .\scripts\meerk40t-cmd.ps1 device"
    exit 1
}

$probe = Test-NetConnection -ComputerName $ServerHost -Port $Port -WarningAction SilentlyContinue
if (-not $probe.TcpTestSucceeded) {
    Write-Error @"
MeerK40t telnet is not reachable on ${ServerHost}:${Port}.

In MeerK40t (Console pane or Network menu), start it first:
  consoleserver
or: Network -> Start Telnet on port ${Port}
"@
    exit 1
}

$lines = @($Command | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$useSingleSession = $SingleSession.IsPresent -and -not $PipeBatch.IsPresent

if ($PipeBatch -and $lines.Count -gt 1) {
    $batchLines = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) { [void]$batchLines.Add($l.Trim()) }
    [void]$batchLines.Add("echo $DoneMarker")
    $batch = ($batchLines | ForEach-Object { $_.Trim() }) -join "|"
    $done = Send-Meerk40tCommand -Line $batch -ServerHost $ServerHost -Port $Port -IdleMs $IdleMs -MaxWaitMs $MaxWaitMs -ReadGreeting:$true -WaitForMarker $DoneMarker -IgnoreEcho @($batch)
    if (-not $done) {
        Write-Warning "Batch sent but did not see completion marker '$DoneMarker' within ${MaxWaitMs}ms. MeerK40t may still be processing."
        Start-Sleep -Milliseconds $BatchSettleMs
    }
} elseif ($useSingleSession -and $lines.Count -gt 1) {
    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $client.ReceiveTimeout = $MaxWaitMs
        $client.SendTimeout = 5000
        $client.Connect($ServerHost, $Port)

        $stream = $client.GetStream()
        $writer = [System.IO.StreamWriter]::new($stream)
        $reader = [System.IO.StreamReader]::new($stream)
        $writer.NewLine = "`r`n"
        $writer.AutoFlush = $true

        Start-Sleep -Milliseconds 300
        [void](Read-Meerk40tResponse -Stream $stream -Reader $reader -IgnoreEcho @() -IdleMs $IdleMs -MaxWaitMs 3000)

        foreach ($line in $lines) {
            Write-Host ">> $line" -ForegroundColor Cyan
            $sentAt = [datetime]::UtcNow
            $writer.WriteLine($line.Trim())
            [void](Read-Meerk40tResponse -Stream $stream -Reader $reader -IgnoreEcho @($line.Trim()) -IdleMs $IdleMs -MaxWaitMs $MaxWaitMs)
            $elapsed = ([datetime]::UtcNow - $sentAt).TotalMilliseconds
            if ($elapsed -lt $MinCommandMs) {
                Start-Sleep -Milliseconds ([int]($MinCommandMs - $elapsed))
            }
        }
    }
    finally {
        if ($client.Connected) { $client.Close() }
    }
} else {
    $first = $true
    foreach ($line in $lines) {
        $sentAt = [datetime]::UtcNow
        [void](Send-Meerk40tCommand -Line $line -ServerHost $ServerHost -Port $Port -IdleMs $IdleMs -MaxWaitMs $MaxWaitMs -ReadGreeting:$first -WaitForMarker "" -IgnoreEcho @($line.Trim()))
        $first = $false
        $elapsed = ([datetime]::UtcNow - $sentAt).TotalMilliseconds
        if ($lines.Count -gt 1 -and $elapsed -lt $MinCommandMs) {
            Start-Sleep -Milliseconds ([int]($MinCommandMs - $elapsed))
        }
    }
}
