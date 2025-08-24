#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Winget Applications Management Module

.DESCRIPTION
    Provides functions for managing applications installed via winget.
    Handles updates, upgrades, and application management.

.NOTES
    Author: Windows Setup Scripts
    Requires: Administrator privileges, winget
#>

# Function to check if winget is available
function Test-WingetAvailable {
    [CmdletBinding()]
    param(
        [switch]$Silent
    )

    try {
        $wingetVersion = winget --version 2>$null
        if ($wingetVersion) {
            if (-not $Silent) {
                Write-Host "Winget available - Version: $wingetVersion" -ForegroundColor Green
            }
            return $true
        }
    }
    catch {
        if (-not $Silent) {
            Write-Warning "Winget is not available or not working properly."
        }
        return $false
    }

    return $false
}

# Function to install winget if not available
function Install-Winget {
    [CmdletBinding()]
    param()

    Write-Host "Installing App Installer (winget)..." -ForegroundColor Yellow

    try {
        # Download and install App Installer from Microsoft Store
        $progressPreference = 'SilentlyContinue'
        $appInstallerUrl = "https://aka.ms/getwinget"
        $tempPath = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

        Write-Host "Downloading App Installer..." -ForegroundColor Green
        Invoke-WebRequest -Uri $appInstallerUrl -OutFile $tempPath

        Write-Host "Installing App Installer..." -ForegroundColor Green
        Add-AppxPackage -Path $tempPath

        # Clean up
        Remove-Item $tempPath -Force -ErrorAction SilentlyContinue

        # Wait and verify installation
        Start-Sleep -Seconds 10
        if (Test-WingetAvailable) {
            Write-Host "Winget installed successfully!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "Winget installation may have succeeded but is not immediately available."
            return $false
        }
    }
    catch {
        Write-Error "Failed to install winget: $($_.Exception.Message)"
        Write-Host "Please install App Installer manually from Microsoft Store." -ForegroundColor Yellow
        Write-Host "Download link: https://aka.ms/getwinget" -ForegroundColor Cyan
        return $false
    }
}

# Function to ensure winget is available
function Initialize-Winget {
    [CmdletBinding()]
    param()

    if (Test-WingetAvailable -Silent) {
        return $true
    }

    Write-Host "Winget not found. Attempting to install..." -ForegroundColor Yellow
    return Install-Winget
}

# Function to get list of outdated applications
function Get-OutdatedWingetApps {
    [CmdletBinding()]
    param()

    if (-not (Initialize-Winget)) {
        return $null
    }

    Write-Host "Checking for application updates..." -ForegroundColor Green

    try {
        # Get list of upgradeable packages
        $upgradeList = winget upgrade --accept-source-agreements 2>$null

        if ($LASTEXITCODE -eq 0) {
            # Parse the output to get structured data
            $lines = $upgradeList -split "`n" | Where-Object { $_ -match '\S' }
            $upgradeable = @()

            # Check if there are actually updates available
            $hasHeader = $lines | Where-Object { $_ -match "^Name\s+Id\s+Version\s+Available" }

            if (-not $hasHeader) {
                # No header means no updates available
                Write-Host "No application updates available" -ForegroundColor Green
                return @()  # Return empty array instead of null
            }

            # Skip header lines and find the data rows
            $dataStarted = $false
            $headerPassed = $false

            foreach ($line in $lines) {
                # Look for header lines and calculate column positions
                if ($line -match "^Name\s+Id\s+Version\s+Available") {
                    $dataStarted = $true
                    $headerPassed = $false
                    continue
                }

                # Skip separator lines with dashes
                if ($dataStarted -and $line -match "^-+") {
                    $headerPassed = $true
                    continue
                }

                # Handle section transitions - don't break, just reset
                if ($line -match "^\d+\s+upgrades?\s+available" -or
                    $line -match "^The following packages" -or
                    $line -match "^\d+\s+package.*version numbers") {
                    $dataStarted = $false
                    $headerPassed = $false
                    continue
                }

                # Process data lines
                if ($dataStarted -and $headerPassed -and $line -match '\S') {
                    # Use a different approach - try multiple splitting methods
                    $parts = $null

                    # Method 1: Try splitting by 2+ spaces
                    $parts = $line -split '\s{2,}' | Where-Object { $_ -match '\S' }

                    # Method 2: If that doesn't work, try parsing by known patterns
                    if ($parts.Count -lt 4) {
                        # Use a better regex that looks for ID patterns (contains dots or is at specific position)
                        # Look for: Name (anything until we find an ID-like pattern) ID Version Available
                        if ($line -match '^(.+?)\s+(\S+\.\S+)\s+(\S+)\s+(\S+)') {
                            # Found dotted ID (like Microsoft.Edge, Discord.Discord)
                            $parts = @($matches[1].Trim(), $matches[2].Trim(), $matches[3].Trim(), $matches[4].Trim())
                        }
                        elseif ($line -match '^(.+?)\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+$') {
                            # Found simple ID pattern (5 parts total with source at end)
                            $parts = @($matches[1].Trim(), $matches[2].Trim(), $matches[3].Trim(), $matches[4].Trim())
                        }
                    }

                    if ($parts.Count -ge 4) {
                        $app = [PSCustomObject]@{
                            Name = $parts[0].Trim()
                            Id = $parts[1].Trim()
                            CurrentVersion = $parts[2].Trim()
                            AvailableVersion = $parts[3].Trim()
                        }
                        $upgradeable += $app
                    }
                }
            }

            return $upgradeable
        }
        else {
            Write-Warning "Failed to get winget upgrade list. Exit code: $LASTEXITCODE"
            return $null
        }
    }
    catch {
        Write-Error "Failed to check for application updates: $($_.Exception.Message)"
        return $null
    }
}

# Function to update all winget applications
function Update-AllWingetApps {
    [CmdletBinding()]
    param(
        [switch]$Force = $false,
        [switch]$Silent = $false
    )

    if (-not (Initialize-Winget)) {
        return $false
    }

    $outdatedApps = Get-OutdatedWingetApps

    if ($null -eq $outdatedApps) {
        Write-Warning "Could not retrieve list of outdated applications."
        return $false
    }    if ($outdatedApps.Count -eq 0) {
        Write-Host "All applications are up to date!" -ForegroundColor Green
        return $true
    }

    Write-Host "Found $($outdatedApps.Count) application(s) with available updates:" -ForegroundColor Yellow
    foreach ($app in $outdatedApps) {
        Write-Host "  - $($app.Name) ($($app.CurrentVersion) -> $($app.AvailableVersion))" -ForegroundColor Cyan
    }

    if (-not $Force -and -not $Silent) {
        $confirm = Read-Host "`nDo you want to update all applications? (y/n)"
        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host "Application updates cancelled by user." -ForegroundColor Yellow
            return $false
        }
    }

    Write-Host "`nUpdating applications..." -ForegroundColor Green

    try {
        # Update all applications
        $upgradeArgs = @("upgrade", "--all", "--accept-package-agreements", "--accept-source-agreements")
        if ($Silent) {
            $upgradeArgs += "--silent"
        }

        $result = & winget @upgradeArgs

        if ($LASTEXITCODE -eq 0) {
            Write-Host "All applications updated successfully!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "Some applications may have failed to update. Exit code: $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-Error "Failed to update applications: $($_.Exception.Message)"
        return $false
    }
}

# Function to get installed winget applications
function Get-InstalledWingetApps {
    [CmdletBinding()]
    param()

    if (-not (Initialize-Winget)) {
        return $null
    }

    try {
        $listOutput = winget list --accept-source-agreements 2>$null
        return $listOutput
    }
    catch {
        Write-Error "Failed to get installed applications list: $($_.Exception.Message)"
        return $null
    }
}

# Functions are automatically available when dot-sourced
# No need for Export-ModuleMember in .ps1 files
