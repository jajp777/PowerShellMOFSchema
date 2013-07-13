function New-MOFSchema {
    param(
        [string]$FriendlyName,
        [ScriptBlock]$sb,
        [Switch]$AsPSObject,
        [Switch]$AsJSON
    )
    
    $MOFMap = [Ordered]@{
        Keys      = [Ordered]@{}
        Writes    = [Ordered]@{}
        Reads     = [Ordered]@{}
        ValueMaps = [Ordered]@{}
    }

    $MOFMap.FriendlyName = $FriendlyName

    function Set-Version {
        param(
            [Parameter(Mandatory)]
            [version]$script:version
        )

        $MOFMap.Version = $version
    }

    function Add-ClassName {
        param(
            [Parameter(Mandatory)]
            [string]$script:className
        )

        $MOFMap.ClassName = $className

    }
    
    function Add-Key { 
        param(
            [Parameter(Mandatory)]
            [string]$type,
            [Parameter(Mandatory)]
            [string]$name
        )
        
        $MOFMap.Keys.$name = $type
    }

    function Add-WriteProperty { 
        param(
            [Parameter(Mandatory)]
            [string]$type,
            [Parameter(Mandatory)]
            [string]$name
        )

        $MOFMap.Writes.$name = $type
    }

    function Add-WriteValueMap { 
        param(
            [Parameter(Mandatory)]
            [string[]]$valueMap,
            [Parameter(Mandatory)]
            [string]$type,
            [Parameter(Mandatory)]
            [string]$name
        )

        $MOFMap.ValueMaps.$name = @{Type=$type; Map=$valueMap}
    }

    function Add-ReadProperty { 
        param(
            [Parameter(Mandatory)]
            [string]$type,
            [Parameter(Mandatory)]
            [string]$name
        )

        $MOFMap.Reads.$name = $type
    }

    & $sb

    if($AsPSObject) {
        return [PSCustomObject]$MOFMap
    }

    if($AsJSON) {
        return $MOFMap | ConvertTo-Json
    }

    $MOFMap
}

function Export-MOF {
    param(
        [Parameter(ValueFromPipeline)]
        [HashTable]$Map
    )

    Begin {
        $MOFOutput = @()
    }

    Process {
    
        $Map.Keys.GetEnumerator()   | ForEach {$MOFOutput+= "`t[Key]   {0} {1};`r`n" -f  $_.Value, $_.Key}
        $Map.Writes.GetEnumerator() | ForEach {$MOFOutput+= "`t[write] {0} {1};`r`n" -f  $_.Value, $_.Key}
        $Map.Reads.GetEnumerator()  | ForEach {$MOFOutput+= "`t[read]  {0} {1};`r`n" -f  $_.Value, $_.Key}
        
        $Map.ValueMaps.GetEnumerator()  | ForEach {
            $target = '{{"{0}"}}' -f ($_.Value.Map -join '","')
            $MOFOutput+="`t[write,ValueMap{0},Values{0}] {1} {2};`r`n" -f $target, $_.Value.Type, $_.Key            
        }

@"
[version("$($Map.Version)"), FriendlyName("$($Map.FriendlyName)")] 
class $($Map.ClassName) : MSFT_BaseResourceConfiguration
{
$($MOFOutput)
};
"@
    }
}

cls

New-MOFSchema WebSite {

    Set-Version 1.0.1
    Add-ClassName Demo_IISWebsite

    Add-Key string Name

    Add-WriteProperty string PhysicalPath
    Add-WriteValueMap "Present", "Absent" string Ensure
    Add-WriteValueMap "Started", "Stopped" string State
    Add-WriteValueMap "http", "https" string Protocol[]
    Add-WriteProperty string BindingInfo[]
    Add-WriteProperty string ApplicationPool
    Add-ReadProperty string ID

} | Export-MOF