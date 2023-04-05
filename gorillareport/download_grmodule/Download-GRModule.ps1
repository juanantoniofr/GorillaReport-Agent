<#
.SYNOPSIS
    Descarga el modulo GRmodule.psm1 del servidor gorillaserver (gorilla).
.DESCRIPTION
    Descarga el modulo GRmodule.psm1 del servidor gorillaserver y lo guarda en la carpeta de modules del cliente.
    Si el modulo ya existe y no coincide el hash del fichero, lo sobreescribe.
.NOTES
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2021-03-03
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>

#Aqui empieza el script

# Variables
# Directorio home del usuario
$homedir = [Environment]::GetFolderPath("UserProfile")
# Directorio de gorillaReport
$gorilladir = "gorillaReport"
# Directorio donde se guardan los modulos de gorillaReport
$gr_module_path = "$homeDir\$gorilladir\modules\GRModule.psm1"
#Gorilla Server DNS Name. Añidir puerto si no es el 443, recomendable en entornos de pruebas.
$gorillaserver="gorillaserver.lc:8080"

# descarga de ficheros (usando certificado y powershell 7)
$HASH=''
If ( (Test-Path $gr_module_path) ) {
    $HASH=(Get-FileHash $gr_module_path).Hash
}

Write-Host "Hash del fichero: $HASH"

# si no existe el archivo ó si el hash no coincide con la plantilla del servidor
If ($HASH -ne "C8883B0E07DCCA2F3188FDECC4813E95B998F5D2FB45351658F1EDE242AF03C0"){
    # si no coincide, descargamos
    $file = "http://$gorillaserver/gorilla/packages/gorillaReport/download_grmodule/GRModule.psm1"
        
    # certificado pfx (requiere contraseña en windows ltsc)
    #$pass = ConvertTo-SecureString -String 'asdf' -AsPlainText -Force
    #$client_pfx_cert = Get-PfxCertificate -FilePath "C:\ProgramData\gorilla\cliente_gorillaserver.pfx" -Password $pass
    # descarga
    Invoke-WebRequest -Uri $file -OutFile $gr_module_path 
    #-Certificate $client_pfx_cert
}
else {
    Write-Host "El fichero ya existe y no es necesario descargarlo."
}
