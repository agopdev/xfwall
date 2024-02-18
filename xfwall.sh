#!/bin/bash

# Get URL from wallpaper
get_wallpaper_url() {


    random_index=$((RANDOM % 31))
    tag="landscape"
    categories="110"
    purity="100"
    apikey="2RD4RdmlgWyjmUbInbkwL2PMuJQnscwO"


    wallpaper_url=$(curl -s "https://wallhaven.cc/api/v1/search?q=$tag&categories=$categories&purity=$purity&apikey=$apikey" | jq -r ".data[$random_index].path")
    echo "$wallpaper_url"
}

# Download wallpaper
download_wallpaper() {
    local wallpaper_url="$1"
    curl -o ~/.xfwall/history/last_img.jpg "$wallpaper_url"
}

# Función para establecer el fondo de pantalla en XFCE4
set_wallpaper() {
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorDP1/workspace0/last-image --set ~/.xfwall/history/last_img.jpg
}

# Time measured in seconds
interval=10

while true; do
    wallpaper_url=$(get_wallpaper_url)
    download_wallpaper "$wallpaper_url"
    set_wallpaper "$wallpaper_url"
    sleep "$interval"
done