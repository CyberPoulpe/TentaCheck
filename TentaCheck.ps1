$Server = "VOTRE-SERVEUR-WSUS"
$Port = 8530
$Days = 60
$Delay = 5
$Limit = 15

Import-Module UpdateServices

# Connexion WSUS
try {
    $Wsus = Get-WsusServer -Name $Server -PortNumber $Port
    Write-Host "[OK] Connecté à $Server:$Port" -ForegroundColor Green
} catch {
    Write-Error "Échec de la connexion WSUS : $_"
    return
}

# Scope de recherche
$Scope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$Scope.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::NotApproved

Write-Host "[...] Requête WSUS en cours (non approuvés)..." -ForegroundColor Cyan
try {
    $Updates = $Wsus.GetUpdates($Scope)
} catch {
    Write-Error "Erreur lors de la récupération des mises à jour : $_"
    return
}

# Filtrage temporel et dédoublonnement
$CutoffDate = (Get-Date).AddDays(-$Days)
Write-Host "[INFO] Filtre de date : >= $($CutoffDate.ToString('dd/MM/yyyy'))" -ForegroundColor Yellow

$FoundKBs = @()
$KBToTitles = @{}

foreach ($Update in $Updates) {
    if (-not $Update.IsDeclined -and $Update.CreationDate -ge $CutoffDate) {
        if ($Update.Title -match 'KB\d{6,8}') {
            $KB = $Matches[0]
            if ($KB -notin $FoundKBs) {
                $FoundKBs += $KB
                $KBToTitles[$KB] = $Update.Title
            }
        }
    }
}

if ($FoundKBs.Count -eq 0) {
    Write-Host "[!] Aucun KB non approuvé trouvé sur les $Days derniers jours." -ForegroundColor Red
    return
}

Write-Host "`n[+] $($FoundKBs.Count) KB uniques identifiés :" -ForegroundColor Green
Write-Host "--------------------------------------------------"
foreach ($KB in $FoundKBs) {
    Write-Host " - $KB : $($KBToTitles[$KB])" -ForegroundColor Gray
}
Write-Host "--------------------------------------------------"

# Demande d'ouverture
Write-Host ""
$Confirm = Read-Host "Ouvrir les fiches NinjaOne pour ces $($FoundKBs.Count) KB ? (O/N)"
if ($Confirm -match '^[Oo]') {
    
    $ListToOpen = $FoundKBs
    if ($FoundKBs.Count -gt $Limit) {
        $ConfirmMass = Read-Host "Attention : $($FoundKBs.Count) fiches à ouvrir. Limiter aux $Limit premières ? (O/N)"
        if ($ConfirmMass -match '^[Oo]') {
            $ListToOpen = $FoundKBs[0..($Limit-1)]
        }
    }

    $Total = $ListToOpen.Count
    for ($i = 0; $i -lt $Total; $i++) {
        $KB = $ListToOpen[$i]
        $Url = "https://www.ninjaone.com/fr/kb-catalog/$($KB.ToLower())/"
        
        Write-Host "[$($i + 1)/$Total] Ouverture de $KB" -ForegroundColor Green
        Start-Process $Url
        
        if ($i -lt ($Total - 1)) {
            Start-Sleep -Seconds $Delay
        }
    }
}
