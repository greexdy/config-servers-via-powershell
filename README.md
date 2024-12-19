# Windows Host Configuration Script

Dit PowerShell-script is ontworpen om Windows-hosts automatisch te configureren volgens specifieke richtlijnen. Het vereenvoudigt en automatiseert taken zoals het instellen van systeemeigenschappen, het configureren van netwerkinstellingen, en het toepassen van beveiligingsbeleid.

## Features

- Installeren van noodzakelijke software of updates.
- installeren van nodige extra features
- Configureren van gebruikersaccounts en machtigingen.
- het aanmaken van een CCTV user.
- het toevoegen van de CCTV user aan de default Users group.
- auto login instellen voor de CCTV user.
- het aanzetten van RDP.
- 

## Vereisten

- Windows 10/11 of Windows Server 2016/2019/2022.
- PowerShell 5.1 of hoger.
- om dit script uit te voeren hoort u ADMIN te zijn!!:
  ```powershell
  set-ExecutionPolicy Bypass -Scope Process -Force

