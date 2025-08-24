#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Creates scheduled tasks for automated Windows maintenance

.DESCRIPTION
    Sets up Windows Task Scheduler tasks to run maintenance script automatically:
    - Daily maintenance task (apps updates)
    - Weekly maintenance task (full updates including Windows Updates)
    - Boot maintenance task (optional, runs after system startup)

.PARAMETER SkipDaily
    Skip creating the daily maintenance task

.PARAMETER SkipWeekly
    Skip creating the weekly maintenance task

.PARAMETER SkipBoot
    Skip creating the boot maintenance task

.PARAMETER TaskPath
    Custom path for scheduled tasks (default: \WindowsMaintenance\)

.EXAMPLE
    .\setup-scheduled-maintenance.ps1
    Create all maintenance tasks with default settings

.EXAMPLE
    .\setup-scheduled-maintenance.ps1 -SkipBoot
    Create daily and weekly tasks only
#>

[CmdletBinding()]
param(
    [switch]$SkipDaily,
    [switch]$SkipWeekly,
    [switch]$SkipBoot,
    [string]$TaskPath = "\WindowsMaintenance\"
)

# Get the directory where this script is located
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$maintenanceScript = Join-Path $scriptRoot "maintenance.ps1"

# Verify maintenance script exists
if (-not (Test-Path $maintenanceScript)) {
    Write-Error "Maintenance script not found at: $maintenanceScript"
    exit 1
}

# Function to create a scheduled task
function New-MaintenanceTask {
    param(
        [string]$TaskName,
        [string]$Description,
        [string]$Arguments,
        [object]$Trigger,
        [string]$Path = $TaskPath
    )

    try {
        # Create the action
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$maintenanceScript`" $Arguments"

        # Create settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable

        # Create principal (run as SYSTEM)
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        # Register the task
        Register-ScheduledTask -TaskName $TaskName -TaskPath $Path -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description $Description -Force

        Write-Host "✅ Created scheduled task: $TaskName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to create scheduled task '$TaskName': $($_.Exception.Message)"
        return $false
    }
}

Write-Host "Setting up Windows Maintenance Scheduled Tasks..." -ForegroundColor Cyan
Write-Host "Maintenance script location: $maintenanceScript" -ForegroundColor Yellow

$tasksCreated = 0

# Create Daily Maintenance Task (Applications only)
if (-not $SkipDaily) {
    Write-Host "`nCreating daily maintenance task..." -ForegroundColor Yellow

    # Run every day at 6:00 AM
    $dailyTrigger = New-ScheduledTaskTrigger -Daily -At "06:00"

    if (New-MaintenanceTask -TaskName "Daily App Updates" -Description "Daily maintenance - Update applications via winget" -Arguments "-AppsOnly -Silent -Force" -Trigger $dailyTrigger) {
        $tasksCreated++
    }
}

# Create Weekly Maintenance Task (Full maintenance)
if (-not $SkipWeekly) {
    Write-Host "`nCreating weekly maintenance task..." -ForegroundColor Yellow

    # Run every Sunday at 3:00 AM
    $weeklyTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "03:00"

    if (New-MaintenanceTask -TaskName "Weekly Full Maintenance" -Description "Weekly maintenance - Windows Updates and application updates" -Arguments "-Silent -Force -NoReboot" -Trigger $weeklyTrigger) {
        $tasksCreated++
    }
}

# Create Boot Maintenance Task (Optional)
if (-not $SkipBoot) {
    Write-Host "`nCreating boot maintenance task..." -ForegroundColor Yellow

    # Run 5 minutes after system startup
    $bootTrigger = New-ScheduledTaskTrigger -AtStartup
    $bootTrigger.Delay = "PT5M"  # 5 minute delay

    if (New-MaintenanceTask -TaskName "Startup Maintenance Check" -Description "Check for updates after system startup" -Arguments "-Silent -Force -NoReboot" -Trigger $bootTrigger) {
        $tasksCreated++
    }
}

# Summary
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "SCHEDULED TASKS SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan
Write-Host "Tasks created: $tasksCreated" -ForegroundColor Green

if ($tasksCreated -gt 0) {
    Write-Host "`nYou can manage these tasks using:" -ForegroundColor Yellow
    Write-Host "• Task Scheduler (taskschd.msc)" -ForegroundColor Cyan
    Write-Host "• PowerShell: Get-ScheduledTask -TaskPath '$TaskPath*'" -ForegroundColor Cyan

    Write-Host "`nTo remove all maintenance tasks:" -ForegroundColor Yellow
    Write-Host "Get-ScheduledTask -TaskPath '$TaskPath*' | Unregister-ScheduledTask -Confirm:`$false" -ForegroundColor Cyan

    Write-Host "`nTo run maintenance manually:" -ForegroundColor Yellow
    Write-Host "PowerShell.exe -ExecutionPolicy Bypass -File `"$maintenanceScript`"" -ForegroundColor Cyan
}
else {
    Write-Warning "No scheduled tasks were created."
}
