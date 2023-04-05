Import-Module "C:\Users\tecnico\scripts\gr\gr_scripts_module.psm1"

##########################################
# Registra pc_client 
# @return $response (booleano)
##########################################
function register_pc_client {
    
    pwsh -Command{
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
            Uri="https://10.1.21.2/api/client/register"
            Authentication="Bearer"
            Token=$token
            SkipCertificateCheck=1
            Body=$body
        }

        Invoke-RestMethod @Params
    
    } -args @($token)
}

#Get API token access
$token = get_access_token

if ( $null -eq $token ){ 
    #DEBUG: escribir en el fichero de gr_log.log
    Write-Host 'Error de acceso'
    exit 0
}

register_pc_client $token.access_token
Write-Host 'Resgistramos equipo'