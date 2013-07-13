. .\New-MOFSchema.ps1

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
}