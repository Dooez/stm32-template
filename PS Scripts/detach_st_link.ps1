Set-PSDebug -Off

$devices = usbipd wsl list | Select-String "^[0-9].*ST.*Attached" -CaseSensitive;
$device = $devices -Replace "(^[0-9]\S+)", '$1';
$device = ($device -split ' ')[0];
if($device){
    usbipd usbipd wsl detach -b $device
    echo "ST-Link detached succesfully"
}else{
    echo "ST-Link Not Found"
    Exit 1
}  

