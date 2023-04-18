param (
    [Parameter(Mandatory=$true)]
    [String]$token,
    [Parameter(Mandatory=$true)]
    [String]$report,
    [Parameter(Mandatory=$true)]
    [String]$uri
)

$URI = $uri

$body = @{
    huid=(Get-CimInstance Win32_ComputerSystemProduct).UUID
    report = $report.ToString()
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
