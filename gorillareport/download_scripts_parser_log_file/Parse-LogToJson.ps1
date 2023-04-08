$logPath = "C:\gorilla\cache\gorilla.log"
$jsonPath = ".\result.json"

$logFile = Get-Content -Path $logPath

# Variables para almacenar la información
$id = 1
$name = 'test'
$catalog = ''
$manifest = ''
$startTime = ''
$endTime = ''
$duration = ''
$log = ''
$managedInstall = @()

# Recorremos las líneas del archivo de log
foreach ($line in $logFile) {
    if ($line -match 'Retrieving manifest: (.+)') {
        $manifest = $Matches[1]
    } elseif ($line -match 'Retrieving catalog: \[(.+)\]') {
        $catalog = $Matches[1]
    } elseif ($line -match 'INFO: (.+) Processing manifest') {
        $startTime = [datetime]::ParseExact($Matches[1], 'yyyy/MM/dd HH:mm:ss.ffffff', $null).ToString('yyyy-MM-dd HH:mm:ss')
    } elseif ($line -match '^(INFO|WARN): (\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\.\d{6}) (.+) (Installation SUCCESSFUL|Installation FAILED)$') {
        $endTime = [datetime]::ParseExact($Matches[2], 'yyyy/MM/dd HH:mm:ss.ffffff', $null).ToString('yyyy-MM-dd HH:mm:ss')
        $duration = (New-TimeSpan -Start $startTime -End $endTime).TotalMilliseconds.ToString()
        $log = 'gorilla.log'

        # Creamos el objeto para el managed install y lo añadimos al array
        $managedInstallObj = @{
            'id' = '1'
            'name' = $Matches[3]
            'version' = $Matches[2]
            'Checking' = @{
                'item' = $Matches[3]
                'Debug' = @{
                    'line1' = 'Algun mensaje'
                    'line2' = 'Algun mensaje'
                }
            }
            'Installing' = @{
                'item' = $Matches[3]
                'Debug' = @{
                    'line1' = 'Algun mensaje'
                    'line2' = 'Algun mensaje'
                }
                'result' = "$($Matches[3]) Installation successfully $($Matches[4]))"
            }
        }
        $managedInstall += $managedInstallObj
    }
}

# Creamos el objeto JSON
$jsonObj = @{
    'lastExecution' = @{
        'id' = $id
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
$json = ConvertTo-Json $jsonObj -Depth 10
$json | Out-File $jsonPath -Encoding UTF8
