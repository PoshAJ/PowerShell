using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic

<#

    .DESCRIPTION
        White-space is irrelevant to PowerShell, but its proper use is key to writing easily readable code.
        Cast operators should be followed by a space for consistency and improved readability.

    .EXAMPLE
        Measure-SpaceAfterCastOperator -ScriptBlockAst $ScriptBlockAst

    .PARAMETER ScriptBlockAst
        Specifies the ScriptBlockAst.

#>

function Measure-SpaceAfterCastOperator {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )

    ## BEGIN ##################################################################
    begin {
        $Results = [List[DiagnosticRecord]] @()

        $Predicate = {
            param ([Ast] $Ast)

            if (($Ast -is [ConvertExpressionAst]) -or ($Ast -is [PropertyMemberAst]) -or ($Ast -is [ParameterAst])) {
                # exceptions: (?=\]) for nested brackets like [int[]], :: for constants like [int]::MaxValue and \. for methods like $Array[1].Value
                $Pattern = "^([^\[\]]|(?\[)|(?<-bracket>\]( |\r?\n|(?=\])|::|\.|$)))*(?(bracket)(?!))$"

                return ($Ast.Extent.Text -inotmatch $Pattern)
            }

            return $false
        }
    }

    ## PROCESS ################################################################
    process {
        $Violations = $ScriptBlockAst.FindAll($Predicate, $true)

        if ($Violations.Count -ne 0) {
            foreach ($Violation in $Violations) {
                $Result = [DiagnosticRecord] @{
                    "Message"           = (Get-Help $MyInvocation.MyCommand.Name).Description.Text
                    "Extent"            = $Violation.Extent
                    "RuleName"          = "CUseSpaceAfterCastOperator"
                    "Severity"          = "Information"
                    "RuleSuppressionID" = $null
                }

                $null = $Results.Add($Result)
            }
        }

        return $Results.ToArray()
    }

    ## END ####################################################################
    end {
    }
}


<#

    .DESCRIPTION
        PowerShell is not case sensitive, but we follow capitalization conventions to make code easy to read.
        Binary Operators should be explicit and have the correct casing for consistency and improved readability.

    .EXAMPLE
        Measure-ExplicitBinaryOperatorCorrectCasing -Token $Token

    .PARAMETER Token
        Specifies the Token.

    .LINK
        https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/code-layout-and-formatting#capitalization-conventions

#>

function Measure-ExplicitBinaryOperatorCorrectCasing {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.Token[]]
        $Token
    )

    ## BEGIN ##################################################################
    begin {
        $Results = [List[DiagnosticRecord]] @()

        $Predicate = {
            param ([Token] $Token)

            if (($Text = [TokenTraits]::Text($Token.Kind)) -ne "generic") {
                return ($Token.Extent.Text -cne $Text)
            }

            return $false
        }
    }

    ## PROCESS ################################################################
    process {
        # for tokens, it is much faster to filter using .Where() then evaluate using $Predicate vice
        # combining the filter in $Predicate. This is in contast to Ast where we can use .FindAll()
        $Test = $Token.Where({ $_.TokenFlags.HasFlag([TokenFlags]::BinaryOperator) })
        $Violations = $Test.Where({ $Predicate.Invoke($_) })

        if ($Violations.Count -ne 0) {
            foreach ($Violation in $Violations) {
                $Text = [TokenTraits]::Text($Violation.Kind)

                $Result = [DiagnosticRecord] @{
                    "Message"           = "Expected Binary Operator '$( $Violation.Extent.Text )' to be '${Text}'."
                    "Extent"            = $Violation.Extent
                    "RuleName"          = "CUseExplicitBinaryOperatorCorrectCasing"
                    "Severity"          = "Information"
                    "RuleSuppressionID" = $null
                }

                $null = $Results.Add($Result)
            }
        }

        return $Results.ToArray()
    }

    ## END ####################################################################
    end {
    }
}


<#

    .DESCRIPTION
        PowerShell is not case sensitive, but we follow capitalization conventions to make code easy to read.
        Keywords should have the correct casing for consistency and improved readability.

    .EXAMPLE
        Measure-ExplicitKeywordCorrectCasing -Token $Token

    .PARAMETER Token
        Specifies the Token.

    .LINK
        https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/code-layout-and-formatting#capitalization-conventions

#>

function Measure-ExplicitKeywordCorrectCasing {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.Token[]]
        $Token
    )

    ## BEGIN ##################################################################
    begin {
        $Results = [List[DiagnosticRecord]] @()

        $Predicate = {
            param ([Token] $Token)

            if ($Text = [TokenTraits]::Text($Token.Kind)) {
                return ($Token.Extent.Text -cne $Text)
            }

            return $false
        }
    }

    ## PROCESS ################################################################
    process {
        # for tokens, it is much faster to filter using .Where() then evaluate using $Predicate vice
        # combining the filter in $Predicate. This is in contast to Ast where we can .FindAll()
        $Test = $Token.Where({ $_.TokenFlags.HasFlag([TokenFlags]::Keyword) })
        $Violations = $Test.Where({ $Predicate.Invoke($_) })

        if ($Violations.Count -ne 0) {
            foreach ($Violation in $Violations) {
                $Text = [TokenTraits]::Text($Violation.Kind)

                $Result = [DiagnosticRecord] @{
                    "Message"           = "Expected Keyword '$( $Violation.Extent.Text )' to be '${Text}'."
                    "Extent"            = $Violation.Extent
                    "RuleName"          = "CUseExplicitKeywordCorrectCasing"
                    "Severity"          = "Information"
                    "RuleSuppressionID" = $null
                }

                $null = $Results.Add($Result)
            }
        }

        return $Results.ToArray()
    }

    ## END ####################################################################
    end {
    }
}


<#

    .DESCRIPTION
        White-space is irrelevant to PowerShell, but its proper use is key to writing easily readable code.
        Functions should be surrounded with two blank lines for consistency and improved readability.

    .EXAMPLE
        Measure-NewLineAroundFunction -ScriptBlockAst $ScriptBlockAst

    .PARAMETER ScriptBlockAst
        Specifies the ScriptBlockAst.

    .LINK
        https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/code-layout-and-formatting#blank-lines-and-whitespace

#>

function Measure-NewLineAroundFunction {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )

    ## BEGIN ##################################################################
    begin {
        $Results = [List[DiagnosticRecord]] @()

        $Predicate = {
            param ([Ast] $Ast)

            if (($Ast -is [FunctionDefinitionAst]) -and ($Ast.Parent -isnot [FunctionMemberAst])) {
                $Tokenize = [PSParser]::Tokenize($Ast.Parent, [ref] $null)
                $Comment = $Tokenize.Where({ $_.Type -eq [PSTokenType]::Comment })
                $Replace = ($Comment.Content | Select-Object -Unique | ForEach-Object { [regex]::Escape($_ + "`r`n") }) -join "|"

                $Parent = $Ast.Parent.Extent.Text -ireplace $Replace
                $Self = $Ast.Extent.Text -ireplace $Replace

                # exceptions: (\w+ \{) for begin, process, end; (^(\r?\n){0,2} for start of code; (\r?\n){0,2}$) for end of code; and [^\S\r\n]* for indented lines
                $Pattern = "(^(\w+ \{)|(\r?\n){0,2}|(\r?\n){3})[^\S\r\n]*$( [regex]::Escape($Self) )((\r?\n){3}|(\r?\n){0,2}|\}$)"

                return ($Parent -inotmatch $Pattern)
            }

            return $false
        }
    }

    ## PROCESS ################################################################
    process {
        $Violations = $ScriptBlockAst.FindAll($Predicate, $true)

        if ($Violations.Count -ne 0) {
            foreach ($Violation in $Violations) {
                $Result = [DiagnosticRecord] @{
                    "Message"           = (Get-Help $MyInvocation.MyCommand.Name).Description.Text
                    "Extent"            = $Violation.Extent
                    "RuleName"          = "CUseNewLineAroundFunction"
                    "Severity"          = "Information"
                    "RuleSuppressionID" = $null
                }

                $null = $Results.Add($Result)
            }
        }

        return $Results.ToArray()
    }

    ## END ####################################################################
    end {
    }
}


Export-ModuleMember -Function Measure-*
