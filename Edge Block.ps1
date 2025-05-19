# -----------------------------
# Full Block: Microsoft Edge Auto Install & Reinstall
# Includes Application Folder Path
# -----------------------------

function Set-RegistryBlock {
    try {
        $key = "HKLM:\SOFTWARE\Microsoft\EdgeUpdate"
        if (-not (Test-Path $key)) {
            New-Item -Path $key -Force | Out-Null
        }
        New-ItemProperty -Path $key -Name "DoNotUpdateToEdgeWithChromium" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-Output "[✔] Registry key set to block Edge auto updates."
    } catch {
        Write-Error "[✖] Failed to set registry key: $_"
    }
}

function Block-EdgeFolders {
    $edgePaths = @(
        "C:\Program Files (x86)\Microsoft\Edge",
        "C:\Program Files\Microsoft\Edge",
        "C:\Program Files (x86)\Microsoft\Edge\Application"
    )

    foreach ($path in $edgePaths) {
        try {
            if (Test-Path $path) {
                takeown /f "$path" /r /d y | Out-Null
                icacls "$path" /grant administrators:F /t | Out-Null
                Remove-Item "$path" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Output "[✔] Removed: $path"
            }

            if (-not (Test-Path $path)) {
                New-Item -Path $path -ItemType Directory -Force | Out-Null
            }

            icacls "$path" /inheritance:r | Out-Null
            icacls "$path" /deny "Everyone:(OI)(CI)(W,M)" | Out-Null
            Write-Output "[✔] Blocked reinstallation at: $path"
        } catch {
            Write-Warning "[!] Could not process: $path — $_"
        }
    }
}

# Main check for admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "❗ Run this script as Administrator."
    exit
}

Write-Host "`n==== BLOCK MICROSOFT EDGE AUTO-INSTALL & APPLICATION FOLDER ====`n"

Set-RegistryBlock
Block-EdgeFolders

Write-Host "`n[✔] Microsoft Edge auto-install and application block completed successfully.`n"
