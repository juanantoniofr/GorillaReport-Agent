# Download gorilla_report.ps1
$homedir = [Environment]::GetFolderPath("UserProfile")
$gorillaReportDir = "gorillaReport"
#Gorilla Server DNS Name or IP
$gorillaserver = "http://gorillaserver"
    
$file = "$gorillaserver/packages/gorillaReport/scripts/gorilla_report.ps1"
$outputFile = "$homedir\$gorillaReportDir\scripts\gorilla_report.ps1"

# descargamos los ficheros
If(!(test-path $outputFile)) {
    Remove-Item $outputFile
}
Invoke-WebRequest -Uri $file -OutFile $outputFile


# Scheduled task variables
$TaskName = "_gorilla_report"
$User = "practica"
$Passwd = "practica"
$script = "$homedir\$gorillaReportDir\scripts\gorilla_report.ps1"


if (-not (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)) {
    # Define scheduled task
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -NoLogo -WindowStyle Hidden -File $script"
    $Trigger = @(
        $(New-ScheduledTaskTrigger -Atlogon)
        $(New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10))
    )
    $Principal = New-ScheduledTaskPrincipal -UserId $User -RunLevel Highest
    $Set = New-ScheduledTaskSettingsSet
    $Object = New-ScheduledTask -Action $Action -Principal $Principal -Trigger $Trigger -Settings $Set
    Register-ScheduledTask $TaskName -InputObject $Object -User $User -Password $Passwd
}
