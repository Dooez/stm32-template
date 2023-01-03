# Description
This repository is a template for stm32 development in VSCode.
Main tools:
- [WSL](https://learn.microsoft.com/en-us/windows/wsl/)  
- [USB-IP](https://github.com/dorssel/usbipd-win/releases)  
- [CMake](https://cmake.org/)  
- [openOCD](https://openocd.org/)  
- [stlink](https://github.com/stlink-org/stlink)  

## First step: WSL installation
This toolchain was tested in WSL2 with Ubuntu 22.04. Without deep dive I was unable to make it work in Ubuntu 20.04.
Suggested installation:
0. (optional) Install Windows Terminal
1. Open PowerShell
2. type
    ```
    curl (("https://cloud-images.ubuntu.com",
    "wsl/jammy/current/",
    "ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz") -join "/") `
    --output ubuntu-22.04-tar.gz
    ```
    This will download Ubuntu 22.04 image. You can [browse](https://cloud-images.ubuntu.com/wsl) other images if you need a different version.  
3. Run
    ```
    wsl --import <Distribution Name> <Installation Folder> <Ubuntu WSL2 Image Tarball path>
    ```
    This will add additional distribution to WSL.  
    Example: 

    ```
    wsl --import Ubuntu-stm32  "C:\Users\<Username>\Documents\Ubuntu-stm32" .\ubuntu-22.04-tar.gz
    ```
    At this point the distributon is added. By default tere is only root user. We need to create new user.  
4. Run  
`wsl -d <Distribution Name>`   
We've now entered ubuntu shell.  
5. Run  
`NEW_USER=<USERNAME>`   
This will store username for future use.  
  
    Next, create user and set password:  
    `useradd -m -G sudo -s /bin/bash "$NEW_USER"`  
    `passwd "$NEW_USER"`  
6. Run
    ```
    tee /etc/wsl.conf <<_EOF
    [user]
    default=${NEW_USER}
    _EOF
    ```
    This will change created user to be the default when you log in.  
7. Run  
`logout`  
to exit wsl and then run   
`wsl --terminate <Distribution Name>`  
to close wsl.

You can use steps 3-7 to create additional WSL distributions.

First step was done using guide by [cloudbytes.dev](https://cloudbytes.dev/snippets/how-to-install-multiple-instances-of-ubuntu-in-wsl2)

## Second step: Setting up WSL
1. Launch VSCode.
2. Install [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl).
3. Open new WSL window using distro created in the first step.  
3.1 (optional) Open terminal in vscode and create folder sctructure.
Example:  
`mkdir repos && cd repos`
4. Clone this repository with submodules.  
`git clone --recurse-submodules https://github.com/Dooez/stm32-template`  
5. Open cloned folder in VSCode.
6. Install suggested extensions.
7. Run  
`sudo ./install_toolchain.sh $USER`  
This will install required tools and set up usbip.
8. After script finished, relaunch WSL.


## Thirds step: Setting up USB-IP

1. Install [USB-IP](https://github.com/dorssel/usbipd-win/releases)
2. Open PowerShell
3. Run  
`usbipd wsl list`  
    This will show list of devices. Find your busid of youe STLink device:
    ```
    BUSID  VID:PID    DEVICE           STATE
    1-1    0483:3748  STM32 STLink     Not attached
    ```
    In this case busid is 1-1
4. Run  
`usbipd wsl attach --busid <busid> -d <Distribution Name>`  
This will attach STLink to WSL. To check if everyuthing is working run  
`usbipd wsl list`  

    You should see 
    ```
    BUSID  VID:PID    DEVICE           STATE
    1-1    0483:3748  STM32 STLink     Attached - Ubuntu-22.04
    ```
5. (optinal) Run in WSL  
`lsusb`  
And you should see your device
    ```
    Bus 001 Device 002: ID 0483:3748 STMicroelectronics ST-LINK/V2
    ```

See [usbipd wiki](https://github.com/dorssel/usbipd-win/wiki/WSL-support) for more detailed info.

## Usage

1. After running installation shell script, installing the extensions and relaunching VSCode CMake Tools should ask for kit. If not, you may select kit from bottom panel. If everything is successfully installed, arm-none-eabi will be available, this is the kit you need.
2. Open CMakeLists.txt and change MCU model to match your device. After saving CMakeLists.txt CMake Tools extension will run configuration and all dependencies should be downloaded.
3. Open .vscode/launch.json and update `device`, `configFiles` and `svdFile`. You can find .svd file in the folder if CMake ran successfully.
4. To build use [CMake: build] build task (Ctrl + Shift + B by default) or hotkey (F7 by default).
5. To flash use [flash] build task (Ctrl + Shift + B by default).
6. For debugging use Run and Debug window (Ctrl + Shift + D by default) or hotkey (F5).  
You can update the binary without stopping the debug by using Restart (Ctrl + Shift + F5, or green circular arrow on debug panel)
