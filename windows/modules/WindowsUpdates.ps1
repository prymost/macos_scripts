#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows Updates Management Module

.DESCRIPTION
    Provides functions for managing Windows Updates installation and checking.
    Can be imported by other scripts or run standalone.

.NOTES
    Author: Windows Setup Scripts
    Requires: Administrator privileges, PSWindowsUpdate module
#>

# Function to ensure PSWindowsUpdate module is available
function Initialize-WindowsUpdateModule {
    [CmdletBinding()]
    param()

    Write-Host "Checking PSWindowsUpdate module..." -ForegroundColor Green

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Yellow
        try {
            Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser
            Write-Host "PSWindowsUpdate module installed successfully!" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to install PSWindowsUpdate module: $($_.Exception.Message)"
            return $false
        }
    }

    try {
        Import-Module PSWindowsUpdate -Force
        Write-Host "PSWindowsUpdate module loaded successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to import PSWindowsUpdate module: $($_.Exception.Message)"
        return $false
    }
}

# Function to check for available Windows Updates
function Get-AvailableWindowsUpdates {
    [CmdletBinding()]
    param()

    Write-Host "Checking for available Windows Updates..." -ForegroundColor Green

    try {
        $updates = Get-WindowsUpdate

        # Handle the case where Get-WindowsUpdate returns null when no updates are available
        if ($null -eq $updates) {
            $updates = @()  # Convert null to empty array
        }

        Write-Host "Successfully retrieved $($updates.Count) Windows Update(s)" -ForegroundColor Green
        return $updates
    }
    catch {
        Write-Warning "Failed to check for Windows Updates: $($_.Exception.Message)"
        Write-Host "Error details: $($_.Exception.GetType().FullName)" -ForegroundColor Yellow
        return $null
    }
}# Function to install Windows Updates
function Install-AvailableWindowsUpdates {
    [CmdletBinding()]
    param(
        [switch]$AutoReboot = $false,
        [switch]$Force = $false
    )

    if (-not (Initialize-WindowsUpdateModule)) {
        return $false
    }

    $updates = Get-AvailableWindowsUpdates

    # Safety check - ensure $updates is never null at this point
    if ($null -eq $updates) {
        $updates = @()
    }    # More robust check - test for actual failure conditions
    if ($null -eq $updates -or $updates -eq $false) {
        Write-Warning "Could not retrieve updates list."
        return $false
    }

    # Ensure updates is treated as an array
    if ($updates -isnot [System.Array]) {
        $updates = @($updates)
    }

    if ($updates.Count -eq 0) {
        Write-Host "No Windows Updates available." -ForegroundColor Green
        return $true
    }

    Write-Host "Found $($updates.Count) update(s) available:" -ForegroundColor Yellow
    foreach ($update in $updates) {
        Write-Host "  - $($update.Title)" -ForegroundColor Cyan
    }

    if (-not $Force) {
        $confirm = Read-Host "`nDo you want to install these updates? (y/n)"
        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host "Updates installation cancelled by user." -ForegroundColor Yellow
            return $false
        }
    }

    Write-Host "`nInstalling Windows Updates..." -ForegroundColor Green
    try {
        Install-WindowsUpdate -AcceptAll -AutoReboot:$AutoReboot
        Write-Host "Windows Updates installed successfully!" -ForegroundColor Green

        # Check if reboot is required using Get-WURebootStatus
        try {
            $rebootStatus = Get-WURebootStatus
            if ($rebootStatus -eq $true) {
                Write-Warning "A system reboot is required to complete the updates."
                return "RebootRequired"
            }
        }
        catch {
            # Fallback method - check for pending reboot via registry
            $rebootPending = $false
            try {
                $cbsReboot = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue
                $wuReboot = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue
                if ($cbsReboot -or $wuReboot) {
                    $rebootPending = $true
                }
            }
            catch {
                # If we can't check, assume no reboot needed
                $rebootPending = $false
            }

            if ($rebootPending) {
                Write-Warning "A system reboot is required to complete the updates."
                return "RebootRequired"
            }
        }

        return $true
    }
    catch {
        Write-Error "Failed to install Windows Updates: $($_.Exception.Message)"
        return $false
    }
}

# Function to get update history
function Get-WindowsUpdateHistory {
    [CmdletBinding()]
    param(
        [int]$MaxResults = 10
    )

    if (-not (Initialize-WindowsUpdateModule)) {
        return $null
    }

    try {
        $history = Get-WUHistory | Select-Object -First $MaxResults
        return $history
    }
    catch {
        Write-Error "Failed to retrieve Windows Update history: $($_.Exception.Message)"
        return $null
    }
}

# Functions are automatically available when dot-sourced
# No need for Export-ModuleMember in .ps1 files
