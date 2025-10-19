Describe 'Get-AuthdogUserInfo' {
    BeforeAll {
        # Import the module from the parent directory
        $modulePath = Join-Path $PSScriptRoot '..' 'Authdog.psm1'
        Import-Module -Name $modulePath -Force -ErrorAction Stop
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
