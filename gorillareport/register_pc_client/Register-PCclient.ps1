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

#aquí empieza el script

# variables
$gr_module = "GRModule"

# Importamos el módulo de scripts de gorillaReport
try {
    $GRModule = Import-Module -Name $gr_module -AsCustomObject -Force -ErrorAction stop -Passthru
    #Console debug: lista de propiedades y métodos del módulo
    Write-Host "Módulo de scripts de gorillaReport importado"
    $GRModule | Get-Member
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al importar el módulo de scripts de gorillaReport"
    Write-Host $_.Exception.Message
    exit 1
}

# Registra pc_client en el servidor gorillaReport
function Register {

    pwsh -Command{
        param(
            [Parameter(Mandatory=$true)]
            [string]$token,

            [Parameter(Mandatory=$true)]
            [string]$URI
        )

        #$token = ConvertTo-SecureString -String $args[0] -AsPlainText -Force
        $token = ConvertTo-SecureString -String $token -AsPlainText -Force

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

        #Invoke-RestMethod @Params

        Write-Host $Params
    
    } -args @($token, $URI)
}

#Obtenemos el token de acceso
#$token = $GRModule."Get-AccessToken"()

#Si no hay token de acceso salimos
if ( $null -eq $token ){ 
    #DEBUG: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $GRModule.log_file -Value "ERROR ($DATE): No se ha podido obtener el token de acceso"
    exit 0
}

#Registramos pc_client
register $token.access_token $GRModule.login_uri
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Log -logFile $log_file -logLevel "INFO: $DATE " -logMessage "pc_client registrado correctamente"
