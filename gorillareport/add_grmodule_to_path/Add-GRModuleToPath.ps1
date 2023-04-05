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
$homedir = [Environment]::GetFolderPath("UserProfile")
$gorilladir = "gorillaReport"
$gr_module_path = "$homeDir\$gorilladir\modules\GRModule.psm1"

# 1. Obtener la ruta completa de la carpeta del módulo
$modulePath = Resolve-Path -Path $gr_module_path

# 2. Obtener la variable de entorno PSModulePath
$envPath = [Environment]::GetEnvironmentVariable("PSModulePath", "User")

# 3. Convertir la cadena de la variable de entorno en un array de rutas
if ($envPath -eq $null) {
    $envPath = ""
}

$pathArray = $envPath -split ';'

# 4. Comprobar si la ruta del módulo ya está en la variable de entorno
if ($pathArray -contains $modulePath) {
    Write-Output "La ruta del módulo ya está en PSModulePath"
} else {
    # 5. Añadir la ruta del módulo al principio del array de rutas
    $modulePath = [System.IO.DirectoryInfo]::new($modulePath)
    $pathArray = $modulePath.FullName + $pathArray


    # 6. Actualizar la variable de entorno PSModulePath
    $newPath = $pathArray -join ';'
    [Environment]::SetEnvironmentVariable("PSModulePath", $newPath, "User")
    Write-Output "La ruta del módulo ha sido añadida a PSModulePath"
}

# 7. Comprobar que la ruta del módulo está en la variable de entorno
$envPath = [Environment]::GetEnvironmentVariable("PSModulePath", "User")
$pathArray = $envPath -split ';'
if ($pathArray -contains $modulePath) {
    Write-Output "La ruta del módulo está en PSModulePath"
} else {
    Write-Output "La ruta del módulo no está en PSModulePath"
}

#Aquí termina el script
#Cualquier script puede importar el módulo GRmodule.psm1 con el siguiente comando:
#Import-Module GRModule.psm1