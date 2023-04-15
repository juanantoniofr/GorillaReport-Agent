#$logFile = Get-Content -Path "c:\gorilla\cache\gorilla.log"
$logFile = "c:\gorilla\cache\gorilla.log"
$pattern = "INFO:\s\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}.\d{6}\sRetrieving manifest:"
$matches = Select-String -Path $logFile -Pattern $pattern -AllMatches

foreach ($match in $matches) {
    Write-Host "Ocurrencia encontrada en la línea $($match.LineNumber)"
}

Write-Host $matches[$matches.Count-1].LineNumber