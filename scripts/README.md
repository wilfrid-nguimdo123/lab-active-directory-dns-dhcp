# Scripts PowerShell

| Script | Machine | Rôle | Modifie le système |
| --- | --- | --- | --- |
| [`1-Install-DC.ps1`](1-Install-DC.ps1) | SRV-DC01 | IP fixe, fuseau, renommage, rôles, création de la forêt `labo.local` | Oui |
| [`2-Config-Reseau.ps1`](2-Config-Reseau.ps1) | SRV-DC01 | Zone DNS inverse, DHCP (autorisation, étendue, options, réservation), source de temps | Oui |
| [`3-Config-AD-GPO.ps1`](3-Config-AD-GPO.ps1) | SRV-DC01 | OU, utilisateurs, groupe, privilèges, GPO bannière | Oui |
| [`4-Join-PC01.ps1`](4-Join-PC01.ps1) | PC-01 | Renommage et jonction au domaine | Oui |
| [`Test-LabInfrastructure.ps1`](Test-LabInfrastructure.ps1) | SRV-DC01 | 21 contrôles de l'état final | **Non** (lecture seule) |

> ⚠️ Le déploiement du lab a été réalisé via les consoles graphiques. Les scripts 1 à 4 en sont l'équivalent PowerShell, écrit après coup : ils **n'ont pas été exécutés de bout en bout** sur ce lab. Testez-les sur un snapshot avant de vous en servir.

- Lancer chaque script dans PowerShell **en administrateur**.
- Les mots de passe sont demandés à l'exécution (`Read-Host -AsSecureString`, `Get-Credential`) et ne sont **jamais écrits** dans les scripts.
- Les fichiers sont encodés en UTF-8 avec BOM pour que Windows PowerShell 5.1 lise correctement les accents.
