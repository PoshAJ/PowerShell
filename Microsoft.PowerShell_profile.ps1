function Test-IsAdmin {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = [Security.Principal.WindowsPrincipal] $Identity

    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}


function Prompt {
    $PathArray = $ExecutionContext.SessionState.Path.CurrentLocation.Path.TrimEnd("\") -isplit '\\'

    Write-Host -NoNewline ("[{0}]: " -f $env:COMPUTERNAME.ToLower())

    switch ($null) {
        { Test-IsAdmin } {
            Write-Host -NoNewline -ForegroundColor red "ADMIN "
        }
        { $PSDebugContext } {
            Write-Host -NoNewline -ForegroundColor magenta "DEBUG "
        }
        default {
            Write-Host -NoNewline "PS "
        }
    }
    Write-Host -NoNewline ("[{0}]" -f $PathArray[-1])
    Write-Host -NoNewline (">" * ($nestedPromptLevel + 1))

    return " "
}


function Out-Password ([int] $Length = 16) {
    # https://www.w3schools.com/charsets/ref_html_ascii.asp
    return -join (1..$Length | ForEach-Object { [char] (Get-Random -Minimum 33 -Maximum 127) })
}


# Default Configurations
Set-PSReadLineOption -BellStyle None
Set-Alias -Name "test" -Value "Invoke-Pester"
$PSSessionOption = New-PSSessionOption -NoMachineProfile -OperationTimeout 30000 -OpenTimeout 30000 -CancelTimeout 30000
$PSDefaultParameterValues = @{
    "Get-Help:ShowWindow"             = $true
    "Format-Table:AutoSize"           = $true
    "Out-Default:OutVariable"         = "0"
    "Invoke-WebRequest:Verbose"       = $true
    "Export-Csv:NoTypeInformation"    = $true
    "ConvertTo-Csv:NoTypeInformation" = $true
    "Invoke-Pester:Output"            = "Detailed"
    "*:Encoding"                      = "Utf8"
}
$OutputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not $Error) {
    Clear-Host
}

# https://artii.herokuapp.com/make?text=PowerShell&font=cyberlarge
@"
     _____   _____  _  _  _ _______  ______ _______ _     _ _______
    |_____] |     | |  |  | |______ |_____/ |______ |_____| |______ |      |
    |       |_____| |__|__| |______ |     \ ______| |     | |______ |_____ |_____
"@
