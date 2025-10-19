function Get-AuthdogUserInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        [string]$ApiKey
    )

    $headers = @{
        'Content-Type' = 'application/json'
        'User-Agent'   = 'authdog-powershell-sdk/0.1.0'
        'Authorization' = "Bearer $AccessToken"
    }

    if ($ApiKey) {
        $headers['Authorization'] = "Bearer $ApiKey"
    }

    $url = "$($BaseUrl.TrimEnd('/'))/v1/userinfo"

    try {
        $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop
        return $response
    } catch [System.Net.WebException] {
        $ex = $_.Exception
        if ($ex.Response) {
            $statusCode = [int]$ex.Response.StatusCode
            $reader = New-Object System.IO.StreamReader($ex.Response.GetResponseStream())
            $body = $reader.ReadToEnd()
            if ($statusCode -eq 401) {
                throw "Unauthorized - invalid or expired token"
            }
            try {
                $errObj = $body | ConvertFrom-Json -ErrorAction Stop
                if ($statusCode -eq 500) {
                    if ($errObj.error -eq 'GraphQL query failed') { throw 'GraphQL query failed' }
                    if ($errObj.error -eq 'Failed to fetch user info') { throw 'Failed to fetch user info' }
                }
            } catch {}
            throw "HTTP error $statusCode: $body"
        }
        throw "Request failed: $($ex.Message)"
    } catch {
        throw $_
    }
}
