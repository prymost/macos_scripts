#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows Maintenance Script - Keep your system updated

.DESCRIPTION
    Automates regular Windows maintenance tasks including:
    - Installing Windows Updates
    - Updating all applications via winget
    - System cleanup and optimization

    Can be run manually, on startup, or scheduled via Task Scheduler.

.PARAMETER UpdatesOnly
    Only install Windows Updates, skip application updates

.PARAMETER AppsOnly
    Only update applications via winget, skip Windows Updates

.PARAMETER Silent
    Run in silent mode without user prompts (for scheduled execution)

.PARAMETER Force
    Force updates without confirmation prompts

.PARAMETER NoReboot
    Prevent automatic reboots even if required

.EXAMPLE
    .\maintenance.ps1
    Run full maintenance with user prompts

.EXAMPLE
    .\maintenance.ps1 -Silent -Force
    Run full maintenance silently (ideal for scheduled tasks)

.EXAMPLE
    .\maintenance.ps1 -UpdatesOnly -Force
    Only install Windows Updates without prompts

.NOTES
    Author: Windows Setup Scripts
    Date: August 15, 2025
    Requires: Windows 11, PowerShell 5.1+, Administrator privileges

    For Task Scheduler setup:
    - Run with: PowerShell.exe -ExecutionPolicy Bypass -File "path\to\maintenance.ps1" -Silent -Force
    - Set to run as SYSTEM or as administrator account
#>

[CmdletBinding()]
param(
    [switch]$UpdatesOnly,
    [switch]$AppsOnly,
    [switch]$Silent,
    [switch]$Force,
    [switch]$NoReboot
)

# Import required modules
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $scriptRoot "modules"

try {
    # Dot-source the module files to load functions
    . (Join-Path $modulesPath "WindowsUpdates.ps1")
    . (Join-Path $modulesPath "WingetApps.ps1")
}
catch {
    Write-Error "Failed to load required modules: $($_.Exception.Message)"
    Write-Host "Please ensure the modules folder exists with WindowsUpdates.ps1 and WingetApps.ps1" -ForegroundColor Red
    exit 1
}

# Function to check if running as administrator
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to log messages with timestamp
function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    if (-not $Silent) {
        switch ($Level) {
            "ERROR" { Write-Host $logMessage -ForegroundColor Red }
            "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
            default { Write-Host $logMessage -ForegroundColor White }
        }
    }

    # Optionally log to file
    $logFile = Join-Path $scriptRoot "maintenance.log"
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
}

# Main execution starts here
Write-LogMessage "Windows Maintenance Script Started" "INFO"
Write-LogMessage "Parameters: UpdatesOnly=$UpdatesOnly, AppsOnly=$AppsOnly, Silent=$Silent, Force=$Force, NoReboot=$NoReboot" "INFO"

# Verify administrator privileges
if (-not (Test-AdminRights)) {
    Write-LogMessage "This script must be run as Administrator. Please restart PowerShell as Administrator and try again." "ERROR"
    exit 1
}

# Variables to track results
$windowsUpdatesResult = $null
$appsUpdateResult = $null
$rebootRequired = $false

# =============================================================================
# WINDOWS UPDATES SECTION
# =============================================================================
if (-not $AppsOnly) {
    Write-LogMessage "Starting Windows Updates installation..." "INFO"

    try {
        $windowsUpdatesResult = Install-AvailableWindowsUpdates -AutoReboot:(-not $NoReboot) -Force:$Force

        if ($windowsUpdatesResult -eq $true) {
            Write-LogMessage "Windows Updates completed successfully" "SUCCESS"
        }
        elseif ($windowsUpdatesResult -eq "RebootRequired") {
            Write-LogMessage "Windows Updates completed but reboot is required" "WARNING"
            $rebootRequired = $true
        }
        else {
            Write-LogMessage "Windows Updates failed or were cancelled" "WARNING"
        }
    }
    catch {
        Write-LogMessage "Error during Windows Updates: $($_.Exception.Message)" "ERROR"
        $windowsUpdatesResult = $false
    }
}

# =============================================================================
# APPLICATIONS UPDATES SECTION
# =============================================================================
if (-not $UpdatesOnly) {
    Write-LogMessage "Starting application updates..." "INFO"

    try {
        $appsUpdateResult = Update-AllWingetApps -Force:$Force -Silent:$Silent

        if ($appsUpdateResult -eq $true) {
            Write-LogMessage "Application updates completed successfully" "SUCCESS"
        }
        else {
            Write-LogMessage "Application updates failed or were cancelled" "WARNING"
        }
    }
    catch {
        Write-LogMessage "Error during application updates: $($_.Exception.Message)" "ERROR"
        $appsUpdateResult = $false
    }
}

# =============================================================================
# SYSTEM CLEANUP (OPTIONAL)
# =============================================================================
Write-LogMessage "Performing basic system cleanup..." "INFO"

try {
    # Clean temporary files
    $tempCleanupScript = {
        Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    & $tempCleanupScript
    Write-LogMessage "Temporary files cleanup completed" "SUCCESS"
}
catch {
    Write-LogMessage "Error during system cleanup: $($_.Exception.Message)" "WARNING"
}

# =============================================================================
# COMPLETION SUMMARY
# =============================================================================
Write-LogMessage "Maintenance script completed" "INFO"

if (-not $Silent) {
    Write-Host ("`n" + "="*60) -ForegroundColor Cyan
    Write-Host "WINDOWS MAINTENANCE SUMMARY" -ForegroundColor Cyan
    Write-Host ("="*60) -ForegroundColor Cyan

    if (-not $AppsOnly) {
        $statusColor = if ($windowsUpdatesResult -eq $true -or $windowsUpdatesResult -eq "RebootRequired") { "Green" } else { "Red" }
        Write-Host "Windows Updates: " -NoNewline
        Write-Host $(if ($windowsUpdatesResult -eq $true) { "[OK] Completed" }
                     elseif ($windowsUpdatesResult -eq "RebootRequired") { "[OK] Completed (Reboot Required)" }
                     else { "[FAIL] Failed" }) -ForegroundColor $statusColor
    }

    if (-not $UpdatesOnly) {
        $statusColor = if ($appsUpdateResult -eq $true) { "Green" } else { "Red" }
        Write-Host "Application Updates: " -NoNewline
        Write-Host $(if ($appsUpdateResult -eq $true) { "[OK] Completed" } else { "[FAIL] Failed" }) -ForegroundColor $statusColor
    }

    Write-Host "System Cleanup: [OK] Completed" -ForegroundColor Green

    if ($rebootRequired -and -not $NoReboot) {
        Write-Host "`n[WARNING] SYSTEM REBOOT REQUIRED" -ForegroundColor Red
        if (-not $Force) {
            $rebootChoice = Read-Host "Would you like to restart now? (y/n)"
            if ($rebootChoice -eq 'y' -or $rebootChoice -eq 'Y') {
                Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 10
                Restart-Computer -Force
            }
        }
    }

    Write-Host "`nMaintenance log saved to: $logFile" -ForegroundColor Cyan
}

Write-LogMessage "Script execution finished" "INFO"

# Return appropriate exit code
if (($windowsUpdatesResult -eq $false -and -not $AppsOnly) -or ($appsUpdateResult -eq $false -and -not $UpdatesOnly)) {
    exit 1
}
else {
    exit 0
}
