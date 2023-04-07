<#
.SYNOPSIS
    Módulo de funciones de gorillaReport
.DESCRIPTION
    Módulo de funciones de gorillaReport. Contiene funciones y variables que se usan en los scripts de gorillaReport.
    Funciones: 
        - GetAccessToken: obtiene el token de acceso a la API de gorillaReport
    Variables:
        - login_uri: uri de login de la API de gorillaReport
        - register_pc_uri: uri de registro de pc_client en la API de gorillaReport
        - log_file: fichero de logs de gorillaReport
.Notes
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2023-04-02
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>

#variables
# Nombre de este módulo
$gr_module = "GRModule"
# uri api login
$login_uri = "https://gorillareport:4444/api/login"
# uri api de registro de pc_client
$register_pc_uri = "https://gorillareport:4444/api/client/register"
# uri api set basic information
$set_basic_info_uri = "https://gorillareport:4444/api/client/updateBasicInformation"
# home de usuario
$homedir = $env:USERPROFILE
# directorio de gorillaReport
$gorilladir = "gorillaReport"
# fichero de logs de gorillaReport
$log_file = "$homedir\$gorilladir\logs\gorillareport.log"

# Funciones

##########################################
# Obtiene el token API de acceso
# @return $token (String) | null
##########################################
function GetAccessToken() {

    param(
            [Parameter(Mandatory=$true)]
            [string]$uri
        )

    $result = pwsh -Command {

        $uri = $args[0]
        
        $Body = @{
            email    = "apiuser@email.com"
            password = "pass"
        }
        
        $JsonBody = $Body | ConvertTo-Json
        
        $Params = @{
            Method               = "Post"
            Uri                  = $uri
            Body                 = $JsonBody
            ContentType          = "application/json"
            SkipCertificateCheck = 1
        }

        #Invoke-RestMethod @Params |  Select-Object -Property access_token
        try {
            $response = Invoke-RestMethod @Params
            $result = $response#.access_token
        }
        catch {
            #Log satus code y salimos
            Write-Host $_.Exception.Message
            $result = $null
        }

        return  $result

    } -args @($uri)

    if ( $null -eq $result ){
        #DEBUG: escribir en el fichero de logs
        $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $log_file -Value "ERROR ($DATE) - $gr_module -: No se ha podido obtener el token de acceso"
    }
    else{
        #DEBUG: escribir en el fichero de logs
        $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $log_file -Value "INFO ($DATE) - $gr_module - : Token de acceso obtenido correctamente"
    }
    
    return $result

}

##########################################
# Añade información básica de la máquina a la DB en gorillaReport webapp
# @return $result (Boolean) | null
#########################################
function AddBasicInformation(){
    
    param(
        [Parameter(Mandatory=$true)]
        [System.Object[]]$token,

        [Parameter(Mandatory=$true)]
        [String]$basicInformation,

        [Parameter(Mandatory=$true)]
        [string]$URI
    )
    $result = $null

    Write-Host $token
    Write-Host $basicInformation
    Write-Host $URI
    Write-Host "####################"
    
    # Ejecutamos el script en powershell 7
    $result = pwsh -Command{
        
        $token = $args[0].access_token
        $basicInformation = $args[1]
        $URI = $args[2]

        #$token = ConvertTo-SecureString -String $args[0] -AsPlainText -Force
        $token = ConvertTo-SecureString -String $token -AsPlainText -Force

        $body = @{
            huid=(Get-CimInstance Win32_ComputerSystemProduct).UUID
            name = $env:COMPUTERNAME
            information = $basicInformation.ToString()
        }

        Write-Host $body
        
        $Params=@{
            Method = "Post"
            Uri = $URI
            Authentication = "Bearer"
            Token = $token
            SkipCertificateCheck = 1
            Body = $body
        }
        
        $result = Invoke-RestMethod @Params
        Write-Host "result Invoke-RestMethod:"
        Write-Host $result
        return $result 

    } -args @($token, $basicInformation, $URI)

    
    return $result
}

# Hacer las funciones y variables de este módulo disponibles en los scripts que lo usen 
$ExportedCommands = @(
    'GetAccessToken',
    'AddBasicInformation'
)
$ExportedVariables = @(
    "login_uri",
    "register_pc_uri",
    "set_basic_info_uri",
    "log_file"
)
Export-ModuleMember -Function $ExportedCommands -Variable $ExportedVariables