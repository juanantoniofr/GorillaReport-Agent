##########################################
# VARIABLES A CONFIGURAR
##########################################
# nombre de ESTE script
$SCRIPT_NAME="download_scripts_gr_psm1_module"
# dominio/usuario de la cuenta del equipo destino (whoami)
$CLIENT_NTACCOUNT="tecnico"
#Gorilla Server DNS Name
$GORILLA_SERVER="gorillaserver"


##########################################
# VARIABLES
##########################################
# directorio donde guardamos los scripts
$SCRIPTS_DIRECTORY="C:\Users\tecnico\scripts\gr"


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
# creamos el directorio si no existe
If(!(test-path $SCRIPTS_DIRECTORY)) {
    New-Item -ItemType "directory" -Force -Path $SCRIPTS_DIRECTORY
    # definimos el propietario
    set_owner $SCRIPTS_DIRECTORY
}

# descarga de ficheros (usando certificado y powershell 7)
pwsh -Command {
    # variables
    $local_gorilla_report_scripts_module = 'C:\Users\tecnico\scripts\gr\gr_scripts_module.psm1' 
    $gorillaserver=$args[0]


    $HASH=''
    If ( (Test-Path $local_gorilla_report_scripts_module) ) {
        $HASH=(Get-FileHash $local_gorilla_report_scripts_module).Hash
    }
    
    # si no existe el archivo ó si el hash no coincide con la plantilla del servidor
    If ($HASH -ne "A5F7C499F73EA99EFB19D103508FB0B3C9194DDDEC381B4C4C7C353E0D15FC0F"){
        # si no coincide, descargamos
        $file = "https://$gorillaserver/packages/report/download_scripts_psm1_module/gr_scripts_module.psm1"
        
        # certificado pfx (requiere contraseña en windows ltsc)
        $pass = ConvertTo-SecureString -String 'asdf' -AsPlainText -Force
        $client_pfx_cert = Get-PfxCertificate -FilePath "C:\ProgramData\gorilla\cliente_gorillaserver.pfx" -Password $pass
        # descarga
        Invoke-WebRequest -Uri $file -OutFile $local_gorilla_report_scripts_module -Certificate $client_pfx_cert
    }
} -args @($GORILLA_SERVER)