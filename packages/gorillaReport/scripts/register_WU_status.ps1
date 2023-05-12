# Importar módulo de Windows Update
Import-Module -Name PSWindowsUpdate

# Obtener actualizaciones
$updates = Get-WindowsUpdate -NotCategory 'Drivers' #| Where-Object {$_.UpdateType -match 'Critical|Important' -and $_.IsInstalled -eq $false}

# Mostrar informacion de actualizaciones
if ($updates) {
    Write-Host 'Las siguientes actualizaciones críticas e importantes no se han aplicado:'
    $updates | Select-Object Title,KB,UpdateType,Description | ConvertTo-Json

}

