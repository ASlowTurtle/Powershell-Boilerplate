<#
    Retrieves the instance name of all installed usb storage devices from the registry.
    The instance name can be used with pnputil to uninstall the device.
#>

$USBDevices = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB"
foreach ($USBDevice in $USBDevices) {
    $USBDeviceType = get-childitem -path "Registry::$($USBDevice.Name)"
    foreach ($SingleDevice in $USBDeviceType) {
        if ($SingleDevice.GetValue("DeviceDesc") -match "(usbstor|disk)") {
            $SingleDevice.Name.replace("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\","")
        }
    }
}


# pnputil /remove-device "USB\VID_0951&PID_1666\E0D55EA574A8E420E8374D4C"
# pnputil /enum-devices | select-string -Pattern "SWD\\WPDBUSENUM"

# Enumerating using Get-PnpDevice
$USBStorageDevices = Get-PnpDevice -Class "USB" | Where-Object {$_.FriendlyName -like "USB Mass Storage Device*"} | Select-Object -ExpandProperty "InstanceID"
$USBStorageDevices = Get-PnpDevice -FriendlyName "USB Mass Storage Device" | Select-Object -ExpandProperty InstanceID



$ListOnly = $false
$ContainerIDs = @()
$DeviceKeys = @()
$DevicesToUninstall = @()
$USBDevices = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB"
foreach ($USBDevice in $USBDevices) {
    $USBDeviceType = get-childitem -path "Registry::$($USBDevice.Name)"
    foreach ($SingleDevice in $USBDeviceType) {
        if ($SingleDevice.GetValue("DeviceDesc") -match "(usbstor|disk)") {
            $DevicesToUninstall += $SingleDevice.Name.replace("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\","")
            $ContainerIDs += $SingleDevice.GetValue("ContainerID")
        }
    }
}
foreach ($ContainerID in $ContainerIDs) {
    $DeviceKeys += Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceContainers\$ContainerID\BaseContainers\$ContainerID" | Get-Member -MemberType NoteProperty | Where-Object "Name" -Notmatch "PS.*"
}
$DeviceKeys = $DeviceKeys.Name

foreach ($DeviceToUninstall in $DevicesToUninstall) {
    Write-Host "$DeviceToUninstall"
    if (-not $ListOnly) {
        pnputil.exe /disable-device $DeviceToUninstall
        pnputil.exe /remove-device $DeviceToUninstall
    }
    
}
foreach ($DeviceKey in $DeviceKeys) {
    Write-Host "HKLM:\SYSTEM\CurrentControlSet\Enum\$DeviceKey"
    if (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$DeviceKey") {
        Write-Host "Found regkey."
        if (-not $ListOnly) {
            Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$DeviceKey" -Force -Recurse
        }
    } else {
        Write-Host "Regkey not found."
    }
}
