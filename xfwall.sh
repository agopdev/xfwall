#!/bin/bash

# Check that required dependencies are installed
check_dependencies() {
    local dependencies=("jq" "curl")

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: '$dep' is not installed. Please install before executing xfwall."
            exit 1
        fi
    done
}

check_dependencies

# Get wallpaper URL and select one randomly
get_wallpaper_url() {
    local tag="landscapes"
    local categories="100"
    local purity="100"
    local apikey=""

    local output_json="/tmp/output.json"

    curl -s "https://wallhaven.cc/api/v1/search?q=$tag&categories=$categories&purity=$purity&apikey=$apikey" > "$output_json"

    local random_index
    total_elements=$(jq '.data | length' "$output_json")
    random_index=$(shuf -i 0-$((total_elements - 1)) -n 1)

    local wallpaper_url
    wallpaper_url=$(jq -r ".data[$((random_index))].path" "$output_json")

    rm "$output_json"

    echo "$wallpaper_url"
}

# Download and set wallpaper
update_wallpaper() {
    local wallpaper_url="$1"
    local image_path=~/.xfwall/history/last_img.jpg

    curl -o "$image_path" "$wallpaper_url"

    if [ $? -eq 0 ]; then
        xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitoreDP1/workspace0/last-image --set "$image_path"
    else
        echo "Error: The wallpaper could not be downloaded."
    fi
}

# Time in seconds
interval=10

while true; do
    wallpaper_url=$(get_wallpaper_url)
    update_wallpaper "$wallpaper_url"
    sleep "$interval"
done
