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



# Stap 1: Hostnaam wijzigen
$newHostname = Read-Host "Voer de nieuwe hostnaam in (bijv. 'MyPC')"
if ($newHostname -ne "") {
  try {
    Rename-Computer -NewName $newHostname -Force -ErrorAction Stop
    Write-Host "Hostnaam succesvol gewijzigd naar $newHostname (vereist herstart)." -ForegroundColor Green
  } catch {
    Write-Host "Fout bij wijzigen hostnaam: $_" -ForegroundColor Red
  }
}

# Enable Remote Desktop 
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# Configure firewall rules
Write-Host "Configuring firewall rules..."

# Allow Remote Desktop connections
New-NetFirewallRule -DisplayName "Remote Desktop" `
    -Enabled True `
    -Direction Inbound `
    -Protocol TCP `
    -Action Allow `
    -LocalPort 3389

# Allow ICMP (Ping) for IPv4 and IPv6
New-NetFirewallRule -DisplayName "Allow Inbound ICMPv4 Echo Request" `
    -Protocol ICMPv4 `
    -IcmpType 8 `
    -Enabled True `
    -Profile Any `
    -Action Allow

New-NetFirewallRule -DisplayName "Allow Inbound ICMPv6 Echo Request" `
    -Protocol ICMPv6 `
    -IcmpType 128 `
    -Enabled True `
    -Profile Any `
    -Action Allow

# Main script execution
Install-SNMP

# Add the new user
Add-NewUser   

# Set auto login for the new user
Set-AutoLogin


# Install Chocolatey (for other packages)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Direct install Google Chrome
Write-Host "Installing Google Chrome..."
$chromeUrl = "https://dl.google.com/chrome/install/standalonesetup.exe"
$chromeInstaller = "$env:TEMP\chrome_installer.exe"
Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller
Start-Process -FilePath $chromeInstaller -Args "/silent /install" -Wait
Remove-Item $chromeInstaller

# Direct install TeamViewer Host
Write-Host "Installing TeamViewer Host..."
$tvUrl = "https://download.teamviewer.com/download/TeamViewer_Host_Setup.exe"
$tvInstaller = "$env:TEMP\teamviewer_host.exe"
Invoke-WebRequest -Uri $tvUrl -OutFile $tvInstaller
Start-Process -FilePath $tvInstaller -Args "/S /norestart" -Wait
Remove-Item $tvInstaller

# Chocolatey packages (Notepad++ and 7-Zip)
choco install notepadplusplus -y
choco install 7zip -y
choco install googlechrome -y
choco upgrade all -y

# Output messages
Write-Host "Software installations completed."

# Herstarten
$restart = Read-Host "Herstarten om alle wijzigingen door te voeren? (J/N)"
if ($restart -eq "J" -or $restart -eq "j") {
  Restart-Computer -Confirm
} else {
  Write-Host "Herstart later handmatig om hostnaam en auto-login te activeren." -ForegroundColor Yellow
}

# Retrieve and display the Windows product key
Get-WindowsProductKey

# Show the current IP address at the end
ipconfig

Write-Host "alles is succelvol geïnstalleerd"