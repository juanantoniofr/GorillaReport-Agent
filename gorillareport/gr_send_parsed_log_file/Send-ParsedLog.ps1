# aquí empieza el script
# Importamos el módulo de scripts de gorillaReport

..\gr_add_module_to_path\Add-GRModuleToPath.ps1 -Wait -NoNewWindow

try {
    $GRModule = Import-Module -Name "GRModule" -AsCustomObject -Force -ErrorAction stop -Passthru
    #Console debug: lista de propiedades y métodos del módulo
    Write-Host "Módulo de scripts de gorillaReport importado"
    #$GRModule | Get-Member
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al importar el módulo de scripts de gorillaReport"
    Write-Host $env:PSModulePath
    Write-Host $_.Exception.Message
    exit 0
}

# variables
$this_script = "Send-ParsedLog.ps1"
$json_file_log = $GRModule.gorilla_log_file_json_format

#Código
#Leemos el fichero de log en formato json
$jsonString = Get-Content -Path $json_file_log -Raw
$jsonObject = $jsonString | ConvertTo-Json

Write-Host $jsonString
Write-Host $jsonObject
exit 0
#DEBUG: escribir en el fichero de logs
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
if ($null -eq $jsonString) {
    Write-Host "Error: no se ha podido leer el fichero de log en formato json"
    Add-Content -Path $GRModule.log_file -Value "$DATE - $this_script - : Error: no se ha podido leer el fichero de log en formato json"
    exit 1
}
else {
    Write-Host "Fichero de log en formato json leido correctamente"
    Add-Content -Path $GRModule.log_file -Value "$DATE - $this_script - : Fichero de log en formato json leido correctamente"
}

# Obtenemmos el token de acceso a la API
$token = $GRModule.GetAccessToken($GRModule.login_uri)
#enviamos el reporte a la api de gorillaReport
#$result = $GRModule.PushReport($token,$jsonString)
#$result = $GRModule.PushReport($token,$jsonObject)
$result = PushReport -token $token -report $jsonObject
Write-Host "gorillareport webapp response: " $result.message
#DEBUG: escribir en el fichero de logs
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $GRModule.log_file -Value "$DATE - $this_script - : gorillareport webapp response: -> $result.message"
exit 0