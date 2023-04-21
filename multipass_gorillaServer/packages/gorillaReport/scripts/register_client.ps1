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

# aquí empieza el script
# variables
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

# Registra pc_client en el servidor gorillaReport
function Register {
    
    param(
        [Parameter(Mandatory=$true)]
        [System.Object[]]$token,

        [Parameter(Mandatory=$true)]
        [string]$URI
    )

    # Ejecutamos el script en powershell 7
    $result = pwsh -Command{
        
        $token = $args[0].access_token
        $URI = $args[1]

        #$token = ConvertTo-SecureString -String $args[0] -AsPlainText -Force
        $token = ConvertTo-SecureString -String $token -AsPlainText -Force

        # Obtenemos las IPs de la máquina
        $ipAddresses = Get-NetIPAddress -AddressFamily Ipv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | Select-Object -ExpandProperty IPAddress
        # Convertimos a json
        $ips = ($ipAddresses | ConvertTo-Json)
        
        $body = @{
            huid=(Get-CimInstance Win32_ComputerSystemProduct).UUID
            name = $env:COMPUTERNAME
            ip = $ips.Replace('[','{').Replace(']','}')
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
    } -args @($token, $URI)

    return $result
}

#Obtenemos el token de acceso
$token = $GRModule.GetAccessToken($GRModule.login_uri)

#Si no hay token de acceso salimos
if ( $null -eq $token ){ 
    #DEBUG: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $GRModule.log_file -Value "ERROR ($DATE) - $this_script -: No se ha podido obtener el token de acceso"
    exit 0
}
else{
    #DEBUG: escribir en el fichero de logs
    $DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $GRModule.log_file -Value "INFO ($DATE) - $this_script - : Token de acceso obtenido correctamente"
}

#Registramos pc_client
$result = Register $token $GRModule.register_pc_uri 
Write-Host "gorillareport webapp response: " $result.message
#DEBUG: escribir en el fichero de logs
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $GRModule.log_file -Value "$DATE - $this_script - : gorillareport webapp response ->  $result.message" 
exit 0
