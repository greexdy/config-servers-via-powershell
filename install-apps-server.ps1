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

# Function to add a new user and add them to the Users group
function Add-NewUser  {
    param (
        [string]$User  = "CCTV",
        [string]$Password = "cctv"
    )

    Write-Host "Adding new user: $User  Name..."
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    New-LocalUser  -Name $User  -Password $SecurePassword -FullName "CCTV User" -Description "User  account for CCTV"
    
    # Add the new user to the Users group
    Add-LocalGroupMember -Group "Gebruikers" -Member $User 
    
    Write-Host "User  $User  Name has been created and added to the Users group."
}

# Function to set auto login
function Set-AutoLogin {
    param (
        [string]$User  = "CCTV",
        [string]$Password = "cctv"
    )

    Write-Host "Setting up auto login for user: $User  ..."
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    
    Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
    Set-ItemProperty -Path $regPath -Name "DefaultUser Name" -Value $User  
    Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $Password
    Write-Host "Auto login has been configured for user $User ."
}

# Main script execution
Install-SNMP

# Add the new user
Add-NewUser   

# Set auto login for the new user
Set-AutoLogin

# List of applications to install
$applications = @(
    @{
        Name = "Google Chrome"
        Url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        Args = "/silent /install"
    },
    @{
        Name = "TeamViewer Host"
        Url = "https://download .teamviewer.com/download/TeamViewer_Host_Setup.exe"
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