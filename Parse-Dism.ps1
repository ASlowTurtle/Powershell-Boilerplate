<#
    .SYNOPSIS
    Parses output of dism /get-drivers /online
    .DESCRIPTION
    This script provides an alternative to Get-WindowsDriver.
    Get-WindowsDriver seems to hang in certain situations and doesn't finish.
    The data provided by this script are usefull for matching Published inf
    names to the original name of the inf file.
    E. g. matching oem12.inf to it's original inf file name.
    Output is provided by $DismoutputParsed
    
    This script contains languages specific code as the output of dism is localized.
    Alternatively one could use the pattern "oem.*\.inf" or "Version" as matching pattern.
#>

$Languages = [PSCustomObject]@{
    "English" = "Published Name"
    "German"  = "" # ADD
}

$Lang = Get-WinSystemLocale
switch -Wildcard ($Lang.DisplayName) {
    "*English*"     {$Pattern = $Languages.English}
    "*German*"      {$Pattern = $Languages.German}
    "*Deutsch*"     {$Pattern = $Languages.German}
    default         {$Pattern = $false}
}


if ($Pattern) {
    $dismoutput = dism.exe /get-drivers /online
    $PublishedName = $dismoutput | select-string -Pattern $Pattern
    $DismoutputParsed = foreach ($LineNumber in $PublishedName.LineNumber) {
        $DriverObject = [PSCustomObject]@{
            "PublishedName"        = ($dismoutput[$LineNumber-1]   -split ":")[1].trim()
            "OriginalFileName"    = ($dismoutput[$LineNumber] -split ":")[1].trim()
            "Inbox"                 = ($dismoutput[$LineNumber+1] -split ":")[1].trim()
            "ClassName"            = ($dismoutput[$LineNumber+2] -split ":")[1].trim()
            "ProviderName"         = ($dismoutput[$LineNumber+3] -split ":")[1].trim()
            "Date"                  = ($dismoutput[$LineNumber+4] -split ":")[1].trim()
            "Version"               = ($dismoutput[$LineNumber+5] -split ":")[1].trim()
        }
        $DriverObject
    }
} else {
    Write-Host "No matching language found."
}

$DismoutputParsed