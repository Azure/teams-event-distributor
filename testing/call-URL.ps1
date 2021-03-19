param
(
  [Parameter(Mandatory)]
  [string]
  ${Please provide the URL to test}
)


$URL   = ${Please provide the URL to test}
$count = 10

function Get-UrlStatusCode([string] $Url)
{
    try
    {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -DisableKeepAlive -MaximumRedirection 0 -SkipHttpErrorCheck -ErrorAction Ignore
        if($response.StatusCode -ne 302)
        {
            Write-Error -Message "Unexpected status code ($($response.StatusCode))" -ErrorAction Stop
        }
        Write-Host "Success! Status code: $($response.StatusCode) -- Backend: $($response.Headers['Location'])"
    }
    catch [Exception]
    {
        $_.Exception.Message
    }
}


for($i = 0; $i -lt $count; $i++){ Get-UrlStatusCode $URL }