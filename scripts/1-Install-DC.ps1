# 1-Install-DC.ps1 — à lancer en 2 temps (le renommage redémarre la machine)
# Équivalent PowerShell du déploiement réalisé à la souris : à tester sur un snapshot.

# --- Partie A : identité et réseau ---
$Carte = (Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1).Name
New-NetIPAddress -InterfaceAlias $Carte -IPAddress 192.168.10.10 -PrefixLength 24 -DefaultGateway 192.168.10.1
Set-DnsClientServerAddress -InterfaceAlias $Carte -ServerAddresses 127.0.0.1
tzutil /s "Romance Standard Time"
Rename-Computer -NewName SRV-DC01 -Restart

# --- Partie B (après redémarrage) : rôles et promotion ---
Install-WindowsFeature AD-Domain-Services, DNS, DHCP -IncludeManagementTools

Install-ADDSForest `
    -DomainName "labo.local" `
    -DomainNetbiosName "LABO" `
    -InstallDns `
    -SafeModeAdministratorPassword (Read-Host -AsSecureString "Mot de passe DSRM") `
    -Force
# Le serveur redémarre automatiquement en contrôleur de domaine.
