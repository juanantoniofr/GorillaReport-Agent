<#
.SYNOPSIS 
    Hace disponible el módulo gorillaReport.psm1 para todos los scripts de powershell.
.DESCRIPTION
    Añade la ruta del módulo gorillaReport a la variable de entorno PSModulePath. Si la ruta ya está en la variable de entorno no hace nada.
    De esta forma, el módulo estará disponible de forma global y permanente para todos los scripts de powershell.
    Con esto conseguimos que los scripts de gorillaReport puedan importar el módulo de scripts de gorillaReport, teniendo acceso a variables y funciones definidas en él.
    Variables de entorno:
        GR_SCRIPTS_PATH: ruta de los scripts de gorillaReport
        GR_SCRIPTS_MODULE: directorio del módulo de scripts de gorillaReport
.NOTES
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2023-03-03
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>

# Aquí empieza el script

# Variables
# home de usuario
$homedir = $env:USERPROFILE
# directorio de gorillaReport
$gorilladir = "gorillaReport"
# directorio de módulos de gorillaReport
$gr_module_path = "$homeDir\$gorilladir\modules"



# Verificar si el archivo de perfil existe
if (!(Test-Path $PROFILE)) {
    # Si el archivo de perfil no existe, crearlo
    New-Item -ItemType File -Path $PROFILE -Force
}

# Agregar el directorio personalizado a la variable PSModulePath
if (-not ($env:PSModulePath -split ';' | Select-String -SimpleMatch $gr_module_path)) {
    $env:PSModulePath += ";$gr_module_path"


    # Agregar el comando a $PROFILE para que los cambios sean permanentes
    Add-Content $PROFILE "`n`$env:PSModulePath += `";$gr_module_path`""

    # Mostrar la nueva lista de directorios de módulos
    Write-Host "La variable `$env:PSModulePath ahora contiene:`n$env:PSModulePath"
}
else {
    <# Action when all if and elseif conditions are false #>
    Write-Host "La variable `$env:PSModulePath ya contiene $gr_module_path :`n$env:PSModulePath"
}

#Aquí termina el script
#Cualquier script puede importar el módulo GRmodule.psm1 con el siguiente comando:
#Import-Module GRModule.psm1