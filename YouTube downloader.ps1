Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
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
$fdial.Filter = "MP4 video (*.mp4)|*.mp4|M4A audio (*.m4a)|*.m4a"
$fdial.ShowDialog()
$name = $fdial.FileName
$ext1 = $name.Split(".")
$ext = $ext1[$ext1.Count - 1]
Write-Output @"
Do
MsgBox "downloading..."
Loop
"@ > $env:TEMP\downloading.vbs
wscript $env:TEMP\downloading.vbs
if ($ext -eq "m4a") {
    cmd /c "$ytdl -f `"m4a`" -o video $link"
    cmd /c "move video `"$name`""
} elseif ($ext -eq "mp4") {
    cmd /c "$ytdl -o video $link"
    cmd /c 'move video.* video'
    ffmpeg -i video -vcodec copy -c:a copy "video.mp4"
    cmd /c "move video.mp4 `"$name`""
}
$olderror = $ErrorActionPreference
$ErrorActionPreference = 'silentlycontinue'
Remove-Item video
$ErrorActionPreference = $olderror
taskkill /f /im wscript.exe
