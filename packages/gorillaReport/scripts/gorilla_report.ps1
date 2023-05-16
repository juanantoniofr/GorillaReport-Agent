$homedir = [Environment]::GetFolderPath("UserProfile")
$gorillaReportDir = "gorillaReport"

$register_client = "$homedir\$gorillaReportDir\scripts\register_client.ps1"
$register_basic_info = "$homedir\$gorillaReportDir\scripts\register_basic_info.ps1"
$register_gorilla_report = "$homedir\$gorillaReportDir\scripts\register_gorilla_report.ps1"

$scripts = @($register_client, $register_basic_info, $register_gorilla_report)

foreach ($script in $scripts) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$script`"" -Wait -WindowStyle Hidden
}
