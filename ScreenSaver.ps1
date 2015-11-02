##############################################################
# Screen saver for large screens to help prevent burn in
# Created by: nlickey
#
# 10/30/2015
##############################################################

Set-Executionpolicy -Scope CurrentUser -executionpolicy remotesigned -y

$logfile = "C:\ScreenSaverStuff\system-monitoring.log"
 
function startscript($string, $color)
{
   if ($Color -eq $null) {$color = "white"}
   $s = "$string $(get-date -format `"yyyyMMdd_hhmmsstt`")"
   write-host $s -foregroundcolor green
   $s | out-file -Filepath $logfile -append
}
function endscript($string, $color)
{
   if ($Color -eq $null) {$color = "white"}
   $s = "$string $(get-date -format `"yyyyMMdd_hhmmsstt`")"
   write-host $s -foregroundcolor red
   $s | out-file -Filepath $logfile -append
}

startscript "Script started: " -foregroundcolor $color
start-process "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" -Argument "--fullscreen C:\ScreenSaverStuff\videoplayback.mp4"
TIMEOUT 50
Get-Process | Where Name –Like “vlc*” | Stop-Process
endscript "Script ended:   " -foregroundcolor $color
