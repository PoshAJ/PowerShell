# Copyright (c) 2022 Gael Colas, https://github.com/gaelcolas/DscBuildHelpers
# Modified "Get-DscSplattedResource.ps1" by Anthony J. Raymond

param (
    [Parameter(ValueFromPipeline)]
    [hashtable] $Configurations,

    [Parameter()]
    [string] $OutputPath = (Get-Location -PSProvider FileSystem).Path
)

foreach ($Configuration in $Configurations.GetEnumerator()) {
    $ConfigurationName = $Configuration.Key -ireplace '''|"'

    $StringBuilder = [System.Text.StringBuilder]::new()

    $null = $StringBuilder.Append('param ([hashtable] $Properties)')

    $Length = $StringBuilder.AppendFormat('Configuration "{0}" {{', $ConfigurationName).Length

    $null = $StringBuilder.AppendFormat('Node "{0}" {{', $ConfigurationName)

    foreach ($Module in $Configuration.Value.GetEnumerator()) {
        $ModuleName = $Module.Key -ireplace '''|"'

        $null = $StringBuilder.Insert($Length, ('Import-DscResource -ModuleName "{0}";' -f $ModuleName))

        foreach ($Resource in $Module.Value.GetEnumerator()) {
            $ResourceSplit = $Resource.Key -ireplace '''|"' -isplit "\s"

            $null = $StringBuilder.AppendFormat('{0} "{1}" {{', $ResourceSplit[0], $ResourceSplit[1])

            foreach ($Key in $Resource.Value.Keys) {
                $null = $StringBuilder.AppendFormat('{0} = $Properties["{1}"]["{2}"]["{0}"];', ($Key -ireplace '"', '""'), ($Module.Key -ireplace '"', '""'), ($Resource.Key -ireplace '"', '""'))
            }

            $null = $StringBuilder.Append('}')
        }
    }

    $null = $StringBuilder.Append('}}')

    $null = $StringBuilder.AppendFormat('& {0} -OutputPath {1}', $Configuration.Key, $OutputPath)

    [scriptblock]::Create($StringBuilder.ToString()).Invoke($Configuration.Value)
}
