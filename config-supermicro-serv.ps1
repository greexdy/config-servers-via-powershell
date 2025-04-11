# het installeren van SNMP
function Install-SNMP {
    Write-Host "SNMP feature installeren..."
    if (Add-WindowsCapability -Online -Name "SNMP.Client~~~~0.0.1.0") {
        # For Windows Server
        Install-WindowsFeature -Name "SNMP" -IncludeManagementTools
    } else {
        # For Windows 10/11
        Add-WindowsCapability -Online -Name "SNMP.Client~~~~0.0.1.0"
    }
    Write-Host "SNMP feature is geïnstalleerd."
}

# Function voor de Windows product key te vinden
function Get-WindowsProductKey {
    Write-Host "waar staat die windows code nu..."
    $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    if ($key) {
        Write-Host "Windows Product Key: $key"
    } else {
        Write-Host "sorry ik kon de windows code niet vinden."
    }
}

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

# Install Chocolatey (for other packages)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Direct install Google Chrome
Write-Host "Installing Google Chrome..."
winget install google.chrome

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
choco upgrade all -y

# Output messages
Write-Host "Software installations completed."

# Herstarten
$restart = Read-Host "Herstarten om alle wijzigingen door te voeren? (J/N)"
if ($restart -eq "Ja" -or $restart -eq "j") {
  Restart-Computer -Confirm
} else {
  Write-Host "Herstart later handmatig om hostnaam en auto-login te activeren." -ForegroundColor Yellow
}

# Retrieve and display the Windows product key
Get-WindowsProductKey

# Show the current IP address at the end
ipconfig

Write-Host "alles is succelvol geïnstalleerd"