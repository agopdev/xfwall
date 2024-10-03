# [Deprecated] - XFWall
        ___   ___  ___________    __    ____  ___       __       __      
        \  \ /  / |   ____\   \  /  \  /   / /   \     |  |     |  |     
         \  V  /  |  |__   \   \/    \/   / /  ^  \    |  |     |  |     
          >   <   |   __|   \            / /  /_\  \   |  |     |  |     
         /  .  \  |  |       \    /\    / /  _____  \  |  `----.|  `----.
        /__/ \__\ |__|        \__/  \__/ /__/     \__\ |_______||_______|

# Attention [Deprecated]
This script has been deprecated in favor of [Wallflow](https://github.com/agopdev/wallflow), a new script that allows you to change the wallpaper in almost any Linux desktop environment, as well as featuring new capabilities that will be added in the future.

**IT IS RECOMMENDED TO USE WALLFLOW INSTEAD OF XFWALL**

**XFWall** is a bash script to set wallpapers from **Wallhaven** API in **XFCE**. Works with X11.

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

+ Clone GitHub repository or download the last version from [Releases](https://github.com/agopdev/xfwall/releases)

    ```bash
    $ git clone https://github.com/agopdev/xfwall.git
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
- `start`: You can simply start xfwall by executing `xfwall start` in the terminal.
- `stop`: Kills all xfwall start processes.
- `change`: Change current wallpaper to a random tag already added without restarting the timer.
- `add`: Add a search parameter.
- `del`: Remove a search parameter.
- `enable`: Enable a search option.
- `disable`: Disable a search option.

### Global Options
- `-h`, `--help`: Prints xfwall info.
- `-sc`, `--show-config`: Prints the actual configuration.
- `-sm`, `--show-monitors`: Prints the available monitors.
- `-v`, `--version`: Prints the version of xfwall.

### Change options
- `""`: Change actual wallpaper from the previously added tags.
- `-q`, `--query`: Change actual wallpaper from a specific query.
- `-i`, `--id`: Change actual wallpaper from id.

### Search Options
- `-c`, `--categories`: Accepted values: general, anime, people.
- `-p`, `--purity`: Accepted values: sfw, sketchy, nsfw.

### Search Parameters
- `-r`, `--resolution`: Resolution for the search.
- `-t`, `--tag`: Tag for the search.

### Configuration Options
- `--interval`: Set time in seconds until next wallpaper.
- `--history`: Set the history length. Only saves the last images.
- `--api-key`: Set API key for the nsfw purity option.


## Donations
This script is a part-time hobby and sometimes not actively mantained in months (even years). 

Still, if you like my work and would like to support me, you can do so through this [link](https://paypal.me/agopdev).