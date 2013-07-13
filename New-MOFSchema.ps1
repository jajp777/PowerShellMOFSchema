# http://technet.microsoft.com/en-us/library/dn249927.aspx

function New-MOFSchema {
    param(
        [string]$FriendlyName,
        [ScriptBlock]$sb
    )

    $script:MOFOutput = @()  

    function Set-Version {
        param(
            [Parameter(Mandatory)]
            [version]$script:version
        )
    }

    function Add-ClassName {
        param(
            [Parameter(Mandatory)]
            [string]$script:className
        )
    }
    
    function Add-Key { 
        param(
            [Parameter(Mandatory)]
            [string]$type,
            [Parameter(Mandatory)]
            [string]$name
        )

        $script:MOFOutput+="`t[Key] {0} {1};" -f $type, $name
    }

    function Add-WriteProperty { 
        param(
            [Parameter(Mandatory)]
            [string]$type,
            [Parameter(Mandatory)]
            [string]$name
        )

        $script:MOFOutput+="`t[write] {0} {1};" -f $type, $name
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

        $target = '{{"{0}"}}' -f ($valueMap -join '","')
        
        $script:MOFOutput+="`t[write,ValueMap{0},Values{0}] {1} {2};" -f $target, $type, $name
    }

    function Add-ReadProperty { 
        param(
            [Parameter(Mandatory)]
            [string]$type,
            [Parameter(Mandatory)]
            [string]$name
        )

        $script:MOFOutput+="`t[read] {0} {1};" -f $type, $name
    }

    & $sb
   
@"
[version("$($version)"), FriendlyName("$($FriendlyName)")] 
class $($className) : MSFT_BaseResourceConfiguration
{
$($MOFOutput -join "`r`n")
};
"@    
}
