# 2-Config-Reseau.ps1 — DNS, DHCP et temps (SRV-DC01, après la promotion)
# Équivalent PowerShell du déploiement réalisé à la souris : à tester sur un snapshot.

# --- DNS : zone inverse + enregistrement PTR du serveur ---
Add-DnsServerPrimaryZone -NetworkId "192.168.10.0/24" -ReplicationScope Domain -DynamicUpdate Secure
ipconfig /registerdns

# --- DHCP : autorisation dans l'AD + groupes de sécurité DHCP ---
Add-DhcpServerInDC -DnsName "srv-dc01.labo.local" -IPAddress 192.168.10.10
netsh dhcp add securitygroups
Restart-Service DHCPServer
# Masque l'avertissement "configuration post-installation" du Gestionnaire de serveur
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12" -Name ConfigurationState -Value 2

# --- DHCP : étendue, exclusion, options, réservation ---
Add-DhcpServerv4Scope -Name "LAN-LABO" -StartRange 192.168.10.100 -EndRange 192.168.10.200 `
    -SubnetMask 255.255.255.0 -LeaseDuration 8.00:00:00 -State Active
Add-DhcpServerv4ExclusionRange -ScopeId 192.168.10.0 -StartRange 192.168.10.100 -EndRange 192.168.10.109
Set-DhcpServerv4OptionValue -ScopeId 192.168.10.0 `
    -Router 192.168.10.1 -DnsServer 192.168.10.10 -DnsDomain "labo.local"
Add-DhcpServerv4Reservation -ScopeId 192.168.10.0 -IPAddress 192.168.10.150 `
    -ClientId "08-00-27-8C-A1-86" -Name "PC-01" -Description "Poste utilisateur test"

# --- Temps : le DC devient la référence du domaine ---
w32tm /config /reliable:yes /syncfromflags:manual /update
Restart-Service w32time
