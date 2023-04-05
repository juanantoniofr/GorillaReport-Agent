<#
.SYNOPSIS
    Registra pc_client en el servidor gorillaReport
.DESCRIPTION
    Registra pc_client en el servidor gorillaReport. Para ello primero obtiene el token de acceso a la API y luego registra el pc_client.
    Variables de entorno:
        GR_SCRIPTS_PATH: ruta de los scripts de gorillaReport
        GR_LOGS_DIRECTORY: directorio de logs
        GR_SCRIPTS_MODULE: directorio del módulo de scripts de gorillaReport
.NOTE
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2023-03-03
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>

#aquí empieza el script

# variables
$gr_module = "GRModule.psm1"

# Importamos el módulo de scripts de gorillaReport
try {
    Import-Module $gr_module -ErrorAction SilentlyContinue
    Write-Host "Módulo de scripts de gorillaReport importado"
    Get-Module -ListAvailable -Name $gr_module    
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al importar el módulo de scripts de gorillaReport"
    Write-Host $_.Exception.Message
}

# Registra pc_client en el servidor gorillaReport
function register_pc_client {

    pwsh -Command{
        param(
            [Parameter(Mandatory=$true)]
            [string]$token,

            [Parameter(Mandatory=$true)]
            [string]$URI
        )

        $token = ConvertTo-SecureString -String $args[0] -AsPlainText -Force

        $net_ip_configuration = Get-NetIPConfiguration | Select-Object -Property Computername, IPv4Address
        
        $body = @{
            huid=(Get-CimInstance Win32_ComputerSystemProduct).UUID
            name = $net_ip_configuration.Computername
            ip = $net_ip_configuration.IPv4Address.IPAddress
            information = "{}"
        }
        
        $Params=@{
            Method = "Post"
            Uri = $URI
            Authentication = "Bearer"
            Token = $token
            SkipCertificateCheck = 1
            Body = $body
        }

        Invoke-RestMethod @Params
    
    } -args @($token, $URI)
}

#Obtenemos el token de acceso
$token = get_access_token

#Si no hay token de acceso salimos
if ( $null -eq $token ){ 
    #DEBUG: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Log -logFile $log_file -logLevel "ERROR: $DATE " -logMessage "No se ha podido obtener el token de acceso"    
    exit 0
}

#Registramos pc_client
register_pc_client $token.access_token
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Log -logFile $log_file -logLevel "INFO: $DATE " -logMessage "pc_client registrado correctamente"