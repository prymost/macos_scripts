# Windows Maintenance Scripts

Automated Windows maintenance scripts for keeping your system updated with Windows Updates and application updates via winget.

## 📁 Files Structure

```
windows_setup/
├── maintenance.ps1                      # Main maintenance script
├── setup-scheduled-maintenance.ps1     # Setup automated scheduling
├── modules/
│   ├── WindowsUpdates.ps1              # Windows Updates management
│   └── WingetApps.ps1                  # Winget applications management
└── maintenance.log                      # Execution log (created after first run)
```

## 🚀 Quick Start

### Manual Execution

```powershell
# Run full maintenance (interactive)
.\maintenance.ps1

# Run silently with all updates
.\maintenance.ps1 -Silent -Force

# Only Windows Updates
.\maintenance.ps1 -UpdatesOnly -Force

# Only application updates
.\maintenance.ps1 -AppsOnly -Silent -Force
```

### Automated Scheduling

```powershell
# Set up all scheduled tasks
.\setup-scheduled-maintenance.ps1

# Set up without boot task
.\setup-scheduled-maintenance.ps1 -SkipBoot
```

## 📋 Script Parameters

### maintenance.ps1

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-UpdatesOnly` | Only install Windows Updates | `.\maintenance.ps1 -UpdatesOnly` |
| `-AppsOnly` | Only update applications via winget | `.\maintenance.ps1 -AppsOnly` |
| `-Silent` | Run without user prompts | `.\maintenance.ps1 -Silent` |
| `-Force` | Skip confirmation prompts | `.\maintenance.ps1 -Force` |
| `-NoReboot` | Prevent automatic reboots | `.\maintenance.ps1 -NoReboot` |

### setup-scheduled-maintenance.ps1

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-SkipDaily` | Don't create daily app updates task | Creates daily task |
| `-SkipWeekly` | Don't create weekly full maintenance task | Creates weekly task |
| `-SkipBoot` | Don't create startup maintenance task | Creates boot task |
| `-TaskPath` | Custom path for scheduled tasks | `\WindowsMaintenance\` |

## 📅 Default Schedule

When using `setup-scheduled-maintenance.ps1`, these tasks are created:

1. **Daily App Updates**: Every day at 6:00 AM
   - Updates applications via winget only
   - Runs silently without reboots

2. **Weekly Full Maintenance**: Every Sunday at 3:00 AM
   - Windows Updates + application updates
   - Runs silently without automatic reboots

3. **Startup Maintenance Check**: 5 minutes after system boot
   - Quick check for critical updates
   - Runs silently without reboots

## 🔧 Advanced Usage

### Custom Scheduling

```powershell
# Create custom scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"C:\path\to\maintenance.ps1`" -Silent -Force"
$trigger = New-ScheduledTaskTrigger -Daily -At "22:00"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "Custom Maintenance" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest
```

### Task Management

```powershell
# View maintenance tasks
Get-ScheduledTask -TaskPath "\WindowsMaintenance\*"

# Run a task manually
Start-ScheduledTask -TaskName "Daily App Updates" -TaskPath "\WindowsMaintenance\"

# Remove all maintenance tasks
Get-ScheduledTask -TaskPath "\WindowsMaintenance\*" | Unregister-ScheduledTask -Confirm:$false
```

## 📊 Logging

The maintenance script creates a log file at `maintenance.log` with:
- Execution timestamps
- Success/failure status
- Error messages
- Summary of updates installed

Example log entry:
```
[2025-08-15 14:30:15] [INFO] Windows Maintenance Script Started
[2025-08-15 14:30:16] [SUCCESS] Windows Updates completed successfully
[2025-08-15 14:32:45] [SUCCESS] Application updates completed successfully
[2025-08-15 14:32:46] [INFO] Script execution finished
```

## ⚠️ Requirements

- **Windows 11** (Windows 10 compatible)
- **PowerShell 5.1+**
- **Administrator privileges**
- **Internet connection**
- **Winget** (App Installer from Microsoft Store)

## 🛡️ Security Notes

- Scripts require Administrator privileges
- Scheduled tasks run as SYSTEM account
- PSWindowsUpdate module is installed automatically if needed
- All downloads are from official Microsoft sources

## 🔄 Integration with Bootstrap

The maintenance script is designed to work alongside the existing bootstrap setup:

```powershell
# After initial bootstrap setup
.\bootstrap-windows11.ps1

# Set up ongoing maintenance
.\setup-scheduled-maintenance.ps1

# Manual maintenance when needed
.\maintenance.ps1
```

## 🚨 Troubleshooting

### Common Issues

1. **"PSWindowsUpdate module not found"**
   ```powershell
   Install-Module -Name PSWindowsUpdate -Force -AllowClobber
   ```

2. **"Winget not available"**
   - Install App Installer from Microsoft Store
   - Or download from: https://aka.ms/getwinget

3. **"Access denied" errors**
   - Ensure running as Administrator
   - Check Windows Update service is running

4. **Scheduled tasks not running**
   - Verify Task Scheduler service is running
   - Check task history in Task Scheduler

### Manual Verification

```powershell
# Test Windows Updates module
Import-Module .\modules\WindowsUpdates.ps1
Get-AvailableWindowsUpdates

# Test Winget module
Import-Module .\modules\WingetApps.ps1
Get-OutdatedWingetApps

# View scheduled tasks
Get-ScheduledTask -TaskPath "\WindowsMaintenance\*" | Format-Table
```

## 📞 Support

For issues or improvements:
1. Check the `maintenance.log` file for detailed error information
2. Run scripts manually with `-Verbose` parameter for detailed output
3. Verify all requirements are met
4. Check Windows Event Viewer for system-level errors
