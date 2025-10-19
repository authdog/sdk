Describe 'Get-AuthdogUserInfo' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..' 'Authdog.psd1'
        Import-Module $modulePath -Force
    }
    It 'returns data on success' {
        Mock -CommandName Invoke-RestMethod -ModuleName Authdog -MockWith { @{ user = @{ id = '123' } } }
        $resp = Get-AuthdogUserInfo -BaseUrl 'https://api.authdog.com' -AccessToken 't'
        $resp.user.id | Should -Be '123'
    }

    It 'throws on 401' {
        Mock -CommandName Invoke-RestMethod -ModuleName Authdog -MockWith { throw (New-Object System.Net.WebException) }
        { Get-AuthdogUserInfo -BaseUrl 'https://api.authdog.com' -AccessToken 'bad' } | Should -Throw
    }
}
