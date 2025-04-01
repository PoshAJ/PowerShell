function Prompt {
    [string[]] $PathSplit = $ExecutionContext.SessionState.Path.CurrentLocation.Path.TrimEnd('\') -isplit '\\'

    Write-Host -NoNewline -Object "PS [$( $PathSplit[-1] )]"
    Write-Host -NoNewline -Object ('>' * ($nestedPromptLevel + 1))

    return ' '
}


function Out-Password ([int] $Length = (Get-Random -Minimum 16 -Maximum 32)) {
    # https://www.w3schools.com/charsets/ref_html_ascii.asp
    return -join [char[]] (Get-Random -Minimum 33 -Maximum 127 -Count $Length)
}


function Get-LoadedAssemblies {
    return [System.AppDomain]::CurrentDomain.GetAssemblies()
}


function Get-HistoryItems {
    return [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems().CommandLine
}


function Get-EnumValues ([Parameter(ValueFromPipeline)] [type] $InputObject) {
    if ($InputObject.BaseType.FullName -eq 'System.Enum') {
        return [System.Enum]::GetValues($InputObject)
    } else {
        Write-Warning -Message 'Type provided must be an Enum.'
    }
}


# Default Configurations
[scriptblock] $HistoryHandler = {
    switch -Regex ($args[0]) {
        '^(Clear-Host|clear|cls)' { return 'SkipAdding' }
        '^Out-Password' { return 'SkipAdding' }
        '^git' { return 'MemoryOnly' }
        '^Get-HistoryItems' { return 'MemoryOnly' }
        '^(Get-Command|Get-Help)' { return 'MemoryOnly' }
        default { return 'MemoryAndFile' }
    }
}
Set-PSReadLineOption -BellStyle 'None' -HistoryNoDuplicates -AddToHistoryHandler $HistoryHandler

$PSSessionOption = New-PSSessionOption -NoMachineProfile -OperationTimeout 30000 -OpenTimeout 30000 -CancelTimeout 30000

$PSDefaultParameterValues = @{
    'Get-Help:ShowWindow'             = $true
    'Format-Table:AutoSize'           = $true
    'Invoke-WebRequest:Verbose'       = $true
    'Export-Csv:NoTypeInformation'    = $true
    'ConvertTo-Csv:NoTypeInformation' = $true
    'Invoke-Pester:Output'            = 'Detailed'
    '*:Encoding'                      = 'Utf8'
}

$OutputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


if (-not $Error) {
    Clear-Host
}

@'
     _____   _____  _  _  _ _______  ______ _______ _     _ _______
    |_____] |     | |  |  | |______ |_____/ |______ |_____| |______ |      |
    |       |_____| |__|__| |______ |     \ ______| |     | |______ |_____ |_____
'@
