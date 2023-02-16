@{
    CustomRulePath      = "C:\Users\<username>\AppData\Roaming\Code\User\PSScriptAnalyzerRules.psm1"
    IncludeDefaultRules = $true
    ExcludeRules        = @("PSUseDeclaredVarsMoreThanAssignments", "PSAvoidUsingWriteHost", "PSAvoidGlobalVars", "PSUseShouldProcessForStateChangingFunctions")
}
