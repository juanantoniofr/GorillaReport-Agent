##########################################
# VARIABLES A CONFIGURAR
##########################################
# nombre de ESTE script
$SCRIPT_NAME="download_scripts_parser_log_file"
# dominio/usuario de la cuenta del equipo destino (whoami)
$CLIENT_NTACCOUNT="tecnico"
#Gorilla Server DNS Name
$GORILLA_SERVER="gorillaserver"


##########################################
# VARIABLES
##########################################
# directorio donde guardamos los scripts
$SCRIPTS_DIRECTORY="C:\Users\tecnico\scripts\gr"
$PARSER_DIRECTORY="C:\Users\tecnico\scripts\gr\parser"


##########################################
# FUNCIONES
##########################################
function set_owner($item) {
    # obtenemos el acl del item 
    $acl = Get-Acl $item
    # creamos el objeto que define al propietario
    $owner = New-Object System.Security.Principal.Ntaccount($CLIENT_NTACCOUNT)
    # configuramos el propietario en la acl
    $acl.SetOwner($owner);
    # seteamos el nuevo acl
    $acl | Set-Acl $item
}

##########################################
# CODIGO A EJECUTAR
##########################################
# creamos el directorio de scripts si no existe
If(!(test-path $SCRIPTS_DIRECTORY)) {
    New-Item -ItemType "directory" -Force -Path $SCRIPTS_DIRECTORY
    # definimos el propietario
    set_owner $SCRIPTS_DIRECTORY
}

# creamos el directorio para el parser si no existe
If(!(test-path $PARSER_DIRECTORY)) {
    New-Item -ItemType "directory" -Force -Path $PARSER_DIRECTORY
    # definimos el propietario
    set_owner $PARSER_DIRECTORY
}

# descarga de ficheros (usando certificado y powershell 7)
pwsh -Command {
    # variables
    $local_gorilla_report_log_parser = 'C:\Users\tecnico\scripts\gr\parser\log_parser.zip' 
    $gorillaserver=$args[0]


    $HASH=''
    If ( (Test-Path $local_gorilla_report_log_parser) ) {
        $HASH=(Get-FileHash $local_gorilla_report_log_parser).Hash
    }
    
    # si no existe el archivo ó si el hash no coincide con la plantilla del servidor
    If ($HASH -ne "287E0C98A43919FABDD452652CB8AB48FA86A2A8224FB33790278D227FF296D7"){
        # si no coincide, descargamos
        $file = "https://$gorillaserver/packages/report/download_scripts_parser_log_file/log_parser.zip"
         
        # certificado pfx (requiere contraseña en windows ltsc)
        $pass = ConvertTo-SecureString -String 'asdf' -AsPlainText -Force
        $client_pfx_cert = Get-PfxCertificate -FilePath "C:\ProgramData\gorilla\cliente_gorillaserver.pfx" -Password $pass
        # descarga
        Invoke-WebRequest -Uri $file -OutFile $local_gorilla_report_log_parser -Certificate $client_pfx_cert
    }
} -args @($GORILLA_SERVER)