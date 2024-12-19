
# Function to install SNMP feature
function Install-SNMP {
    Write-Host "Installing SNMP feature..."
    if (Add-WindowsCapability -Online -Name "SNMP.Client~~~~0.0.1.0") {
        # For Windows Server
        Install-WindowsFeature -Name "SNMP" -IncludeManagementTools
    } else {
        # For Windows 10/11
        Add-WindowsCapability -Online -Name "SNMP.Client~~~~0.0.1.0"
    }
    Write-Host "SNMP feature has been installed."
}

# Function to install applications
function Install-Application {
    param (
        [string]$AppName,
        [string]$DownloadUrl,
        [string]$InstallerArgs = ""
    )

    Write-Host "Installing $AppName..."
    $installerPath = "$env:TEMP\$($AppName -replace ' ', '_')_installer.exe"
    
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList $InstallerArgs -Wait
    Remove-Item $installerPath -Force
    Write-Host "$AppName has been installed."
}

# Function to retrieve Windows product key
function Get-WindowsProductKey {
    Write-Host "Retrieving Windows Product Key..."
    $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    if ($key) {
        Write-Host "Windows Product Key: $key"
    } else {
        Write-Host "Could not retrieve the Windows Product Key."
    }
}

# Main script execution
Enable-RDP
Install-SNMP

# List of applications to install
$applications = @(
    @{
        Name = "Google Chrome"
        Url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        Args = "/silent /install"
    },
    @{
        Name = "TeamViewer Host"
        Url = "https://download.teamviewer.com/download/TeamViewer_Host_Setup.exe"
        Args = "/S"
    },
    @{
        Name = "Notepad++"
        Url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest/download/npp.8.4.2.Installer.exe"
        Args = "/S"  # Silent installation
    }
)

# Install each application in the list
foreach ($app in $applications) {
    Install-Application -AppName $app.Name -DownloadUrl $app.Url -InstallerArgs $app.Args
}

# Retrieve and display the Windows product key
Get-WindowsProductKey

# Show the current IP address at the end
ipconfig

Write-Host "All tasks completed successfully."