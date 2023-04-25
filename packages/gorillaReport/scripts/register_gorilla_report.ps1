<#
.SYNOPSIS
    Usa python script para parsear el fichero de log de gorilla a formato JSON y lo envía a gorillaReport webapp.
.DESCRIPTION
    Usa python script para parsear el fichero de log de gorilla a formato JSON y lo envía a gorillaReport webapp.
    1. Importa el módulo de scripts de gorillaReport
    2. Parsea el fichero de log de gorilla a formato JSON: python.exe - $GRModule.path_to_python_parser.
    3. Obtiene el token de acceso a la API
    4. Envia el reporte a la api de gorillaReport
.NOTES
    Autor: Juan Antonio Fernández Ruiz
    Fecha: 2023-04-07
    Versión: 1.0
    Email: juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html
#>

# aquí empieza el script
# 1. Importamos el módulo de scripts de gorillaReport

try {
    $GRModule = Import-Module -Name "GRModule" -AsCustomObject -Force -ErrorAction stop -Passthru
    #Console debug: lista de propiedades y métodos del módulo
    Write-Host "Módulo de scripts de gorillaReport importado"
    #$GRModule | Get-Member
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al importar el módulo de scripts de gorillaReport"
    Write-Host $env:PSModulePath
    Write-Host $_.Exception.Message
    exit 0
}

# variables
$this_script = "Send-ParsedLog.ps1"
$json_file_log = $GRModule.gorilla_log_file_json_format

# 2. Generamos fichero de log de gorilla en formato JSON
# 2.1 Verificamos que python está instalado en el sistema y obtenemos su ruta
#$pythonExe = $(Get-Command python).Path
if ( !(Test-Path -Path "C:\Program Files\Python311\python.exe" )) {
    Write-Host "Python no está instalado en el sistema."
    exit 1
}

$pythonExe = "C:\Program Files\Python311\python.exe"


# 2.2 Ejecutamos el script de python para parsear el fichero de log de gorilla a formato JSON
$process = Start-Process -FilePath $pythonExe -ArgumentList $GRModule.path_to_python_parser -PassThru
# 2.3 Esperamos a que termine la ejecución del script de python
$process.WaitForExit()
# 2.4 Comprobamos el código de salida del script de python, si error salimos del script
if ($process.ExitCode -eq 0) {
    Write-Host "El script de Python se ha ejecutado correctamente."
}
else {
    Write-Host "Ha ocurrido un error al ejecutar el script de Python."
    exit 1
}

# 3. Obtenemmos el token de acceso a la API de gorillaReport webapp
$token = $GRModule.GetAccessToken($GRModule.login_uri)

# 4. enviamos el reporte a la api de gorillaReport
$result = $(pwsh.exe -File $GRModule.ps_file_for_send_reports_with_pwsh -token $token.access_token -logfile $json_file_log -uri $GRModule.update_report_uri)

#DEBUG: console debug
Write-Host "gorillareport webapp response: " $result
#DEBUG: escribir en el fichero de logs
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $GRModule.log_file -Value "$DATE - $this_script - : gorillareport webapp response: -> $result.message"
exit 0