# Define log function
function Log {
    param (
        [string]$ImagePath,
        [string]$DesktopResult,
        [string]$LockScreenResult,
        [string]$LogPath = ""
    )
    # Get current time
    $now = Get-Date
    if ($LogPath -eq "") {
        $LogPath = Join-Path -Path $PSScriptRoot -ChildPath "logs.csv"
    }
    # Format time
    $timeStr = $now.ToString("yyyy-MM-dd HH:mm:ss")
    # Check if log file exists
    if (-not (Test-Path -Path $LogPath)) {
        "time,path,DesktopResult,LockScreenResult" | Out-File -FilePath $LogPath -Encoding UTF8
    }
    # Write log to file
    "$timeStr,$ImagePath,$DesktopResult,$LockScreenResult" | Add-Content -Path $LogPath -Encoding UTF8
}

# Get wallpaper function
function Get-Image {
    param (
        [string]$DownloadFolder,
        [string]$Provider
    )
    # Define image download URL and provider
    $url = "https://api.nguaduot.cn"
    $headers = @{
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    }
    # Construct search URL
    $searchURL = "$url/$Provider/random?json=1"
    Write-Host "Fetching image URL..."
    # Send GET request to search URL
    $response = Invoke-WebRequest -Uri $searchURL -Headers $headers
    if ($response.StatusCode -eq 200) {
        Write-Host "Request successful, parsing data..."
        # Parse JSON data
        $result = $response.Content | ConvertFrom-Json
        $data = $result.data
        $imgURL = $data.imgurl
        $imgid = $data.id
        Write-Host "Image URL: $imgURL"
    }
    else {
        Write-Host "Request failed, please check network connection"
        return -1
    }

    # Download image
    Write-Host "Downloading image..."
    # Download image file
    Invoke-WebRequest -Uri $imgURL -Headers $headers -OutFile "$DownloadFolder\$imgid.jpg"
    # Return image file path
    $jpgFile = Join-Path -Path $DownloadFolder -ChildPath "$imgid.jpg"
    Write-Host "Download completed. File path: $jpgFile"
    return $jpgFile
}

# Set desktop wallpaper function
function Set-Wallpaper {
    param (
        [string]$FilePath
    )
    Write-Host "Setting desktop wallpaper..."
    try {
        # Open the registry key
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Control Panel\Desktop", $true)
        $key.SetValue("WallpaperStyle", "10")  # set to fill
        $key.SetValue("TileWallpaper", "0")   # set to centered
        $key.Close()

        # P/Invoke 
        $code = @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
        Add-Type -TypeDefinition $code

        # Call SystemParametersInfo to set wallpaper
        [Wallpaper]::SystemParametersInfo(20, 0, $FilePath, 3)
        Write-Host "Successfully applied: $FilePath as desktop wallpaper"
    }
    catch {
        Write-Host "Wallpaper setup failed: $_"
        return -1
    }
    return 0
}


# Set lockscreen wallpaper function
function Set-LockScreenWallpaper {
    param (
        [string]$FilePath
    )
    Write-Host "Setting lockscreen wallpaper..."
    $igcmdWin10Path = Join-Path -Path $PSScriptRoot -ChildPath "igcmdWin10.exe"
    if (-not (Test-Path -Path $igcmdWin10Path)) {
        Write-Host "igcmdWin10.exe not found, please download first"
        return -1
    }
    try {
        Start-Process -FilePath $igcmdWin10Path -ArgumentList "setlockimage", (Resolve-Path -Path $FilePath) -Wait -NoNewWindow
        Write-Host "Successfully applied: $FilePath as lockscreen wallpaper"
    }
    catch {
        Write-Host "Wallpaper setup failed: $_"
        return -1
    }
    return 0
}

# Main function
function Main {
    $downloadFolder = "download"
    $provider = "spotlight"
    $downloadFolder = Join-Path -Path $PSScriptRoot -ChildPath $downloadFolder
    if (-not (Test-Path -Path $downloadFolder)) {
        New-Item -Path $downloadFolder -ItemType Directory | Out-Null
    }
    $imageFile = Get-Image -DownloadFolder $downloadFolder -Provider $provider
    if ($imageFile -ne -1) {
        $sW = Set-Wallpaper -FilePath $imageFile
        $sL = Set-LockScreenWallpaper -FilePath $imageFile
        Log -ImagePath $imageFile -DesktopResult $sW -LockScreenResult $sL
    }
}

Main