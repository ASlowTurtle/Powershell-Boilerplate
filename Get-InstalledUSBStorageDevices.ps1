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