# 06 – Fiche mémo

[← Retour au README](../README.md)

## Méthode de dépannage

**IP → réseau → DNS → contrôleur de domaine → heure → GPO → preuve Wireshark.**
En Active Directory, quand rien ne marche, regardez d'abord le DNS.

## Commandes utiles

| Besoin | Commande |
| --- | --- |
| Configuration IP complète | `ipconfig /all` |
| Renouveler le bail DHCP | `ipconfig /release` puis `ipconfig /renew` |
| Vider le cache DNS | `ipconfig /flushdns` |
| Réenregistrer sa fiche DNS | `ipconfig /registerdns` (à lancer **sur la machine concernée**) |
| Tester la résolution | `nslookup srv-dc01.labo.local` |
| Trouver un contrôleur de domaine | `nltest /dsgetdc:labo.local /force` |
| Mesurer l'écart d'horloge | `w32tm /stripchart /computer:srv-dc01.labo.local /samples:3 /dataonly` |
| Resynchroniser l'heure | `w32tm /resync /force` |
| Voir / purger les tickets Kerberos | `klist` / `klist purge` |
| Appliquer les GPO | `gpupdate /force` |
| GPO appliquées (invite élevée) | `gpresult /r /scope computer` |
| Utilisateur courant | `whoami` |
| Redirection des nouveaux ordinateurs | `redircmp "OU=Ordinateurs-LABO,OU=LABO,DC=labo,DC=local"` |

## Ports à connaître

| Service | Port |
| --- | --- |
| DNS | 53 UDP/TCP |
| DHCP | 67 UDP (serveur), 68 UDP (client) |
| Kerberos | 88 UDP/TCP |
| NTP (W32Time) | 123 UDP |
| RPC | 135 TCP |
| LDAP | 389 UDP/TCP |
| SMB | 445 TCP |
| LDAPS | 636 TCP |
| Catalogue global | 3268 TCP |

## Événements Windows à surveiller (SOC)

| ID | Journal | Signification |
| --- | --- | --- |
| 516 | DNS Server / Audit | Enregistrement DNS supprimé |
| 4625 | Sécurité | Échec d'ouverture de session |
| 4724 | Sécurité | Réinitialisation de mot de passe |
| 4728 | Sécurité | Ajout d'un membre à un groupe global de sécurité |
| 4740 | Sécurité | Compte verrouillé |
| 4771 | Sécurité (DC) | Échec de pré-authentification Kerberos (code `0x25` = décalage d'horloge) |
| 7036 | Système | Changement d'état d'un service (arrêt / démarrage) |

## Repères DHCP (DORA)

**D**iscover (client, broadcast) → **O**ffer (serveur) → **R**equest (client) → **A**CK (serveur).
Sans réponse, le client réessaie à intervalles croissants puis s'attribue une adresse APIPA `169.254.x.x/16`.

## Repères Kerberos

Tolérance d'horloge par défaut : **5 minutes**. Un écart supérieur ne bloque pas immédiatement une session ouverte (tickets en cache), mais fait échouer le renouvellement des tickets.
