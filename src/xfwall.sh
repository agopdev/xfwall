#!/bin/bash

# FUNCTIONALITY

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
    local tag=$(get_random_tag)
    local categories=$(get_categories)
    local purity=$(get_purity)
    local apikey=$(get_apikey)
    local resolutions=$(get_resolutions)
    local ratios=""
    local sorting=$(get_sorting)

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
    wallpaper_url=$(get_wallpaper_url)
    update_wallpaper "$wallpaper_url"
}

# Start xfwall
start () {
    
    while true; do
        local interval=$(get_interval)
        do_wallpaper_replacement
        sleep "$interval"
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
    |     /  .  \  |  |       \    /\    / /  _____  \  |   ----.|   ----.   | |
    |    /__/ \__\ |__|        \__/  \__/ /__/     \__\ |_______||_______|   | |
    |________________________________________________________________________| |
     \________________________________________________________________________\'


        Usage: See each category

        COMMON:
        Usage: xfwall [option]
        --help, -h              Prints this screen


        WALLPAPERS:
        Usage: xfwall [option]
        start                   Start xfwall with the actual configuration
        change                  Change actual wallpaper, doesn't restart timer


        SEARCH PARAMS:
        Usage: xfwall [add/del] [option] [value]
        --categories, -c        Accepted values: general, anime, people
        --purity, -p            Accepted values: sfw, sketchy, nsfw
        --resolution, -r        Resolution for the search. Ex. --resolution 1920x1080
        --tag, -t               Tag for the search. Ex. --tag landscapes


        CONFIG:
        Usage: xfwall [option] [value]
        --interval, -i          Set time in seconds until next wallpaper. Ex. --interval 300
        --api-key, -a           Set api key for the nsfw purity option
        
        
    "
}


# CONFIGURATIONS

# Edit JSON
edit_json_file(){
    jq "$1" ~/.xfwall/config.json > /tmp/config.json && mv /tmp/config.json ~/.xfwall/config.json
}

# Interval
set_interval(){
    edit_json_file '.config.interval = '$1''
}

get_interval(){
    jq -r '.config.interval' ~/.xfwall/config.json
}

# Sorting
get_sorting(){
    jq -r '.config.sorting' ~/.xfwall/config.json
}

# API Key
set_apikey(){
    edit_json_file '.config.apikey = '$1''
}

get_apikey(){
    jq -r '.config.apikey' ~/.xfwall/config.json
}

# Resolutions
get_resolutions(){
    jq -r '.config.resolutions | join(",")' ~/.xfwall/config.json
}

# Tag
get_random_tag(){
    jq -r '.config.tags | join(",")' ~/.xfwall/config.json | tr ',' '\n' | shuf -n 1
}

# Auxiliar boolean value
get_boolean_value() {
    if [ "$1" == true ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Categories
get_categories(){
    
    local general=$(jq -r '.config.categories.general' ~/.xfwall/config.json)
    local anime=$(jq -r '.config.categories.anime' ~/.xfwall/config.json)
    local people=$(jq -r '.config.categories.people' ~/.xfwall/config.json)
    local categories=""
    
    categories="${categories}$(get_boolean_value "$general")"
    categories="${categories}$(get_boolean_value "$anime")"
    categories="${categories}$(get_boolean_value "$people")"

    echo "$categories"
}

# Purity
get_purity(){
    
    local sfw=$(jq -r '.config.purity.sfw' ~/.xfwall/config.json)
    local sketchy=$(jq -r '.config.purity.sketchy' ~/.xfwall/config.json)
    local nsfw=$(jq -r '.config.purity.nsfw' ~/.xfwall/config.json)
    local purity=""

    purity="${purity}$(get_boolean_value "$sfw")"
    purity="${purity}$(get_boolean_value "$sketchy")"
    purity="${purity}$(get_boolean_value "$nsfw")"

    echo "$purity"
}

# Add / Del options
handle_add_del(){
    
    if [ "$1" = "add" ]; then
        add_del="+"
    elif [ "$1" = "del" ]; then
        add_del="-"
    fi

    case "$2" in
        --resolution|-r)
            edit_json_file ".config.resolutions $add_del= [\"$3\"]"
            ;;
        --tag|-t)
            edit_json_file ".config.tags $add_del= [\"$3\"]"
            ;;
    esac

}

# Enable / Disable options
handle_enable_disable(){
    
    if [ "$1" = "enable" ]; then
        enable_disable=true
    elif [ "$1" = "disable" ]; then
        enable_disable=false
    fi

    case "$2" in
        --categories|-c)
            edit_json_file "if .config.categories.$3? then .config.categories.$3 = $enable_disable else . end"
            ;;
        --purity|-p)
            edit_json_file "if .config.purity.$3? then .config.purity.$3 = $enable_disable else . end"
            ;;
    esac

}


# LIST CLI ACTIONS

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
            --resolution|-r)
                handle_add_del "$1" "$2" "$3"
                ;;
            --tag|-t)
                handle_add_del "$1" "$2" "$3"
                ;;
        esac
        ;;
    enable|disable)
        case "$2" in
            --categories|-c)
                handle_enable_disable "$1" "$2" "$3"
                ;;
            --purity|-p)
                handle_enable_disable "$1" "$2" "$3"
                ;;
        esac
        ;;
    --api-key|-a)
        set_apikey "$2"
        ;;
    --interval|-i)
        set_interval "$2"
        ;;
    "")
        display_help
        ;;
    *)
        echo "Error: Unrecognized option '$1'"
        exit 1
        ;;
esac

# Echo Errors
echo_error(){
    echo $error
}