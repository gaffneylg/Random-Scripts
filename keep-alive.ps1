#
# -- NoSleep --
# Keep your computer awake by programmatically pressing the ScrollLock key every X seconds
#

param($sleep = 540) # seconds
$announcementInterval = 10 # loops

Clear-Host

$WShell = New-Object -com "Wscript.Shell"
$date = Get-Date -Format "dddd MM/dd HH:mm (K)"

$stopwatch
# Some environments don't support invocation of this method.
try {
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
} catch {
   Write-Host "Couldn't start the stopwatch."
}

Write-Host "Executing ScrollLock-toggle NoSleep routine."
Write-Host "Start time:" $(Get-Date -Format "dddd MM/dd HH:mm (K)")

Write-Host "." -fore green

$index = 0
while ( $true )
{
    Write-Host " ." -fore green      # heartbeat
    $WShell.sendkeys("{SCROLLLOCK}")

    Start-Sleep -Milliseconds 200

    $WShell.sendkeys("{SCROLLLOCK}")
    Write-Host "." -fore green       # heartbeat

    Start-Sleep -Seconds $sleep

    # Announce runtime on an interval
    if ( $stopwatch.IsRunning -and (++$index % $announcementInterval) -eq 0 )
    {
        Write-Host "Elapsed time: " $stopwatch.Elapsed.ToString('dd\.hh\:mm\:ss')
    }
}
