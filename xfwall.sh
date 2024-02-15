#!/bin/bash

# Función para obtener la URL del fondo de pantalla desde la API de Wallhaven
get_wallpaper_url() {
    # Realizar la solicitud a la API de Wallhaven y extraer la URL del fondo de pantalla
    # wallpaper_url=$(curl -s "https://wallhaven.cc/api/v1/w/l8v3ey" | jq -r '.data[0].path')
    wallpaper_url=$(curl -s "https://wallhaven.cc/api/v1/w/l8v3ey")
    echo "$wallpaper_url"
}

# Función para establecer el fondo de pantalla en XFCE4
set_wallpaper() {
    # Comando para cambiar el fondo de pantalla en XFCE4, ajusta la ruta según tu configuración
    # xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$1"
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP1/workspace0 -s "$1"
}

# Establecer el tiempo en segundos para cambiar el fondo de pantalla
interval=1800  # Cambia cada 30 minutos, ajusta según tus preferencias

while true; do
    wallpaper_url=$(get_wallpaper_url)
    set_wallpaper "$wallpaper_url"
    sleep "$interval"
done
