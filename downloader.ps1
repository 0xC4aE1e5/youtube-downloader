Set-ExecutionPolicy Bypass -Scope CurrentUser
powershell "iwr -useb get.scoop.sh | iex"
scoop install ffmpeg
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$ProgressPreference = "SilentlyContinue"
$ytdl = "$env:TEMP\yt-dlp.exe"
if (Test-Path -Path "$ytdl" -PathType Leaf) {
    0
} else {
    $releases = "https://api.github.com/repos/yt-dlp/yt-dlp/releases"
    $tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name
    $download = "https://github.com/yt-dlp/yt-dlp/releases/download/$tag/yt-dlp_x86.exe"
    Invoke-WebRequest $download -OutFile "$ytdl"
}

$link = $([Microsoft.VisualBasic.Interaction]::InputBox("YouTube link:", "Link"))
$fdial = New-Object System.Windows.Forms.SaveFileDialog
$fdial.Filter = "MP4 files (*.mp4)|*.mp4"
$fdial.ShowDialog()
$name = $fdial.FileName
Write-Output @"
Do
MsgBox "downloading..."
Loop
"@ > $env:TEMP\downloading.vbs
wscript $env:TEMP\downloading.vbs
cmd /c "$ytdl -o video $link"
cmd /c 'move video.* video'
ffmpeg -i video -vcodec copy -c:a copy video.mp4
cmd /c "move video.mp4 $name"
Remove-Item video
taskkill /f /im wscript.exe