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

# Usage
### Commands
- `Start`: You can simply start xfwall by executing `xfwall start` in the terminal.
- `Change`: Change the current wallpaper without restarting the timer.
-`Add`: Add a search parameter.
- `Delete`: Remove a search parameter.
- `Enable`: Enable a search option.
- `Disable`: Disable a search option.

### Global Options
- `-h`, `--help`: Shows this screen.
- `-sc`, `--show-config`: Shows the actual configuration.
- `-sm`, `--show-monitors`: Shows the available monitors.

### Search Options
- `-c`, `--categories`: Accepted values: general, anime, people.
- `-p`, `--purity`: Accepted values: sfw, sketchy, nsfw.

### Search Parameters
- `-r`, `--resolution`: Resolution for the search. Example: `add --resolution 1920x1080`.
- `-t`, `--tag`: Tag for the search. Example: `add --tag landscapes`.

### Configuration Options
- `-i`, `--interval`: Set time in seconds until next wallpaper. Example: `--interval 300`.
- `-a`, `--api-key`: Set API key for the nsfw purity option.


## Donations
This script is a part-time hobby and sometimes not actively mantained in months (even years). 

Still, if you like my work and would like to support me, you can do so through this [link](https://paypal.me/agopdev).