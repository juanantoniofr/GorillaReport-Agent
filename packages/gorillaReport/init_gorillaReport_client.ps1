<#
.SYNOPSIS
    1 - Instala python y powershell 7
    2 - Crea los directorios de gorillaReport en el cliente.
    3 - Descarga el modulo GRmodule.psm1  y el parser en python del servidor de gorilla.
    4 - Hace disponible el módulo gorillaReport.psm1 para todos los scripts de powershell.
    5 - Descarga scripts para realizar reportes.

.DESCRIPTION
    1 - Instala python y powershell 7
        Instalar python3 y Powershell 7.4

    2 - Crea los directorios de gorillaReport en el cliente. 
        En el directorio home del usuario crea un directorio llamado gorillaReport, y los subdirectorios:
        - gorillaReport\scripts: directorio para los scripts de gorillaReport
        - gorillaReport\modules: directorio para los módulos de gorillaReport
        - gorillaReport\logs: directorio para los logs de gorillaReport
        - gorillaReport\reports: directorio para los informes de gorillaReport
        - gorillaReport\temp: directorio para los archivos temporales de gorillaReport

    3 - Descarga el modulo GRmodule.psm1 del servidor gorillaserver y lo guarda en la carpeta de modules del cliente.
        Si el modulo ya existe y no coincide el hash del fichero, lo sobreescribe.  
        Tambien descarga el script en python que parsea el fichero de logs de gorilla.      

    4 - Añade la ruta del módulo gorillaReport a la variable de entorno PSModulePath. Si la ruta ya está en la variable de entorno no hace nada.
        De esta forma, el módulo estará disponible de forma global y permanente para todos los scripts de powershell.
        Con esto conseguimos que los scripts de gorillaReport puedan importar el módulo de scripts de gorillaReport, teniendo acceso a variables y funciones definidas en él.
        Variables de entorno:
        - GR_SCRIPTS_PATH: ruta de los scripts de gorillaReport
        - GR_SCRIPTS_MODULE: directorio del módulo de scripts de gorillaReport

.NOTES
    Autores: Luis Vela Morilla, Juan Antonio Fernández Ruiz
    Fecha: 2023-03-03
    Versión: 1.0
    Email:  luivelmor@us.es | juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>
#Gorilla Server DNS Name or IP
$gorillaserver = "gorillaserver.lc:8080"
#$gorillaserver="172.23.23.132"

#########################################
### 1 - Instala el software necesario ###
#########################################

# 1.1 - Instalamos python
#if($null -eq (choco list --localonly | Select-String "python")){
#    try {
#        Invoke-Expression "choco install python -y"
#        Write-Host "Python instalado correctamente"
#    } catch {
#        Write-Host "Error al instalar Python: $_"
#    }
#    
#}
#else{
#    Write-Host "Python ya esta instalado"
#}

# 1.2 - Instalamos powershell 7
If ( !(Test-Path "C:\Program Files\PowerShell\7\pwsh.exe") ) {
    # copiamos el script
    $file = "http://$gorillaserver/packages/gorillaReport/PowerShell-7.2.0-win-x64.msi"
    $outputFile = 'C:\Users\tecnico\AppData\Local\Temp\PowerShell-7.2.0-win-x64.msi'
    # descargamos los ficheros
    Invoke-WebRequest -Uri $file -OutFile $outputFile
    # instalamos
    msiexec.exe /i "C:\Users\tecnico\AppData\Local\Temp\PowerShell-7.2.0-win-x64.msi" /qn
}
else {
    Write-Host "Powershell 7 ya esta instalado"
}


###############################################################
### 2 - Crea los directorios de gorillaReport en el cliente ###
###############################################################

# 2.1 - Crea el directorio gorillaReport
$homedir = [Environment]::GetFolderPath("UserProfile")
$gorilladir = "gorillaReport"

if (-not (Test-Path -Path "$homedir\$gorilladir" -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path "$homedir\$gorilladir" -ErrorAction Stop | Out-Null
        Write-Host "Directorio $gorilladir creado correctamente."
    }
    catch {
        throw "Error al crear el directorio: $_"
    }
}
else {
    Write-Host "El directorio $gorilladir ya existe."
}

# 2.2 - Crea los subdirectorios de gorillaReport
$subdirectories = @("scripts", "modules", "logs", "reports", "temp")

foreach ($subdir in $subdirectories) {
    if (-not (Test-Path -Path "$homedir\$gorilladir\$subdir" -PathType Container)) {
        try {
            New-Item -ItemType Directory -Path "$homedir\$gorilladir\$subdir" -ErrorAction Stop | Out-Null
            Write-Host "Directorio $homedir\$gorilladir\$subdir creado correctamente."
        }
        catch {
            throw "Error al crear el directorio: $_"
        }
    }
    else {
        Write-Host "El directorio $homedir\$GORILLADIR\$subdir ya existe."
    }
}

# 2.3 - Crea un fichero de log para gorillaReport
$log_file = "$homedir\$gorilladir\logs\gorillareport.log"
if (-not (Test-Path -Path $log_file -PathType Leaf)) {
    try {
        New-Item -ItemType File -Path $log_file -ErrorAction Stop | Out-Null
        Write-Host "Archivo $log_file creado correctamente."
    }
    catch {
        throw "Error al crear el archivo: $_"
    }
}
else {
    Write-Host "El archivo $log_file ya existe."
}



###########################################################################################
### 3 - Descarga el modulo GRmodule.psm1  y el parser en python del servidor de gorilla ###
###########################################################################################

# Directorio home del usuario
$homedir = [Environment]::GetFolderPath("UserProfile")
# Directorio de gorillaReport
$gorilladir = "gorillaReport"
# Directorio donde se guardan los modulos de gorillaReport
$gr_modules_path = "$homeDir\$gorilladir\modules"
#Directorio donde se guarda el módulo GRModule.psm1
$gr_module_dir = "$gr_modules_path\GRModule"
# Nombre del modulo
$gr_module_name = "GRModule.psm1"
#path al fichero GRModule.psm1
$GRModule_path = "$gr_module_dir\$gr_module_name"

# 3.1 - Creamos directorio en el cliente para el módulo GRModule.psm1, si no existe
If (-not (Test-Path -Path $gr_module_dir -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path $gr_module_dir -ErrorAction Stop | Out-Null
        Write-Host "Directorio $gr_module_dir creado correctamente."
    }
    catch {
        throw "Error al crear el directorio: $_"
        exit 1
    }
}
else {
    Write-Host "El directorio $gr_module_dir ya existe."
}

# 3.2 - descarga de ficheros (sin certificado, AuthBasic in gorilla server)
$HASH = ''
If ( (Test-Path $GRModule_path) ) {
    $HASH = (Get-FileHash $GRModule_path).Hash
}

Write-Host "Hash del fichero $GRModule_path : $HASH"

# si no existe el archivo ó si el hash no coincide con la plantilla del servidor
If ($HASH -ne "a2a91f5e93d9529c956e0211ad446408ce425c29a1903b05566bd2c27492d701") {
    $file = "http://$gorillaserver/packages/gorillaReport/modules/GRModule/GRModule.psm1"       
    Invoke-WebRequest -Uri $file -OutFile $GRModule_path 
}
else {
    Write-Host "El fichero $GRModule_path ya existe y no es necesario descargarlo."
}

# 3.3 - descarga scripts de python (parser)
If (!(Test-Path $gr_modules_path\python_gorilla_parser)) {
    New-Item -ItemType Directory -Path $gr_modules_path\python_gorilla_parser -ErrorAction Stop | Out-Null
    Write-Host "Directorio " + "$gr_modules_path\python_gorilla_parser" + "creado correctamente."
}
else {
    Write-Host "El directorio " + "$gr_modules_path\python_gorilla_parser" + " ya existe."
}

# descargamos los ficheros
$file1 = "http://$gorillaserver/packages/gorillaReport/modules/python_gorilla_parser/main.py"
$outputFile1 = "$homedir\gorillaReport\modules\python_gorilla_parser\main.py"

$file2 = "http://$gorillaserver/packages/gorillaReport/modules/python_gorilla_parser/my_functions.py"
$outputFile2 = "$homedir\gorillaReport\modules\python_gorilla_parser\my_functions.py"

if (!(Test-Path $file1)) { Invoke-WebRequest -Uri $file1 -OutFile $outputFile1 }
if (!(Test-Path $file2)) { Invoke-WebRequest -Uri $file2 -OutFile $outputFile2 }


#############################################################################################
### 4 - Hace disponible el módulo gorillaReport.psm1 para todos los scripts de powershell ###
#############################################################################################

# home de usuario
$homedir = $env:USERPROFILE
# directorio de gorillaReport
$gorilladir = "gorillaReport"
# directorio de módulos de gorillaReport
$gr_module_path = "$homeDir\$gorilladir\modules"


# 4.1 - Verificar si el archivo de perfil existe
if (!(Test-Path $PROFILE)) {
    # Si el archivo de perfil no existe, crearlo
    New-Item -ItemType File -Path $PROFILE -Force
}

# 4.2 - Agregar el directorio personalizado a la variable PSModulePath
if (-not ($env:PSModulePath -split ';' | Select-String -SimpleMatch $gr_module_path)) {
    $env:PSModulePath += ";$gr_module_path"
    # Agregar el comando a $PROFILE para que los cambios sean permanentes
    Add-Content $PROFILE "`n`$env:PSModulePath += `";$gr_module_path`""
    # Mostrar la nueva lista de directorios de módulos
    Write-Host "La variable `$env:PSModulePath ahora contiene:`n$env:PSModulePath"
}
else {
    Write-Host "La variable `$env:PSModulePath ya contiene $gr_module_path :`n$env:PSModulePath"
}
#Cualquier script puede importar el módulo GRmodule.psm1 con el siguiente comando:
#Import-Module GRModule

###################################################
### 5 - Descarga scripts para realizar reportes ###
###################################################

$file1 = "http://gorillaserver/packages/gorillaReport/scripts/register_gorilla_report.ps1"
$outputFile1 = "$homedir\gorillaReport\scripts\register_gorilla_report.ps1"

$file2 = "http://$gorillaserver/packages/gorillaReport/scripts/register_client.ps1"
$outputFile2 = "$homedir\gorillaReport\scripts\register_client.ps1"

$file3 = "http://$gorillaserver/packages/gorillaReport/scripts/send_report_pwsh7.ps1"
$outputFile3 = "$home\gorillaReport\scripts\send_report_pwsh7.ps1"

$file4 = "http://$gorillaserver/packages/gorillaReport/scripts/register_basic_info.ps1"
$outputFile4 = "$homedir\gorillaReport\scripts\register_basic_info.ps1"

if (!(Test-Path $outputFile1)) { Invoke-WebRequest -Uri $file1 -OutFile $outputFile1 }
if (!(Test-Path $outputFile2)) { Invoke-WebRequest -Uri $file2 -OutFile $outputFile2 }
if (!(Test-Path $outputFile3)) { Invoke-WebRequest -Uri $file3 -OutFile $outputFile3 }
if (!(Test-Path $outputFile4)) { Invoke-WebRequest -Uri $file4 -OutFile $outputFile4 }
