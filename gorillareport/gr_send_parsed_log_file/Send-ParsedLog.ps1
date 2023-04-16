# aquí empieza el script
# Importamos el módulo de scripts de gorillaReport
try {
    $GRModule = Import-Module -Name "GRModule" -AsCustomObject -Force -ErrorAction stop -Passthru
    #Console debug: lista de propiedades y métodos del módulo
    Write-Host "Módulo de scripts de gorillaReport importado"
    #$GRModule | Get-Member
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Error al importar el módulo de scripts de gorillaReport"
    Write-Host $_.Exception.Message
    exit 1
}

# variables
$this_script = "Send-ParsedLog.ps1"
$file_gorilla_log = $GRModule.file_gorilla_log
$reports_dir = $GRModule.reports_dir
$file_json_report = "$reports_dir\result.json"
#$GRModule | Get-Member
Write-Host "Parsing file $file_gorilla_log to $file_json_report"

#Código
$pattern = "INFO:\s\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}.\d{6}\sRetrieving manifest:"
$ocurrencias = Select-String -Path $file_gorilla_log -Pattern $pattern -AllMatches
$firstLine = $ocurrencias[$ocurrencias.Count-1].LineNumber

$logFile = Get-Content -Path $file_gorilla_log

# Variables para almacenar la información
$name = 'test'
$catalog = ''
$manifest = ''
$startTime = ''
$endTime = ''
$duration = ''
$log = ''
$managedInstall = @()

# Recorremos las líneas del archivo de log
foreach ($i in $firstLine..($logFile.Count - 1)) {
    # Obtenemos la línea actual
    $line = $logFile[$i]
    
    # Procesamos la línea
    if ($line -match 'Retrieving manifest: (.+)') {
        $manifest = $Matches[1]
    } elseif ($line -match 'Retrieving catalog: \[(.+)\]') {
        $catalog = $Matches[1]
    } elseif ($line -match 'INFO: (.+) Processing manifest') {
        $startTime = [datetime]::ParseExact($Matches[1], 'yyyy/MM/dd HH:mm:ss.ffffff', $null).ToString('yyyy-MM-dd HH:mm:ss')
    } 
    elseif ($line -match 'INFO: (.+) Done!') {
        $endTime = [datetime]::ParseExact($Matches[1], 'yyyy/MM/dd HH:mm:ss.ffffff', $null).ToString('yyyy-MM-dd HH:mm:ss')
        $duration = (New-TimeSpan -Start $startTime -End $endTime).TotalMilliseconds.ToString()
        $log = $file_gorilla_log
    }
    #INFO: 2023/04/09 11:15:24.103086 Checking status via script: display_name
    elseif ($line -match 'INFO: (.+) Checking status (.+)') {
        <# Action when this condition is true #>
        $DebugCheck = @{}

        do {
            # Leemos la siguiente línea
            $line = $logFile[++$i]
            # Procesamos la línea
            if ($line -match "DEBUG:\s\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}.\d{6}\s(.+)$") {
                $DebugCheck["line$($DebugCheck.Count + 1)"]=$matches[1]
            }
        } while ($line -match "DEBUG:\s\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}.\d{6}\s(.+)$")
    }
    #INFO: 2023/04/09 11:15:25.322027 Installing ps1 display_name
    elseif ($line -match 'INFO: (.+) Installing (.+)') {
        <# Action when this condition is true #>
        $DebugInstall = @{}

        do {
            # Leemos la siguiente línea
            $line = $logFile[++$i]
            # Procesamos la línea
            if ($line -match "DEBUG:\s\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}.\d{6}\s(.+)$") {
                $DebugInstall["line$($DebugInstall.Count + 1)"]=$matches[1]
            }
        } while ($line -match "DEBUG:\s\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}.\d{6}\s(.+)$")
    }
    elseif ($line -match '^(INFO|WARN): (\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\.\d{6}) (.+) (Installation SUCCESSFUL|Installation FAILED)$') {
        # Creamos el objeto para el managed install y lo añadimos al array
        $managedInstallObj = @{
            'item' = $Matches[3]
            'Checking' = @{
                'Debug' = $DebugCheck
            }
            'Installing' = @{
                'Debug' = $DebugInstall 
                'result' = $Matches[4]
            }
        }
        $managedInstall += $managedInstallObj
    }
}

# Creamos el objeto JSON
$jsonObj = @{
    'lastExecution' = @{
        'name' = $name
        'catalog' = $catalog
        'manifest' = $manifest
        'startTime' = $startTime
        'endTime' = $endTime
        'duration' = $duration
        'log' = $log
        'managed_install' = $managedInstall
    }
}

# Convertimos el objeto a JSON y lo guardamos en un archivo
$jsonString = ConvertTo-Json $jsonObj -Depth 10
#guardamos el json en un archivo
Write-Output $jsonString | Out-File -Encoding utf8 -FilePath $file_json_report

# Obtenemmos el token de acceso a la API
$token = $GRModule.GetAccessToken($GRModule.login_uri)
#enviamos el reporte a la api de gorillaReport
$result = $GRModule.PushReport($token,$jsonString,$GRModule.update_report_uri)
Write-Host "gorillareport webapp response: " $result.message
#DEBUG: escribir en el fichero de logs
$DATE = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $GRModule.log_file -Value "$DATE - $this_script - : gorillareport webapp response: -> $result.message"
exit 0