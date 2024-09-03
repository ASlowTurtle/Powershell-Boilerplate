#$global:InteractiveLogging = $true
$global:LogPath = "c:\temp\test.log"

Function Write-Log {
    <#
    .SYNOPSIS
    Writes logs.
    .DESCRIPTION
    This function is used for logging.
    It creates the parent directory if it doesn't exist.
    .PARAMETER Message
    The message to be logged.
    .PARAMETER LogPath
    Path to the log file (fullname).
    .PARAMETER LogLevel
    ToDo. This can be used for verbose logging.
    This allows to optionally disable log messages
    of a specific level by using a global variable.
    .PARAMETER InteractiveLogging
    If this switch is used the message will be written
    to the console.
    Alternatively: $global:InteractiveLogging = $true
    .PARAMETER OnlyInteractive
    If this switch is provided the log won't be written
    and the message will only appear in the console.
    Alternatively: $global:OnlyInteractive = $true
    .NOTES
    Thanks to https://2pintsoftware.com/news/details/why-is-add-content-bad-in-powershell-51
    https://learn.microsoft.com/en-us/dotnet/api/system.io.streamwriter.-ctor
    ToDo: support for cmtrace.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [AllowNull()]
        [String]$Message,
        [String]$LogPath,
        [String]$LogLevel,
        [Switch]$InteractiveLogging,
        [Switch]$OnlyInteractive
    )
    if ($global:InteractiveLogging) {
        $InteractiveLogging = $global:InteractiveLogging
    }
    if ($global:OnlyInteractive) {
        $OnlyInteractive = $global:OnlyInteractive
    }
    if ($OnlyInteractive) {
        $InteractiveLogging = $true
    }

    if (-not ($local:LogPath)) {
        $LogPath = $global:LogPath
    }
    $LogDir = Split-Path -Path $local:LogPath
    if ($LogDir -and (-not (Test-Path -Path $LogDir))) {
        try {
            $null = mkdir "$LogDir" -ErrorAction:Stop
        } catch {
            Write-Error "Write-Log: Error creating directory [$LogDir]. Exiting gracefully but without logging."
            return
        }
    }
    $Date = Get-Date -UFormat "%Y-%m-%d %R:%S (UTC %Z)"
    $Message = [String]::Format("{0}: {1}",$local:Date,$local:Message)
    if (-not $OnlyInteractive) {
        # $true/$false for appending.
        $stream = [System.IO.StreamWriter]::new($local:LogPath, $true, ([System.Text.Utf8Encoding]::new()))
        $stream.WriteLine("$Message")
        $stream.close()
        $stream.Dispose()
        $stream = $null
    }
    if ($InteractiveLogging) {
        Write-Host $Message
    }
}

Function Write-CMLog {
    <#
    .SYNOPSIS
    Writes logs in the cmtrace format.
    .DESCRIPTION
    This function writes logs in a format conforming to the cmtrace format.
    .NOTES
    https://janikvonrotz.ch/2017/10/26/powershell-logging-in-cmtrace-format/
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [AllowNull()]
        [String]$Message,
        [String]$LogPath,
        [String]$LogLevel,
        [Switch]$InteractiveLogging,
        [Switch]$OnlyInteractive,
        [ValidateSet("Info", "Warning", "Error")]
        [String]$Type,
        [String]$Component
    )
    if ($global:InteractiveLogging) {
        $InteractiveLogging = $global:InteractiveLogging
    }
    if ($global:OnlyInteractive) {
        $OnlyInteractive = $global:OnlyInteractive
    }
    if ($local:OnlyInteractive) {
        $InteractiveLogging = $true
    }
    if (-not ($local:LogPath)) {
        $LogPath = $global:LogPath
    }
    $LogDir = Split-Path -Path $LogPath
    if ($LogDir -and (-not (Test-Path -Path $LogDir))) {
        try {
            $null = mkdir "$LogDir" -ErrorAction:Stop
        } catch {
            Write-Error "Write-Log: Error creating directory [$local:LogDir]. Exiting gracefully but without logging."
            return
        }
    }

    $time = Get-Date -Format "HH:mm:ss.ffffff"
    $date = Get-Date -Format "M-d-yyyy"

    $Message = [String]::Format('<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="{4}" type="{5}" thread="{6}" file="{7}">',$local:Message,$local:time,$local:date,$local:Component,$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name),$local:Type,$([Threading.Thread]::CurrentThread.ManagedThreadId),$local:file)

    if (-not $OnlyInteractive) {
        # $true/$false for appending.
        $stream = [System.IO.StreamWriter]::new($local:LogPath, $true, ([System.Text.Utf8Encoding]::new()))
        $local:stream.WriteLine("$local:Message")
        $local:stream.close()
        $local:stream.Dispose()
        $local:stream = $null
    }
    if ($local:InteractiveLogging) {
        Write-Host $local:InteractiveLogging
        Write-Host $local:Message
    }
}