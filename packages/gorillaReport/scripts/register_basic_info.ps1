<#
.SYNOPSIS
    Obtiene información básica del sistema
.DESCRIPTION
    Obtiene información básica del sistema y la envía a gorillaReport webapp. Esta información contiene el procesador, la memoria RAM instalada, el tipo de sistema (32 o 64 bits), la versión de Windows, el número de compilación y la fecha de instalación.
    Funciones:
        - Export-SystemInfo: obtiene la información del sistema y la guarda en un archivo JSON.
.NOTES
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2023-04-07
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>
# aquí empieza el script
# variables
$gr_module = "GRModule"
$this_script = "register_basic_info.ps1"

# Importamos el módulo de scripts de gorillaReport
try {
    $GRModule = Import-Module -Name $gr_module -AsCustomObject -Force -ErrorAction stop -Passthru
    Write-Host "Módulo de scripts de gorillaReport importado"
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al importar el módulo de scripts de gorillaReport"
    Write-Host $_.Exception.Message
    exit 1
}

# Verificar si el módulo CimCmdlets está disponible
if (-not(Get-Module -Name CimCmdlets)) {
    try {
        # Importar el módulo CimCmdlets si no está disponible
        Import-Module CimCmdlets -ErrorAction Stop
    }
    catch {
        Write-Error "No se pudo importar el módulo CimCmdlets. Error: $($_.Exception.Message)"
        exit 1
    }
}

# Obtiene la información del sistema y la guarda en un archivo JSON
function Get-SystemInfo {

    # Obtiene la información del sistema
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $cpuInfo = Get-CimInstance Win32_Processor
    $memoryInfo = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum

    # Crea el objeto JSON
    $jsonObj = @{
        SystemInfo = @{
            Processor = $cpuInfo.Name
            RAMInstalledGB = [math]::Round($memoryInfo.Sum / 1GB, 2)
            SystemType = $osInfo.OSArchitecture
        }
        WindowsInfo = @{
            Version = $osInfo.Version
            Build = $osInfo.BuildNumber
            InstallDate = $osInfo.InstallDate
            OSName = $osInfo.Caption
        }
    }

    return $jsonObj
}

# Obtenemos la información del sistema y lo guardamos en un fichero JSON
$jsonData = Get-SystemInfo
$json_file_log = $GRModule.reports_dir + "\basic_info.json"
try {
    #Set-Content -Path $json_file_log -Value $jsonData
    $jsonData | ConvertTo-Json | Out-File -FilePath $json_file_log -Encoding UTF8
 
    Write-Host "Fichero JSON con la información del sistema guardado en $json_file_log"
    Add-Content -Path $GRModule.log_file -Value "INFO ($DATE) - $this_script -: Fichero JSON con la información del sistema guardado en $json_file_log" 
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al guardar el fichero JSON en $json_file_log"
    Write-Host $_.Exception.Message
    Add-Content -Path $GRModule.log_file -Value "ERROR ($DATE) - $this_script -: Error al guardar el fichero JSON en $json_file_log"
    exit 1 
}

# Obtenemmos el token de acceso a la API
$token = $GRModule.GetAccessToken($GRModule.login_uri)
#si no hay token de acceso salimos
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

# Enviamos la información del sistema a gorillaReport webapp
$result = $(pwsh.exe -File $GRModule.ps_file_for_send_reports_with_pwsh -token $token.access_token -logfile $json_file_log -uri $GRModule.udpate_basic_info_uri)

# logs
Write-Host "gorillareport webapp response: "  $result
#DEBUG: escribir en el fichero de logs
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $GRModule.log_file -Value "INFO: $DATE - $this_script - : gorillareport webapp response ->  $result" 
exit 0