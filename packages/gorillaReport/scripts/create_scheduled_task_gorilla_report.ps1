# Donwload file ps1 usando powershell 7
pwsh -Command {
    $homedir = [Environment]::GetFolderPath("UserProfile")
    $gorilladir = "gorillaReport"
    #Gorilla Server DNS Name or IP
    $gorillaserver = "gorillaserver.lc:8080"
    #$gorillaserver="172.23.23.132"

    # certificado pfx (requiere contraseña en windows ltsc)
    $pass = ConvertTo-SecureString -String 'asdf' -AsPlainText -Force
    $client_pfx_cert = Get-PfxCertificate -FilePath "C:\ProgramData\gorilla\cliente_gorillaserver.pfx" -Password $pass
    
    $file = "http://$gorillaserver/packages/gorillaReport/scripts/gorilla_report.ps1"
    $outputFile = "$homedir\$gorilladir\scripts\gorilla_report.ps1"

    # descargamos los ficheros
    If(!(test-path $outputFile)) {
        Remove-Item $outputFile
    }
    Invoke-WebRequest -Uri $file -OutFile $outputFile -Certificate $client_pfx_cert
}

$homedir = [Environment]::GetFolderPath("UserProfile")
$gorilladir = "gorillaReport"

# Scheduled task variables
$TaskName = "_gorilla_report"
$User = "tecnico"
$script = "$homedir\$gorilladir\scripts\gorilla_report.ps1"



if($null -eq (Get-ScheduledTask -TaskName $TaskName)){
    # Define scheduled task
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -NoLogo -NonInteractive -WindowStyle Hidden -File $script"
    $Trigger = @(
        $(New-ScheduledTaskTrigger -Atlogon)
        $(New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10))
    )
    $Principal = New-ScheduledTaskPrincipal -UserId $User -RunLevel Highest
    $Set = New-ScheduledTaskSettingsSet
    $Object = New-ScheduledTask -Action $Action -Principal $Principal -Trigger $Trigger -Settings $Set
    Register-ScheduledTask $TaskName -InputObject $Object -User "tecnico" -Password 'v3nt4n1t401'
}