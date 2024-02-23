# XFWall

    __________________________________________________________________________
    |    ___   ___  ___________    __    ____  ___       __       __         |\ 
    |    \  \ /  / |   ____\   \  /  \  /   / /   \     |  |     |  |        | |                                                                    
    |     \  V  /  |  |__   \   \/    \/   / /  ^  \    |  |     |  |        | |
    |      >   <   |   __|   \            / /  /_\  \   |  |     |  |        | |
    |     /  .  \  |  |       \    /\    / /  _____  \  |   ----.|   ----.   | |
    |    /__/ \__\ |__|        \__/  \__/ /__/     \__\ |_______||_______|   | |
    |________________________________________________________________________| |
     \________________________________________________________________________\'

**XFWall** is a bash script to set wallpapers from Wallhaven API in XFCE. Works with X11.

**IMPORTANT:** I wrote this script for myself, even if I tried to make this compatible with others devices I can´t guarantee that works on every machine. If you found a problem or know how to solve it. Create a new issue.

__Programs required:__ The following software is necessary to execute XFWall with no problems
- curl
- jq
- xrandr
- git

These programs can be installed with:
```bash
$ sudo apt update && sudo apt install curl jq xrandr git
```

# Install
__XFWall can be installed by following these steps:__

+ Clone GitHub repository

    ```bash
    $ git clone https://github.com/alonsogonzalezleal/xfwall.git
    ```
+ Change to cloned directory

    ```bash
    $ cd ./xfwall
    ```
+ Give execute permission to install.sh

    ```bash
    $ chmod +x ./install.sh
    ```
+ Execute `install.sh` from terminal with option `--install`

    ```bash
    $ ./install.sh --install
    ```

# Uninstall
**WARNING:** Uninstalling xfwall also removes .xfwall folder located in the home user folder. So save your `config.json` if you don´t want to lose it.

__XFWall can be uninstalled by following these steps:__

+ Run `install.sh` with the option `--uninstall`

    ```bash
    $ ./install.sh --uninstall
    ```

+ Remove cloned folder

    ```bash
    $ rm -rf ./xfwall
    ```