#!/bin/bash

install_script() {
    echo "Installing xfwall in /usr/local/bin/..."
    sudo cp ./src/xfwall.sh /usr/local/bin/xfwall
    sudo chmod +x /usr/local/bin/xfwall
    mkdir ~/.xfwall/history
    cp ./src/config.json ~/.xfwall/config.json
    echo "Installation completed! Try executing xfwall start"
}

uninstall_script() {
    echo "Uninstalling xfwall..."
    sudo rm /usr/local/bin/xfwall
    echo "xfwall completely removed!"
}

# Check if install.sh was executed as sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please execute install.sh as sudo."
    exit 1
fi

# Check if is installing or uninstalling xfwall
case "$1" in
    install)
        install_script
        ;;
    uninstall)
        uninstall_script
        ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
