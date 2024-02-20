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
    local tag=""
    local categories="100"
    local purity="100"
    local apikey="2RD4RdmlgWyjmUbInbkwL2PMuJQnscwO"
    local resolutions="1920x1080"
    local ratios=""
    local sorting="random"

    local output_json="/tmp/output.json"

    curl -s "https://wallhaven.cc/api/v1/search?q=$tag&categories=$categories&purity=$purity&resolutions=$resolutions&ratios=$ratios&sorting=$sorting&apikey=$apikey" > "$output_json"

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

# Change wallpaper
do_wallpaper_replacement () {
    local interval=1

    wallpaper_url=$(get_wallpaper_url)
    update_wallpaper "$wallpaper_url"
    sleep "$interval"
}

# Start xfwall
start () {
    
    while true; do
        do_wallpaper_replacement
    done
}

# Show help
display_help() {
    echo "
    __________________________________________________________________________
    |    ___   ___  ___________    __    ____  ___       __       __         |\ 
    |    \  \ /  / |   ____\   \  /  \  /   / /   \     |  |     |  |        | |                                                                    
    |     \  V  /  |  |__   \   \/    \/   / /  ^  \    |  |     |  |        | |
    |      >   <   |   __|   \            / /  /_\  \   |  |     |  |        | |
    |     /  .  \  |  |       \    /\    / /  _____  \  |  ´----.|  ´----.   | |
    |    /__/ \__\ |__|        \__/  \__/ /__/     \__\ |_______||_______|   | |
    |________________________________________________________________________| |
     \________________________________________________________________________\|


        Usage: See each category

        COMMON:
        Usage: xfwall [option]
        --help, -h              Prints this screen


        WALLPAPERS:
        Usage: xfwall [option]
        start                   Start xfwall with the actual configuration
        change                  Change actual wallpaper and restart timer


        SEARCH PARAMS:
        Usage: xfwall [add/del] [option] [value]
        --api-key, -a           Api key for the nsfw purity option
        --categories, -c        Accepted values: general, anime, people
        --purity, -p            Accepted values: sfw, sketchy, nsfw
        --resolution, -r        Resolution for the search. Ex. --resolution 1920x1080
        --tag, -t               Tag for the search. Ex. --tag landscapes


        CONFIG:
        Usage: xfwall [option] [value]
        --interval, -i          Set time in seconds until next wallpaper. Ex. --interval 300        
        
        
    "
}

# Set options from CLI
case "$1" in
    -h|--help)
        display_help
        ;;
    start)
        start
        ;;
    change)
        do_wallpaper_replacement
        ;;
    add|del)
        case "$2" in
            --api-key|-a)
                function
                ;;
            --categories|-c)
                function
                ;;
            --purity|-p)
                function
                ;;
            --resolution|-r)
                function
                ;;
            --tag|-t)
                function
                ;;
        esac
        ;;
    --interval|-i)
        function
        ;;
    "")
        display_help
        ;;
    *)
        echo "Error: Unrecognized option '$1'"
        exit 1
        ;;
esac
