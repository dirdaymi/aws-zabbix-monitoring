# Script PowerShell pour installer Zabbix Agent sur Louki-Client-Windows
# À exécuter en tant qu'Administrateur

Write-Host "==========================================" -ForegroundColor Green
Write-Host "INSTALLATION ZABBIX AGENT - Louki-Client-Windows" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Configuration
$ZabbixServer = "10.0.1.249"
$Hostname = "Louki-Client-Windows"
$DownloadURL = "https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.43/zabbix_agent2-6.0.43-windows-amd64-openssl.msi"
$InstallerPath = "$env:TEMP\zabbix_agent2.msi"

# Téléchargement
Write-Host "1. Téléchargement de l'agent Zabbix..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallerPath
    Write-Host "   ✓ Téléchargement réussi" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Erreur de téléchargement: $_" -ForegroundColor Red
    exit 1
}

# Installation
Write-Host "2. Installation en cours..." -ForegroundColor Yellow
$InstallArgs = "/i " /quiet /norestart SERVER=$ZabbixServer HOSTNAME=$Hostname"
Start-Process msiexec.exe -Wait -ArgumentList $InstallArgs

# Vérification du service
Write-Host "3. Vérification de l'installation..." -ForegroundColor Yellow
$Service = Get-Service "Zabbix Agent 2" -ErrorAction SilentlyContinue
if ($Service) {
    Write-Host "   ✓ Service Zabbix Agent 2 trouvé" -ForegroundColor Green
    Write-Host "   Status: $($Service.Status)" -ForegroundColor Cyan
} else {
    Write-Host "   ✗ Service Zabbix Agent 2 non trouvé" -ForegroundColor Red
}

# Création du fichier de configuration personnalisé
Write-Host "4. Configuration personnalisée..." -ForegroundColor Yellow
$ConfigContent = @"
# Configuration Zabbix Agent 2 - Louki-Client-Windows
LogFile=C:\Program Files\Zabbix Agent 2\zabbix_agent2.log
Server=${ZabbixServer}
ServerActive=${ZabbixServer}
Hostname=${Hostname}
"@

$ConfigContent | Out-File -FilePath "C:\Program Files\Zabbix Agent 2\zabbix_agent2_louki.conf" -Encoding UTF8
Write-Host "   ✓ Fichier de configuration créé" -ForegroundColor Green

Write-Host "==========================================" -ForegroundColor Green
Write-Host "INSTALLATION TERMINÉE" -ForegroundColor Green
Write-Host "Hostname: $Hostname" -ForegroundColor Cyan
Write-Host "Serveur Zabbix: $ZabbixServer" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Green
