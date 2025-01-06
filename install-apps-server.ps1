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

# Enable Remote Desktop 
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# Set the firewall rule to allow Remote Desktop connections
New-NetFirewallRule -DisplayName "Remote Desktop" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 3389

# Main script execution
Install-SNMP

# Add the new user
Add-NewUser   

# Set auto login for the new user
Set-AutoLogin

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install teamviewer-host
choco install teamviewer.host -y

# Install Notepad++
choco install notepadplusplus -y

# Install 7-Zip
choco install 7zip -y

# Install Google-Chrome
choco install googlechrome -y

# Update Chocolatey
choco upgrade all -y

# Prompt for the new hostname
$newHostname = Read-Host "Enter the new hostname"

# Rename the computer
Rename-Computer -NewName $newHostname -Force

# Output a message
Write-Host "Chocolatey and selected applications have been installed."
# Install each application in the list
foreach ($app in $applications) {
    Install-Application -AppName $app.Name -DownloadUrl $app.Url -InstallerArgs $app.Args
}

# Retrieve and display the Windows product key
Get-WindowsProductKey

# Show the current IP address at the end
ipconfig

Write-Host "All tasks completed successfully."