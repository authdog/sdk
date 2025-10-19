Describe 'Get-AuthdogUserInfo' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../Authdog.psd1" -Force
    }
    It 'returns data on success' {
        Mock -CommandName Invoke-RestMethod -MockWith { @{ user = @{ id = '123' } } }
        $resp = Get-AuthdogUserInfo -BaseUrl 'https://api.authdog.com' -AccessToken 't'
        $resp.user.id | Should -Be '123'
    }

    It 'throws on 401' {
        Mock -CommandName Invoke-RestMethod -MockWith { throw (New-Object System.Net.WebException) }
        { Get-AuthdogUserInfo -BaseUrl 'https://api.authdog.com' -AccessToken 'bad' } | Should -Throw
    }
}
