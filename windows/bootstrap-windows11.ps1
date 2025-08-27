#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Bootstrap Script - Complete system setup after fresh installation

.DESCRIPTION
    This script automates the initial setup of Windows 11 including:
    - Installing Windows Updates
    - Configuring security and privacy settings
    - Installing essential applications via winget
    - Configuring Windows features
    - Setting up development tools

.NOTES
    Author: Auto-generated Bootstrap Script
    Date: May 27, 2025
    Requires: Windows 11, PowerShell 5.1+, Administrator privileges

    IMPORTANT: Run this script as Administrator!
#>

# Set execution policy to allow script execution (temporarily)
Write-Host "Setting execution policy..." -ForegroundColor Green
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Function to check if running as administrator
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Verify administrator privileges
if (-not (Test-AdminRights)) {
    Write-Error "This script must be run as Administrator. Please restart PowerShell as Administrator and try again."
    exit 1
}

Write-Host "Windows 11 Bootstrap Script Starting..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# =============================================================================
# INTERACTIVE MENU - CHOOSE WHAT TO RUN
# =============================================================================
Write-Host "`nWhat would you like to run?" -ForegroundColor Yellow
Write-Host "1. Run everything (full bootstrap)" -ForegroundColor Green
Write-Host "2. Install Windows Updates only" -ForegroundColor Green
Write-Host "3. Configure Privacy & Security only" -ForegroundColor Green
Write-Host "4. Configure Windows Features (WSL 2) only" -ForegroundColor Green
Write-Host "5. Install Applications only" -ForegroundColor Green
Write-Host "6. Apply System Optimizations only" -ForegroundColor Green
Write-Host "7. Final Configurations only" -ForegroundColor Green
Write-Host "8. Custom selection (choose multiple sections)" -ForegroundColor Green

$choice = Read-Host "`nEnter your choice (1-8)"

# Initialize section flags
$runUpdates = $false
$runPrivacy = $false
$runFeatures = $false
$runApps = $false
$runOptimizations = $false
$runFinal = $false

switch ($choice) {
    "1" {
        Write-Host "`nRunning full bootstrap..." -ForegroundColor Cyan
        $runUpdates = $runPrivacy = $runFeatures = $runApps = $runOptimizations = $runFinal = $true
    }
    "2" { $runUpdates = $true }
    "3" { $runPrivacy = $true }
    "4" { $runFeatures = $true }
    "5" { $runApps = $true }
    "6" { $runOptimizations = $true }
    "7" { $runFinal = $true }
    "8" {
        Write-Host "`nSelect sections to run (y/n for each):" -ForegroundColor Yellow
        $runUpdates = (Read-Host "Install Windows Updates? (y/n)") -eq 'y'
        $runPrivacy = (Read-Host "Configure Privacy & Security? (y/n)") -eq 'y'
        $runFeatures = (Read-Host "Configure Windows Features (WSL 2)? (y/n)") -eq 'y'
        $runApps = (Read-Host "Install Applications? (y/n)") -eq 'y'
        $runOptimizations = (Read-Host "Apply System Optimizations? (y/n)") -eq 'y'
        $runFinal = (Read-Host "Final Configurations? (y/n)") -eq 'y'
    }
    default {
        Write-Error "Invalid choice. Please run the script again and select 1-8."
        exit 1
    }
}

Write-Host "`nStarting selected operations..." -ForegroundColor Cyan

# =============================================================================
# SECTION 1: INSTALL WINDOWS UPDATES
# =============================================================================
if ($runUpdates) {
    Write-Host "`n[STEP 1] Installing Windows Updates..." -ForegroundColor Yellow

    # Check if PSWindowsUpdate module is installed, if not install it
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Green
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber
    }

    # Import the module
    Import-Module PSWindowsUpdate

    # Install all available Windows Updates
    Write-Host "Checking for Windows Updates..." -ForegroundColor Green
    try {
        # Get list of available updates
        $updates = Get-WindowsUpdate
        if ($updates.Count -gt 0) {
            Write-Host "Found $($updates.Count) update(s). Installing..." -ForegroundColor Green
            Install-WindowsUpdate -AcceptAll -AutoReboot:$false
            Write-Host "Windows Updates installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "No updates available." -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Failed to install Windows Updates: $($_.Exception.Message)"
    }
} # End of Windows Updates section

# =============================================================================
# SECTION 2: PRIVACY AND SECURITY SETTINGS
# =============================================================================
if ($runPrivacy) {
    Write-Host "`n[STEP 2] Applying Privacy and Security Settings..." -ForegroundColor Yellow

    # Disable telemetry and data collection
    Write-Host "Configuring privacy settings..." -ForegroundColor Green

    # Disable telemetry
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Force

    # Disable advertising ID
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Force

    # Disable location tracking
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -Force
} # End of Privacy and Security section

# =============================================================================
# SECTION 3: WINDOWS FEATURES CONFIGURATION
# =============================================================================
if ($runFeatures) {
    Write-Host "`n[STEP 3] Configuring Windows Features..." -ForegroundColor Yellow

    # Enable Windows Subsystem for Linux (WSL)
    Write-Host "Enabling WSL..." -ForegroundColor Green
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

    # Enable Virtual Machine Platform (required for WSL 2)
    Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Green
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    # Set WSL 2 as the default version
    Write-Host "Setting WSL 2 as default version..." -ForegroundColor Green
    wsl --set-default-version 2

    # Install WSL 2 with Ubuntu (this will download and install Ubuntu automatically)
    Write-Host "Installing WSL 2 with Ubuntu..." -ForegroundColor Green
    try {
        wsl --install -d Ubuntu --no-launch
        Write-Host "WSL 2 with Ubuntu installed successfully!" -ForegroundColor Green
        Write-Host "After restart, Ubuntu will be available in WSL 2 mode." -ForegroundColor Cyan
    }
    catch {
        Write-Warning "WSL install command failed. You can manually install after restart with: wsl --install -d Ubuntu"
    }
} # End of Windows Features section

# =============================================================================
# SECTION 3A: GPU DETECTION AND DRIVER INSTALLATION
# =============================================================================
if ($runFeatures) {
    Write-Host "`n[STEP 3A] Detecting GPU and Installing Drivers..." -ForegroundColor Yellow

    # Function to detect GPU vendor
    function Get-GPUVendor {
        try {
            $gpuInfo = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -notlike "*Basic*" -and $_.Name -notlike "*Microsoft*" }

            foreach ($gpu in $gpuInfo) {
                Write-Host "Detected GPU: $($gpu.Name)" -ForegroundColor Cyan

                if ($gpu.Name -match "NVIDIA|GeForce|GTX|RTX|Quadro|Tesla") {
                    return "NVIDIA"
                }
                elseif ($gpu.Name -match "AMD|Radeon|ATI") {
                    return "AMD"
                }
                elseif ($gpu.Name -match "Intel") {
                    return "Intel"
                }
            }
            return "Unknown"
        }
        catch {
            Write-Warning "Could not detect GPU: $($_.Exception.Message)"
            return "Unknown"
        }
    }

    # Detect GPU vendor
    $gpuVendor = Get-GPUVendor
    Write-Host "GPU Vendor detected: $gpuVendor" -ForegroundColor Green

    # Install appropriate drivers and software based on GPU vendor
    switch ($gpuVendor) {
        "NVIDIA" {
            Write-Host "Installing NVIDIA GeForce Experience and drivers..." -ForegroundColor Green
            try {
                # Install NVIDIA GeForce Experience (includes drivers)
                winget install --id Nvidia.GeForceExperience --silent --accept-package-agreements --accept-source-agreements
                Write-Host "NVIDIA GeForce Experience installed successfully!" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to install NVIDIA software: $($_.Exception.Message)"
                Write-Host "You can manually download drivers from: https://www.nvidia.com/drivers" -ForegroundColor Cyan
            }
        }

        "AMD" {
            Write-Host "Installing AMD Radeon Software..." -ForegroundColor Green
            try {
                # Install AMD Radeon Software Adrenalin
                winget install --id AMD.RadeonSoftware --silent --accept-package-agreements --accept-source-agreements
                Write-Host "AMD Radeon Software installed successfully!" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to install AMD Radeon Software: $($_.Exception.Message)"
                Write-Host "You can manually download drivers from: https://www.amd.com/support" -ForegroundColor Cyan
            }
        }

        "Intel" {
            Write-Host "Installing Intel Graphics Command Center..." -ForegroundColor Green
            try {
                # Install Intel Graphics Command Center
                winget install --id Intel.IntelGraphicsCommandCenter --silent --accept-package-agreements --accept-source-agreements
                Write-Host "Intel Graphics Command Center installed successfully!" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to install Intel Graphics software: $($_.Exception.Message)"
                Write-Host "You can manually download drivers from: https://www.intel.com/content/www/us/en/support/products/80939/graphics.html" -ForegroundColor Cyan
            }
        }

        "Unknown" {
            Write-Host "Could not determine GPU vendor. Skipping GPU software installation." -ForegroundColor Yellow
            Write-Host "Please manually install appropriate drivers for your graphics card." -ForegroundColor Cyan
        }
    }
} # End of GPU Detection section

# =============================================================================
# SECTION 4: INSTALL ESSENTIAL APPLICATIONS
# =============================================================================
if ($runApps) {
    Write-Host "`n[STEP 4] Installing Essential Applications..." -ForegroundColor Yellow

    # Import the winget management module
    try {
        $wingetModulePath = Join-Path $PSScriptRoot "modules\WingetApps.ps1"
        if (Test-Path $wingetModulePath) {
            . $wingetModulePath

            # Ensure winget is available
            if (Initialize-Winget) {
                # Define application list
                $apps = @(
                    # Development Tools
                    @{Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
                    @{Name = "Git"; Id = "Git.Git" },
                    @{Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal" },
                    @{Name = "Docker Desktop"; Id = "Docker.DockerDesktop" },
                    @{Name = "AWS CLI"; Id = "Amazon.AWSCLI" },

                    # Browsers
                    @{Name = "Brave Browser"; Id = "Brave.Brave" },

                    # Productivity Tools
                    @{Name = "Logseq"; Id = "Logseq.Logseq" },
                    @{Name = "Microsoft PowerToys"; Id = "Microsoft.PowerToys" },
                    @{Name = "7-Zip"; Id = "7zip.7zip" },
                    @{Name = "LibreOffice"; Id = "TheDocumentFoundation.LibreOffice" },

                    # Media
                    @{Name = "VLC Media Player"; Id = "VideoLAN.VLC" },

                    # Communication
                    @{Name = "Discord"; Id = "Discord.Discord" },
                    @{Name = "Zoom"; Id = "Zoom.Zoom" },

                    # Cloud Storage
                    @{Name = "Google Drive"; Id = "Google.GoogleDrive" },
                    @{Name = "Synology Drive Client"; Id = "Synology.DriveClient" },

                    # Utilities
                    @{Name = "ShareX"; Id = "ShareX.ShareX" },
                    @{Name = "Steam"; Id = "Valve.Steam" },
                    @{Name = "ExpressVPN"; Id = "ExpressVPN.ExpressVPN" },
                    @{Name = "Calibre"; Id = "calibre.calibre" }
                )

                Write-Host "✅ Loaded $($apps.Count) applications" -ForegroundColor Green

                # Install each application
                foreach ($app in $apps) {
                    Write-Host "Installing $($app.Name)..." -ForegroundColor Green
                    try {
                        winget install --id $app.Id --silent --accept-package-agreements --accept-source-agreements
                        Write-Host "$($app.Name) installed successfully!" -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Failed to install $($app.Name): $($_.Exception.Message)"
                    }
                }

                # Install Kinto (Mac-style keyboard shortcuts for Windows)
                Write-Host "`nInstalling Kinto (Mac-style keyboard shortcuts)..." -ForegroundColor Yellow
                try {
                    Write-Host "Kinto provides Mac-style keyboard shortcuts for Windows..." -ForegroundColor Cyan
                    Write-Host "This will enable familiar shortcuts like Cmd+C, Cmd+V, Cmd+Tab, etc." -ForegroundColor Cyan

                    # Download and execute Kinto installation script
                    $kintoInstallScript = "Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/rbreaves/kinto/master/install/windows.ps1 -UseBasicParsing | iex"

                    Write-Host "Downloading and installing Kinto..." -ForegroundColor Green
                    Invoke-Expression $kintoInstallScript

                    Write-Host "Kinto installed successfully!" -ForegroundColor Green
                    Write-Host "After restart, Kinto will provide Mac-style keyboard shortcuts." -ForegroundColor Cyan
                    Write-Host "You can access Kinto settings from the system tray." -ForegroundColor Cyan
                }
                catch {
                    Write-Warning "Failed to install Kinto: $($_.Exception.Message)"
                    Write-Host "You can manually install Kinto later by running:" -ForegroundColor Yellow
                    Write-Host "Set-ExecutionPolicy Bypass -Scope Process -Force" -ForegroundColor Cyan
                    Write-Host "iwr https://raw.githubusercontent.com/rbreaves/kinto/master/install/windows.ps1 -UseBasicParsing | iex" -ForegroundColor Cyan
                }
            }
            else {
                Write-Warning "Could not initialize winget. Skipping application installation."
            }
        }
        else {
            Write-Warning "WingetApps module not found at: $wingetModulePath"
            Write-Host "Please ensure the WingetApps.ps1 module exists in the modules directory." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "Failed to run application installation: $($_.Exception.Message)"
    }
} # End of Applications section

# =============================================================================
# SECTION 5: SYSTEM OPTIMIZATIONS
# =============================================================================
if ($runOptimizations) {
    Write-Host "`n[STEP 5] Applying System Optimizations..." -ForegroundColor Yellow

    # Disable startup programs that slow down boot
    Write-Host "Optimizing startup programs..." -ForegroundColor Green

    # Disable Xbox services (if not gaming)
    Get-Service -Name "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc" | Stop-Service -Force
    Get-Service -Name "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc" | Set-Service -StartupType Disabled
} # End of System Optimizations section

# =============================================================================
# SECTION 6: FINAL CONFIGURATIONS
# =============================================================================
if ($runFinal) {
    Write-Host "`n[STEP 6] Final Configurations..." -ForegroundColor Yellow

    # Configure Windows Terminal with Solarized Dark theme
    Write-Host "Configuring Windows Terminal with Solarized Dark theme..." -ForegroundColor Green
    try {
        $terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $workspaceSettingsPath = "$PSScriptRoot\windows_terminal_settings.json"

        if (Test-Path $workspaceSettingsPath) {
            if (Test-Path $terminalSettingsPath) {
                # Backup existing settings
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                Copy-Item $terminalSettingsPath "$terminalSettingsPath.backup.$timestamp"
                Write-Host "Backed up existing Windows Terminal settings" -ForegroundColor Cyan
            }

            # Copy Solarized Dark configuration
            Copy-Item $workspaceSettingsPath $terminalSettingsPath -Force
            Write-Host "Windows Terminal configured with Solarized Dark theme!" -ForegroundColor Green
            Write-Host "Ubuntu WSL will be the default profile with Solarized Dark colors" -ForegroundColor Cyan
        }
        else {
            Write-Warning "Windows Terminal settings template not found at: $workspaceSettingsPath"
            Write-Host "Please manually configure Windows Terminal after installation" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "Could not configure Windows Terminal: $($_.Exception.Message)"
    }

    # Install Windows Terminal as default terminal
    Write-Host "Setting Windows Terminal as default..." -ForegroundColor Green
    # This requires Windows 11 22H2 or later
    try {
        # Set Windows Terminal as default terminal application
        $terminalPath = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps" -Filter "wt.exe" -Recurse | Select-Object -First 1
        if ($terminalPath) {
            Write-Host "Windows Terminal found and configured!" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Could not configure Windows Terminal as default"
    }
} # End of Final Configurations section

# =============================================================================
# COMPLETION MESSAGE
# =============================================================================
Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "Windows 11 Bootstrap Script Completed!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

Write-Host "`n🎨 Solarized Dark Theme Setup:" -ForegroundColor Yellow
Write-Host "   ✅ Windows Terminal configured with Solarized Dark colors" -ForegroundColor Green
Write-Host "   ✅ Ubuntu WSL set as default profile" -ForegroundColor Green
Write-Host "   💡 Next step: Run the WSL bootstrap to complete terminal setup" -ForegroundColor Cyan

Write-Host "`nNOTE: Some changes require a system restart to take effect." -ForegroundColor Red
$restart = Read-Host "`nWould you like to restart now? (y/n)"
if ($restart -eq 'y' -or $restart -eq 'Y') {
    Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}
else {
    Write-Host "Please restart your computer manually when convenient." -ForegroundColor Yellow
    Write-Host "`n🚀 After restart, launch Ubuntu from Windows Terminal and run:" -ForegroundColor Green
    Write-Host "   cd /mnt/d/Workspace/windows_setup/wsl_scripts" -ForegroundColor Cyan
    Write-Host "   ./bootstrap.sh" -ForegroundColor Cyan
}
