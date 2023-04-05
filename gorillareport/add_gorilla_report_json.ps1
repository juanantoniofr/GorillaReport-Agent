Import-Module C:\Users\tecnico\scripts\gorilla_scripts_module.psm1


function get_ip_address () {
    return Get-NetIPAddress -AddressFamily IPv4 | ForEach-Object { $_.IpAddress } | Select-String -Pattern '10.1.21.*'
}


# Bucle de espera (60segundos máximo) hasta que el equipo obtenga su IP
$cont = 0
while($true){
    if($null -eq $(get_ip_address)){
        Add-Content -Path $LOG_FILE -Value "$DATE - ($SCRIPT_NAME) - La ip es null"
        Start-Sleep -Seconds 1
        $cont++
    }
    else{
        break
    }
    if($cont -eq 60){
        break
    }
}

$content = Invoke-WebRequest "http://10.1.21.24/gorilla/get_manifest_from_ip/$(get_ip_address)" -UseBasicParsing


$manifest = "default_manifest"
# si el acceso a la url tiene Status Code = 200
If($content.StatusCode -eq 200){
    # Obtenemos el manifest
    $manifest = $content.Content
}


#########################################################################
############################ Scheduled tasks ############################
#########################################################################
$tasks = '_gorilla', '_set_default_printer', '_set_screen_resolution'
$dict_tasks = @{}
foreach( $taskname in $tasks){
    # LastRunTime: código en decimal del resultado de la última ejecución de la tarea
    $json_infoTask = Get-ScheduledTaskInfo -TaskName $taskname | Select-Object -Property LastRunTime, LastTaskResult, NextRunTime
    $dict_tasks["$taskname"] = $json_infoTask
}

#########################################################################
############################## status file ##############################
#########################################################################
[string[]]$status_file_content = Get-Content -Path "C:\Users\tecnico\scripts\status\status.txt"


#########################################################################
################################ hardware ###############################
#########################################################################
$Win32_BIOS            = Get-CimInstance -ClassName Win32_BIOS
$Win32_Baseboard       = Get-CimInstance -ClassName Win32_Baseboard
$Win32_OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
$Win32_PhysicalMemory  = Get-CimInstance -ClassName Win32_PhysicalMemory
$Win32_Processor       = Get-CimInstance -ClassName Win32_Processor

$dict_hardware = @{}
$dict_hardware["BIOS"] = $Win32_BIOS.Manufacturer + " - "  + $Win32_BIOS.SerialNumber + " - " + $Win32_BIOS.Version
$dict_hardware["CPU"] = $Win32_Processor.Name
$dict_hardware["Placa Base"] = $Win32_Baseboard.Manufacturer + " - " + $Win32_Baseboard.Product

foreach($item in $Win32_PhysicalMemory){
    $key = $item.Banklabel
    $value = ""
    $value += $item.Manufacturer + " - " + ($item.Configuredclockspeed).ToString() + "Mhz" + " - "
    $value += ($item.Devicelocator).ToString() + " - " + ([math]::truncate($item.capacity / 1GB)).ToString() + "GB"
    $dict_hardware["Memoria $key"] = $value
}

$disk_count = 1
foreach($item in Get-Disk){
    $key = $item.Model
    $value = ""    
    $value = ([math]::truncate($item.size / 1GB)).ToString() + "GB"
    $dict_hardware["Disco $disk_count"] = $key + " - " + $value
    $disk_count += 1
}

$dict_hardware["Sistema Operativo"] = $Win32_OperatingSystem | Select-Object Version, BuildNumber

foreach($item in Get-NetAdapter){
    $key = $item.Name
    $value = ""
    $value = $item.InterfaceDescription + " - " + $item.MacAddress + " - " + $item.LinkSpeed
    $dict_hardware["$key"] = $value
}


#########################################################################
############################# windows updates ###########################
#########################################################################
$dict_windows_updates = @{}
$pending_windows_updates = Get-WindowsUpdate -Severity Critical, Important

foreach($item in $pending_windows_updates){
    $key = $item.KB
    $value = $item | Select-Object Size, Title
    $dict_windows_updates["$key"] = $value
}


#########################################################################
############################## status file ##############################
#########################################################################
[string[]]$log_file_content = Get-Content -Path "C:\Users\tecnico\scripts\logs\logs.txt" -Tail 25



############################################
################## all data ################
############################################
$data = @{}
$data["Date"] = (Get-Date -Format "dddd dd/MM/yyyy HH:mm").ToString()
$data["Scheduled tasks"] = $dict_tasks
$data["Status file"] = [string[]]$status_file_content
$data["Hardware"] = $dict_hardware

Start-Sleep -Seconds 1

If ($null -eq $pending_windows_updates) {
    $data["SIN Windows updates (important, critical) pendientes"] = ""
}
Else {
    $data["Windows updates criticas pendientes"] = $dict_windows_updates
}
$data["Logs (last 25)"] = [string[]]$log_file_content

#######################
#### send POST DATA ###
#######################
$uri = "https://10.1.21.24/gorilla/add_gorilla_report/$manifest"
$Body = @{
    json_data = $data | ConvertTo-Json
}
 
$data = Invoke-RestMethod -Method POST -Uri $uri -Body $Body
