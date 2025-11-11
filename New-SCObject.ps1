Function New-SCObject {
    [cmdletbinding()]
    param(
        [string[]]$stringinput,
        [int]$linenumber
    )
    $Object = [PSCustomObject]@{}
    $internallinenumber = $linenumber
    while ($stringinput[$internallinenumber] -notmatch "^\s*$") {
        $Title,$Content = $stringinput[$internallinenumber] -split ":"
        if ($stringinput[$internallinenumber] -notlike "*:*") {
            Add-Member -InputObject $Object -MemberType "NoteProperty" -Name "PossibleStates" -Value $Title.trim()
        } else {
            Add-Member -InputObject $Object -MemberType "NoteProperty" -Name $Title.trim() -Value $Content.trim()
        }
        $internallinenumber += 1
    }
    Write-Output $Object
}

$services = sc.exe query state=all

$Objects = foreach ($linenumber in (0..$services.count)) {
    if ($Services[$linenumber] -match "SERVICE_NAME:") {
        New-SCObject -stringinput $Services -linenumber $linenumber
    }
}
