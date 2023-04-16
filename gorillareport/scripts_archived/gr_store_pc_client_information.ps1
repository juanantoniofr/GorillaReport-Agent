Import-Module $GR_SCRIPTS_PATH + "/gr_scripts_module.psm1"


function store_pc_client_information($token){

    pwsh -Command{
        
        $net_ip_configuration = Get-NetIPConfiguration | Select-Object -Property Computername, IPv4Address

        $computer_info = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, BiosName, BiosFirmwareType, OsUptime
        $basic_information = @{}

        $basic_information | Add-Member -NotePropertyName WindowsProductName -NotePropertyValue $computer_info.WindowsProductName
        $basic_information | Add-Member -NotePropertyName WindowsVersion -NotePropertyValue $computer_info.WindowsVersion
        $basic_information | Add-Member -NotePropertyName BiosName -NotePropertyValue $computer_info.BiosName
        $basic_information | Add-Member -NotePropertyName BiosFirmwareType -NotePropertyValue $computer_info.BiosFirmwareType
        $basic_information | Add-Member -NotePropertyName OsUptime -NotePropertyValue $computer_info.OsUptime.TotalSeconds


        #C:\ProgramData\gorilla\config.yaml
        $line = Select-String -Path C:\ProgramData\gorilla\config.yaml -Pattern 'manifest' | Select-Object -Property Line 

        $basic_information | Add-Member -NotePropertyName Manifest -NotePropertyValue $line.Line.Substring(10)

        $json_basic_information = $basic_information | ConvertTo-Json

                
        
        $Token=$args[0] | ConvertTo-SecureString -AsPlainText -Force
        
        $Body = @{
            name = $net_ip_configuration.Computername
            ip = $net_ip_configuration.IPv4Address.IPAddress
            information = $json_basic_information
        }

        $JsonBody = $Body | ConvertTo-Json  
        
        $Params=@{
            Method = "Post"
            Uri="https://10.1.21.2/api/clients"
            Authentication="Bearer"
            Token=$Token
            SkipCertificateCheck=1
            Body=$Body
        }

        Invoke-RestMethod @Params
    } -args @($token)

}

$token = get_access_token

if (null -ne $token){ 
    $token_access = $token.access_token
    $token_type = $token.token_type

    store_pc_client_information $token.access_token
    

    }
else{
    Write-Host 'Error de acceso'
    exit 0
}

