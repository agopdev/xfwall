#!/bin/bash

get_actual_user(){
    local user=${SUDO_USER:-$USER}
    echo "$user"
}

install_script() {
    echo "Installing xfwall in /usr/local/bin/..."
    
    local user=$(get_actual_user)
    local user_home=$(eval echo ~$user)
    
    sudo cp ./src/xfwall.sh /usr/local/bin/xfwall
    sudo chmod +x /usr/local/bin/xfwall
    mkdir -p "$user_home/.xfwall/history"
    cp ./src/config.json "$user_home/.xfwall/config.json"
    sudo chown -R "$user" "$user_home/.xfwall"

    echo "Installation completed! Try executing xfwall --help"
}


uninstall_script() {    
    echo "Uninstalling xfwall..."

    local user=$(get_actual_user)
    local user_home=$(eval echo ~$user)
    sudo rm /usr/local/bin/xfwall
    sudo rm -rf "$user_home/.xfwall"
    echo "xfwall completely removed!"
}

# Check if install.sh was executed as sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please execute install.sh as sudo."
    exit 1
fi

# Check if is installing or uninstalling xfwall
case "$1" in
    --install)
        install_script
        ;;
    --uninstall)
        uninstall_script
        ;;
    *)
        echo "Usage: $0 {--install|--uninstall}"
        exit 1
        ;;
esac
