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

#### URI's ####
#Nameserver o IP del servidor de gorillaReport
#$gr_server = "gorillareport::4444"
$gr_server = "10.1.21.2"
# uri api login
$login_uri = "https://"+$gr_server+"/api/login"
# uri api de registro de pc_client
$register_pc_uri = "https://"+$gr_server+"/api/client/register"
# uri api set basic information
$udpate_basic_info_uri = "https://"+$gr_server+"/api/client/updateBasicInformation"
# uri api set report
$update_report_uri = "https://"+$gr_server+"/api/client/updateReport"

#### Files and directories paths ####
# home de usuario
$homedir = $env:USERPROFILE

### directorios y ficheros de gorilla ###
#directorio de gorilla
$gorilla_dir = "c:\gorilla"
# fichero de logs de gorilla
$file_gorilla_log = "$gorilla_dir\cache\gorilla.log"

### directorios y ficheros de gorillaReport ###
# directorio de gorillaReport
$gorillaReport_dir = "$homedir\gorillaReport"
# directorio para reports de gorilla
$reports_dir = "$gorillaReport_dir\reports"
# fichero de logs de gorillaReport
$log_file = "$gorillaReport_dir\logs\gorillareport.log"
# fichero de logs de gorilla en formato JSON
$gorilla_log_file_json_format = "$gorilla_dir\CustomGorillaReport.json"
#Script ps1 para invocar pwsh con Invoke-RestMethod
$ps_file_for_send_reports_with_pwsh = "$gorillaReport_dir\scripts\gr_send_parsed_log_file\send_report_pwsh7.ps1"


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
function PushBasicInformation(){
    
    param(
        [Parameter(Mandatory=$true)]
        [System.Object[]]$token,

        [Parameter(Mandatory=$true)]
        [String]$basicInformation
    )
    

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

        $Params=@{
            Method = "Post"
            Uri = $URI
            Authentication = "Bearer"
            Token = $token
            SkipCertificateCheck = 1
            Body = $body
        }
        
        return Invoke-RestMethod @Params

    } -args @($token, $basicInformation, $udpate_basic_info_uri)

    return $result
}

##########################################
# Enviamos logs de la última ejecución de gorilla en formato JSON
# @return $result (Boolean) | null
#########################################
function PushReport() {
    
    param(
        [Parameter(Mandatory=$true)]
        [System.Object[]]$token,

        [Parameter(Mandatory=$true)]
        [System.String]$report
    ) 
    

    #Ejecutamos el script en powershell 7
    #$result = pwsh -Command{

        $access_token = $token.access_token
        #$report = $args[1]
        #$URI = $args[2]

        Write-Host $token

        

        #$token = ConvertTo-SecureString -String $args[0] -AsPlainText -Force
        $access_token = ConvertTo-SecureString -String $access_token -AsPlainText -Force

        $body = @{
            huid=(Get-CimInstance Win32_ComputerSystemProduct).UUID
            report = $report.ToString()
        }

        $Params=@{
            Method = "Post"
            Uri = $update_report_uri
            Authentication = "Bearer"
            Token = $access_token
            SkipCertificateCheck = 1
            Body = $body
        }

        #$Params.body.report
        $result = Invoke-RestMethod @Params
        return $result

    #} -args @($token, $report, $update_report_uri)

    return $result
}

# Hacer las funciones y variables de este módulo disponibles en los scripts que lo usen 
$ExportedCommands = @(
    'GetAccessToken',
    'PushBasicInformation',
    'PushReport'
)
$ExportedVariables = @(
    "login_uri",
    "register_pc_uri",
    "udpate_basic_info_uri",
    "update_report_uri",
    "log_file",
    "gorilla_log_file_json_format",
    "file_gorilla_log",
    "reports_dir",
    "ps_file_for_send_reports_with_pwsh"
)
Export-ModuleMember -Function $ExportedCommands -Variable $ExportedVariables