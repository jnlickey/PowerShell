##############################################################
# Screen saver for large screens to help prevent burn in.
# REQUIREMENTS:
# 1) Create a folder on the C: drive named ScreenSaverStuff
# 2) Get a video from youtube.com, or create a video
# that contains only static. Example video can be found at:
# https://www.youtube.com/watch?v=bf7NbRFyg3Y
# You can use http://keepvid.com/ to download and save the
# youtube video as an mp4 file.
# 3) Download and install VLC Player to the default location
# https://get.videolan.org/vlc/2.2.4/win32/vlc-2.2.4-win32.exe
# 4) Save this powershell script and the MP4 video file in the
# newly created C:\ScreenSaverStuff directory.
# 5) Configure the TIMEOUT in this script to the amount of time
# that you would like the video to continue to play for.
# 6) Configure Windows TaskScheduler to execute this script
# at a predetermined time.
#
# Created by: nlickey
# 10/30/2015
##############################################################

Set-Executionpolicy -Scope CurrentUser -executionpolicy remotesigned -y

$logfile = "C:\ScreenSaverStuff\system-monitoring.log"
 
function startscript($string, $color)
{
   if ($Color -eq $null) {$color = "green"}
   $s = "$string $(get-date -format `"yyyyMMdd_hhmmsstt`")"
   write-host $s -foregroundcolor green
   $s | out-file -Filepath $logfile -append
}
function endscript($string, $color)
{
   if ($Color -eq $null) {$color = "red"}
   $s = "$string $(get-date -format `"yyyyMMdd_hhmmsstt`")"
   write-host $s -foregroundcolor red
   $s | out-file -Filepath $logfile -append
}

startscript "Script started: " -foregroundcolor $color
start-process "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" -Argument "--fullscreen C:\ScreenSaverStuff\videoplayback.mp4"
# TIMEOUT is in seconds
# TIMEOUT 3600 = 1 hour
# TIMEOUT 36000 = 10 hours
TIMEOUT 50
Get-Process | Where Name –Like “vlc*” | Stop-Process
endscript "Script ended:   " -foregroundcolor $color
