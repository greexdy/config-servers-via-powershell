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

# Enable Automatic Login for CCTV User on Windows 11

# Set DevicePasswordLessBuildVersion to 0 in the registry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" -Name "DevicePasswordLessBuildVersion" -Value 0

# Function to disable password prompt at login
function Enable-AutoLogin {
    param (
        [string]$Username,
        [string]$Password
    )

    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    # Set DefaultUserName and DefaultPassword
    Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $Username
    Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $Password
    Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
}

# Define CCTV user credentials
$username = "CCTV"
$password = "cctv"  # Replace with the actual password

# Enable automatic login for CCTV user
Enable-AutoLogin -Username $username -Password $password

Write-Output "Automatic login has been enabled for user $username. Restart your computer to apply the changes."


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

# Install Git
choco install teamviewer.host -y

# Install Notepad++
choco install notepadplusplus -y

# Install 7-Zip
choco install 7zip -y

# Install Google Chrome
choco install googlechrome -y

# Update Chocolatey
choco upgrade all -y

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