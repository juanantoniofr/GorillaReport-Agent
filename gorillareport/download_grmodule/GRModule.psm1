##########################################
# VARIABLES
##########################################
$GR_LOGS_DIRECTORY = $GR_SCRIPTS_PATH + "\logs"
$GR_lOGS_FILE = $GR_LOGS_DIRECTORY + "\gr_log.log"


##########################################
# FUNCIONES
##########################################

##########################################
# Obtiene el token API de acceso
# @return $token (String) | null
##########################################
function get_access_token() {

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
Export-ModuleMember -Function '*'
Export-ModuleMember -Variable '*'