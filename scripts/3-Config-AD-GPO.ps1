# 3-Config-AD-GPO.ps1 — annuaire et GPO (SRV-DC01)
# Équivalent PowerShell du déploiement réalisé à la souris : à tester sur un snapshot.
Import-Module ActiveDirectory, GroupPolicy
$Racine = "DC=labo,DC=local"
$OuLabo = "OU=LABO,$Racine"

# --- Unités d'organisation ---
New-ADOrganizationalUnit -Name "LABO" -Path $Racine
"Utilisateurs-LABO","Ordinateurs-LABO","Groupes-LABO" |
    ForEach-Object { New-ADOrganizationalUnit -Name $_ -Path $OuLabo }

# Les futurs PC joints au domaine iront directement dans la bonne OU (au lieu de "Computers")
redircmp "OU=Ordinateurs-LABO,$OuLabo"

# --- Utilisateurs ---
$OuUsers = "OU=Utilisateurs-LABO,$OuLabo"
$Comptes = @(
    @{Prenom="Alice";   Nom="Martin"; Login="alice.martin"},
    @{Prenom="Bob";     Nom="Durand"; Login="bob.durand"},
    @{Prenom="Wilfrid"; Nom="Admin";  Login="wilfrid.admin"}
)
foreach ($c in $Comptes) {
    New-ADUser -Name "$($c.Prenom) $($c.Nom)" -GivenName $c.Prenom -Surname $c.Nom `
        -SamAccountName $c.Login -UserPrincipalName "$($c.Login)@labo.local" `
        -Path $OuUsers -Enabled $true -ChangePasswordAtLogon $false `
        -AccountPassword (Read-Host -AsSecureString "Mot de passe pour $($c.Login)")
}

# --- Groupe et privilèges ---
New-ADGroup -Name "GG-Employes" -GroupScope Global -GroupCategory Security -Path "OU=Groupes-LABO,$OuLabo"
Add-ADGroupMember -Identity "GG-Employes" -Members alice.martin, bob.durand
Add-ADGroupMember -Identity "Admins du domaine" -Members wilfrid.admin   # (Domain Admins en anglais)

# --- GPO bannière de connexion ---
$Gpo = "GPO-Banniere-Connexion"
$Cle = "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System"
New-GPO -Name $Gpo -Comment "Bannière légale avant ouverture de session" |
    New-GPLink -Target "OU=Ordinateurs-LABO,$OuLabo" -LinkEnabled Yes
Set-GPRegistryValue -Name $Gpo -Key $Cle -ValueName "legalnoticecaption" -Type String `
    -Value "Avertissement – Système LABO"
Set-GPRegistryValue -Name $Gpo -Key $Cle -ValueName "legalnoticetext" -Type String `
    -Value "Accès réservé aux personnes autorisées. Toute connexion est journalisée."
