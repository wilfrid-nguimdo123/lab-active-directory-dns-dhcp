# 4-Join-PC01.ps1 — PC-01 doit avoir reçu son adresse et le DNS 192.168.10.10 par DHCP
# Équivalent PowerShell du déploiement réalisé à la souris : à tester sur un snapshot.
tzutil /s "Romance Standard Time"
Rename-Computer -NewName PC-01 -Restart

# Après redémarrage :
Add-Computer -DomainName "labo.local" `
    -OUPath "OU=Ordinateurs-LABO,OU=LABO,DC=labo,DC=local" `
    -Credential (Get-Credential "LABO\wilfrid.admin") -Restart

# Après redémarrage, connecté en LABO\alice.martin :
whoami                                  # → labo\alice.martin
# En invite ADMINISTRATEUR :
gpupdate /force
gpresult /r /scope computer             # → GPO-Banniere-Connexion appliquée
