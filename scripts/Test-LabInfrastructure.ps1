# Test-LabInfrastructure.ps1 — n'effectue aucune modification (lecture seule, 21 contrôles)
# Usage : Set-ExecutionPolicy -Scope Process Bypass ; .\Test-LabInfrastructure.ps1
$Domaine='labo.local'; $Zone='labo.local'; $Etendue='192.168.10.0'
$IpDC='192.168.10.10'; $IpPoste='192.168.10.150'
$OuOrdinateurs='OU=Ordinateurs-LABO,OU=LABO,DC=labo,DC=local'
$Gpo='GPO-Banniere-Connexion'; $Groupe='GG-Employes'
$resultats=@()

function Test-Controle {
    param([string]$Nom,[scriptblock]$Test)
    try { $ok=[bool](& $Test) } catch { $ok=$false }
    $etat= if($ok){'OK'}else{'ECHEC'}
    Write-Host ("[{0,-5}] {1}" -f $etat,$Nom) -ForegroundColor $(if($ok){'Green'}else{'Red'})
    $script:resultats += [pscustomobject]@{Controle=$Nom;Etat=$etat}
}

Write-Host "`n=== Vérification du laboratoire $Domaine ===`n" -ForegroundColor Cyan
# Active Directory
Test-Controle "Domaine $Domaine joignable"            { (Get-ADDomain).DNSRoot -eq $Domaine }
Test-Controle "OU Ordinateurs-LABO présente"          { Get-ADOrganizationalUnit -Identity $OuOrdinateurs }
Test-Controle "PC-01 dans Ordinateurs-LABO"           { (Get-ADComputer PC-01).DistinguishedName -like "*$OuOrdinateurs" }
Test-Controle "Groupe $Groupe non vide"               { (Get-ADGroupMember $Groupe).Count -ge 1 }
Test-Controle "Compte krbtgt désactivé (normal)"      { -not (Get-ADUser krbtgt).Enabled }
Test-Controle "wilfrid.admin dans Admins du domaine"  { Get-ADGroupMember 'Admins du domaine' | Where-Object SamAccountName -eq 'wilfrid.admin' }
# DNS
Test-Controle "Service DNS démarré"                   { (Get-Service DNS).Status -eq 'Running' }
Test-Controle "A srv-dc01 = $IpDC"                    { (Resolve-DnsName "srv-dc01.$Zone" -Type A -Server $IpDC).IPAddress -contains $IpDC }
Test-Controle "A PC-01 = $IpPoste"                    { (Resolve-DnsName "pc-01.$Zone" -Type A -Server $IpDC).IPAddress -contains $IpPoste }
Test-Controle "SRV du contrôleur de domaine"          { Resolve-DnsName "_ldap._tcp.dc._msdcs.$Zone" -Type SRV -Server $IpDC }
Test-Controle "Zone inverse présente"                 { Get-DnsServerZone -Name '10.168.192.in-addr.arpa' }
# DHCP
Test-Controle "Service DHCP démarré"                  { (Get-Service DHCPServer).Status -eq 'Running' }
Test-Controle "Étendue active"                        { (Get-DhcpServerv4Scope -ScopeId $Etendue).State -eq 'Active' }
Test-Controle "Option 003 = 192.168.10.1"             { (Get-DhcpServerv4OptionValue -ScopeId $Etendue -OptionId 3).Value -contains '192.168.10.1' }
Test-Controle "Option 006 = $IpDC"                    { (Get-DhcpServerv4OptionValue -ScopeId $Etendue -OptionId 6).Value -contains $IpDC }
Test-Controle "Réservation PC-01 = $IpPoste"          { (Get-DhcpServerv4Reservation -ScopeId $Etendue).IPAddress.IPAddressToString -contains $IpPoste }
Test-Controle "Serveur DHCP autorisé dans l'AD"       { Get-DhcpServerInDC | Where-Object IPAddress -eq $IpDC }
# GPO
Test-Controle "$Gpo existe"                           { Get-GPO -Name $Gpo }
Test-Controle "$Gpo liée à Ordinateurs-LABO"          { (Get-GPInheritance -Target $OuOrdinateurs).GpoLinks.DisplayName -contains $Gpo }
# Temps
Test-Controle "Service de temps démarré"              { (Get-Service w32time).Status -eq 'Running' }
Test-Controle "Fuseau horaire Paris"                  { (Get-TimeZone).Id -eq 'Romance Standard Time' }

$echecs=($resultats | Where-Object Etat -eq 'ECHEC').Count
Write-Host ("`nBilan : {0} contrôles, {1} échec(s)`n" -f $resultats.Count,$echecs) -ForegroundColor $(if($echecs -eq 0){'Green'}else{'Yellow'})
