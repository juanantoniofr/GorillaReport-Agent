<#
.SYNOPSIS
    Obtiene información básica del sistema
.DESCRIPTION
    Obtiene información básica del sistema y la guarda en un archivo JSON. Esta información contiene el procesador, la memoria RAM instalada, el tipo de sistema (32 o 64 bits), la versión de Windows, el número de compilación y la fecha de instalación.
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
$this_script = "Get-BasicInformation.ps1"

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

    # Convierte el objeto JSON en formato JSON y lo guarda en un archivo
    $jsonString = $jsonObj | ConvertTo-Json
    return $jsonString
}

# Obtenemos la información del sistema
$basicInformation = Get-SystemInfo

# Obtenemmos el token de acceso a la API
$token = $GRModule.GetAccessToken($GRModule.login_uri)
#si no hay token de acceso salimos
if ($token -eq $null) {
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

# Añadimos información básica a la BD de gorillaReport webapp
$result = $GRModule.AddBasicInformation($token, $basicInformation, $GRModule.set_basic_info_uri)

#Write-Host $this_script " - " $result
#si no se ha podido añadir la información básica salimos
if( $null -eq $result ){
    #Debug: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $GRModule.log_file -Value "ERROR ($DATE) - $this_script -: No se ha podido añadir la información básica a la BD de gorillaReport webapp"
    Write-Host "No se ha podido añadir la información básica a la BD de gorillaReport webapp"
    exit 1
}
else{
    #Debug: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $GRModule.log_file -Value "INFO ($DATE) - $this_script -: Información básica añadida a la BD de gorillaReport webapp"
    Write-Host "Información básica añadida a la BD de gorillaReport webapp"
    Write-Host $result
}