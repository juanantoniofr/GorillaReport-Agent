param (
    [Parameter(Mandatory=$true)]
    [String]$token,
    [Parameter(Mandatory=$true)]
    [String]$logfile,
    [Parameter(Mandatory=$true)]
    [String]$uri
)

$URI = $uri

$jsonString_fromfile = Get-Content -Raw -Path $logfile 
$jsonObject = ConvertFrom-Json -InputObject $jsonString_fromfile

$report = $jsonObject | ConvertTo-Json

$body = @{
    huid=(Get-CimInstance Win32_ComputerSystemProduct).UUID
    report = $report 
}

$headers = @{
    "Authorization" = "Bearer $token"
}

$Params=@{
    Method = "Post"
    Uri = $URI
    Headers = $headers
    SkipCertificateCheck = 1
    Body = $body
}

$result = Invoke-RestMethod @Params 
return $result
