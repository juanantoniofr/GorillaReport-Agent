<#
.SYNOPSIS
    Registra pc_client en el servidor gorillaReport
.DESCRIPTION
    Registra pc_client en el servidor gorillaReport. Para ello primero obtiene el token de acceso a la API y luego registra el pc_client.
.NOTES
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2023-03-03
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>

# Variables
$ip_pattern = "172."
$gr_module = "GRModule"
$this_script = "register_client.ps1"

# Importamos el módulo de scripts de gorillaReport
try {
    $GRModule = Import-Module -Name $gr_module -AsCustomObject -Force -ErrorAction stop -Passthru
    #Console debug: lista de propiedades y métodos del módulo
    Write-Host "Módulo de scripts de gorillaReport importado"
    #$GRModule | Get-Member
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al importar el módulo de scripts de gorillaReport"
    Write-Host $_.Exception.Message
    exit 1
}

# Verificar si el modulo CimCmdlets estÃ¡ disponible
if (-not(Get-Module -Name CimCmdlets)) {
    try {
        # Importar el modulo CimCmdlets si no estÃ¡ disponible
        Import-Module CimCmdlets -ErrorAction Stop
    }
    catch {
        Write-Error "No se pudo importar el mÃ³dulo CimCmdlets. Error: $($_.Exception.Message)"
        exit 1
    }
}


# Informacion del PC
$ipAddress = ((Get-NetIPConfiguration).IPv4Address.IPAddress | Select-String -Pattern $ip_pattern).toString().Trim()
$huid=(Get-CimInstance Win32_ComputerSystemProduct).UUID
$name = $env:COMPUTERNAME

# Creamos objeto JSON
$jsonData = @{
    ip=$ipAddress
    huid=$huid
    name=$name    
}
# Guardamos a fichero
$json_file_log = $GRModule.reports_dir + "\register_info.json"
try {
    $jsonData | ConvertTo-Json | Out-File -FilePath $json_file_log -Encoding UTF8
    Write-Host "Fichero JSON con la informacion del sistema guardado en $json_file_log"
    Add-Content -Path $GRModule.log_file -Value "INFO ($DATE) - $this_script -: Fichero JSON con la informacion del sistema guardado en $json_file_log" 
}
catch {
    <# Do this if a terminating exception happens #>
    Write-Host "Error al guardar el fichero JSON en $json_file_log"
    Write-Host $_.Exception.Message
    Add-Content -Path $GRModule.log_file -Value "ERROR ($DATE) - $this_script -: Error al guardar el fichero JSON en $json_file_log"
    #exit 1 
}


# Obtenemos el token de acceso
$token = $GRModule.GetAccessToken($GRModule.login_uri)

# Si no hay token de acceso salimos
if ($null -eq $token) {
    #Debug: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $GRModule.log_file -Value "ERROR ($DATE) - $this_script -: No se ha podido obtener el token de acceso a la API"
    Write-Host "No se ha podido obtener el token de acceso a la API"
    exit 1
}
else{
    #Debug: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $GRModule.log_file -Value "INFO ($DATE) - $this_script -: Token de acceso a la API obtenido"
    Write-Host "Token de acceso a la API obtenido"
}

# Enviamos la informacion del sistema a gorillaReport webapp
$result = $(pwsh.exe -File $GRModule.ps_file_for_send_reports_with_pwsh -token $token.access_token -logfile $json_file_log -uri $GRModule.register_pc_uri)

# logs
Write-Host "gorillareport webapp response: "  $result

# DEBUG: escribir en el fichero de logs
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $GRModule.log_file -Value "INFO: $DATE - $this_script - : gorillareport webapp response ->  $result" 
exit 0
