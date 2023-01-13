Set-PSDebug -Off
$distroPath = $PSScriptRoot;
$distroName = $distroPath -Replace '^\\\\wsl\$\\([^\\]+)\\.*$', '$1';

$devices = usbipd wsl list | Select-String "^[0-9].*ST.*Not attached" -CaseSensitive;
$device = $devices -Replace "(^[0-9]\S+)", '$1';
$device = ($device -split ' ')[0];

if($device){
    echo "ST-Link Attached"
    usbipd wsl attach -b $device -d $distroName
}else{
    $devices = usbipd wsl list | Select-String "^[0-9].*ST.*Attached" -CaseSensitive;
    $device = $devices -Replace "(^[0-9]\S+)", '$1';
    $device = ($device -split ' ')[0];
    if($device){
        echo "ST-Link attached already"
    }else{
        echo "ST-Link Not Found"
        Exit 1
    }  
}
