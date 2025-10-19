Describe 'Get-AuthdogUserInfo' {
    BeforeAll {
        # Import the module from the parent directory using the manifest
        $modulePath = Join-Path $PSScriptRoot '..' 'Authdog.psd1'
        Write-Host "Importing module from: $modulePath"
        
        try {
            Import-Module -Name $modulePath -Force -ErrorAction Stop
            Write-Host "Module imported successfully"
            
            # Verify the function is available
            $cmd = Get-Command Get-AuthdogUserInfo -ErrorAction SilentlyContinue
            if ($cmd) {
                Write-Host "Function Get-AuthdogUserInfo found: $($cmd.CommandType)"
            } else {
                Write-Host "Function Get-AuthdogUserInfo NOT found"
                throw "Function Get-AuthdogUserInfo not available after module import"
            }
        } catch {
            Write-Host "Error importing module: $($_.Exception.Message)"
            throw
        }
    }
    
    AfterAll {
        # Clean up the module
        Remove-Module -Name Authdog -Force -ErrorAction SilentlyContinue
    }
    
    It 'returns data on success' {
        Mock -CommandName Invoke-RestMethod -MockWith { @{ user = @{ id = '123' } } }
        $resp = Get-AuthdogUserInfo -BaseUrl 'https://api.authdog.com' -AccessToken 't'
        $resp.user.id | Should -Be '123'
    }

    It 'throws on 401' {
        Mock -CommandName Invoke-RestMethod -MockWith { 
            $ex = New-Object System.Net.WebException
            $ex.Response = New-Object System.Net.HttpWebResponse
            throw $ex
        }
        { Get-AuthdogUserInfo -BaseUrl 'https://api.authdog.com' -AccessToken 'bad' } | Should -Throw
    }
}
