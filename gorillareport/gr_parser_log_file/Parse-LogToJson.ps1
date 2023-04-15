$logPath = "C:\gorilla\cache\gorilla.log"
$jsonPath = ".\result.json"


$pattern = "INFO:\s\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}.\d{6}\sRetrieving manifest:"
$ocurrencias = Select-String -Path $logPath -Pattern $pattern -AllMatches
$firstLine = $ocurrencias[$ocurrencias.Count-1].LineNumber

write-host $firstLine

$logFile = Get-Content -Path $logPath

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
        $log = $logPath
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
Write-Output $jsonString | Out-File -Encoding utf8 -FilePath $jsonPath