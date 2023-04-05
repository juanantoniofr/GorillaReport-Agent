<#
.SYNOPSIS
    Crea los directorios de gorillaReport en el cliente.
.DESCRIPTION
    Crea los direcrtorios de gorillaReport en el cliente. En el directorio home del usuario crea un directorio llamado gorillaReport, y los subdirectorios:
        - gorillaReport\scripts: directorio para los scripts de gorillaReport
        - gorillaReport\logs: directorio para los logs de gorillaReport
        - gorillaReport\reports: directorio para los informes de gorillaReport
        - gorillaReport\temp: directorio para los archivos temporales de gorillaReport
.NOTES
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2023-03-03
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>

# Aquí empieza el script
# Creamos directorio en el cliente para scripts de gorillaReport  
$homedir = [Environment]::GetFolderPath("UserProfile")
$gorilladir = "gorillaReport"

if (-not (Test-Path -Path "$homedir\$gorilladir" -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path "$homedir\$gorilladir" -ErrorAction Stop | Out-Null
        Write-Host "Directorio creado correctamente."
    } catch {
        throw "Error al crear el directorio: $_"
    }
} else {
    Write-Host "El directorio ya existe."
}

#create subdirectories
$subdirectories = @("scripts", "logs", "reports", "temp")

foreach ($subdir in $subdirectories) {
    if (-not (Test-Path -Path "$homedir\$gorilladir\$subdir" -PathType Container)) {
        try {
            New-Item -ItemType Directory -Path "$homedir\$GORILLADIR\$subdir" -ErrorAction Stop | Out-Null
            Write-Host "Directorio creado correctamente."
        } catch {
            throw "Error al crear el directorio: $_"
        }
    } else {
        Write-Host "El directorio ya existe."
    }
}