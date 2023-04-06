

#variables
# uri api login
$login_uri = "https://gorillareport:4444/api/login"
# uri api de registro de pc_client
$register_pc_uri = "https://gorillareport:4444/api/client/register"
# home de usuario
$homedir = $env:USERPROFILE
# directorio de gorillaReport
$gorilladir = "gorillareport"
# fichero de logs de gorillaReport
$log_file = "$homedir\$gorilladir\logs\gorillareport.log"

# Funciones

##########################################
# Obtiene el token API de acceso
# @return $token (String) | null
##########################################
function Get-AccessToken {

    param(
        [Parameter(Mandatory=$true)] LoginUri
    )

    pwsh -Command {

        $Body = @{
            email    = "apiuser@email.com"
            password = "pass"
        }
        
        $JsonBody = $Body | ConvertTo-Json
        
        $Params = @{
            Method               = "Post"
            Uri                  = "https://10.1.21.2/api/login"
            Body                 = $JsonBody
            ContentType          = "application/json"
            SkipCertificateCheck = 1
        }

    
        #Invoke-RestMethod @Params |  Select-Object -Property access_token
        try {
            $response = Invoke-RestMethod @Params
            $result = $response.access_token
        }
        
        catch {
        
            #Log satus code y salimos
            #return $_.Exception.Response.StatusCode.value__ 
            return $null
        }

        return $result

    }

}


# Hacer las funciones y variables de este módulo disponibles en los scripts que lo usen 
$ExportedCommands = @(
    'Get-AccessToken'
)
Export-ModuleMember -Function $ExportedCommands
Export-ModuleMember -Variable '*'