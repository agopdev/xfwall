#!/bin/bash

export CONFIG_FILE_PATH=~/.xfwall/config.json

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
    local sorting=$(get_sorting)

    local output_json="/tmp/output.json"
    
    curl -s "https://wallhaven.cc/api/v1/search?q=$tag&categories=$categories&purity=$purity&resolutions=$resolutions&sorting=$sorting&apikey=$apikey" > "$output_json"

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
    jq "$1" $CONFIG_FILE_PATH > /tmp/config.json && mv /tmp/config.json $CONFIG_FILE_PATH
}

# Interval
set_interval(){
    edit_json_file '.config.interval = '$1''
}

get_interval(){
    jq -r '.config.interval' $CONFIG_FILE_PATH
}

# Sorting
get_sorting(){
    jq -r '.wallhaven.sorting' $CONFIG_FILE_PATH
}

# API Key
set_apikey(){
    edit_json_file '.wallhaven.apikey = '$1''
}

get_apikey(){
    jq -r '.wallhaven.apikey' $CONFIG_FILE_PATH
}

# Resolutions
get_resolutions(){
    jq -r '.wallhaven.resolutions | join(",")' $CONFIG_FILE_PATH
}

# Tag
get_tags(){
    jq -r '.wallhaven.tags | join(",")' $CONFIG_FILE_PATH
}

get_random_tag(){
    jq -r '.wallhaven.tags | join(",")' $CONFIG_FILE_PATH | tr ',' '\n' | shuf -n 1
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
    
    local general=$(jq -r '.wallhaven.categories.general' $CONFIG_FILE_PATH)
    local anime=$(jq -r '.wallhaven.categories.anime' $CONFIG_FILE_PATH)
    local people=$(jq -r '.wallhaven.categories.people' $CONFIG_FILE_PATH)
    local categories=""
    
    categories="${categories}$(get_boolean_value "$general")"
    categories="${categories}$(get_boolean_value "$anime")"
    categories="${categories}$(get_boolean_value "$people")"

    echo "$categories"
}

# Purity
get_purity(){
    
    local sfw=$(jq -r '.wallhaven.purity.sfw' $CONFIG_FILE_PATH)
    local sketchy=$(jq -r '.wallhaven.purity.sketchy' $CONFIG_FILE_PATH)
    local nsfw=$(jq -r '.wallhaven.purity.nsfw' $CONFIG_FILE_PATH)
    local purity=""

    purity="${purity}$(get_boolean_value "$sfw")"
    purity="${purity}$(get_boolean_value "$sketchy")"
    purity="${purity}$(get_boolean_value "$nsfw")"

    echo "$purity"
}

# Add / Del options
handle_add_del(){

    add_del="-"
    
    if [ "$1" == "add" ]; then
        add_del="+"
    fi

    case "$2" in
        --resolution|-r)
            regex='^[0-9]+x[0-9]+$'
            if ! [[ $3 =~ $regex ]]; then
                echo "Error: Invalid format for resolution. Allowed format: (number)x(number)"
                exit 1
            fi
            edit_json_file ".wallhaven.resolutions $add_del= [\"$3\"]"
            ;;
        --tag|-t)
            edit_json_file ".wallhaven.tags $add_del= [\"$3\"]"
            ;;
        *)
            echo "Error: Unrecognized option '$2'"
            exit 1
            ;;
    esac

}

# Auxiliary array search
search_in_array() {
    local seeking=$1; shift
    for element; do
        if [[ $element == "$seeking" ]]; then
            return 0
            break
        fi
    done
    return 1
}

# Enable / Disable options
handle_enable_disable(){

    enable_disable=false
    
    if [ "$1" == "enable" ]; then
        enable_disable=true
    fi

    valid_categories=("general" "anime" "people")
    valid_purity=("sfw" "sketchy" "nsfw")

    case "$2" in
        --categories|-c)
            if ! search_in_array "$3" "${valid_categories[@]}"; then
                echo "Error: Unknown category '$3'"
                exit 1
            fi
            edit_json_file ".wallhaven.categories.$3 = $enable_disable"
            ;;
        --purity|-p)
            if ! search_in_array "$3" "${valid_purity[@]}"; then
                echo "Error: Unknown purity '$3'"
                exit 1
            fi
            edit_json_file ".wallhaven.purity.$3 = $enable_disable"
            ;;
        *)
            echo "Error: Unrecognized option '$2'"
            exit 1
            ;;
    esac

}

# Print configuration
print_xfwall_configuration(){
    echo "    
    ACTUAL CONFIG:

        Tags:                                   $(get_tags)
        Resolutions:                            $(get_resolutions)
        Categories (general/anime/people):      $(get_categories)
        Purity (sfw/sketchy/nsfw):              $(get_purity)
        Interval:                               $(get_interval)
        Api Key:                                $(get_apikey)
    
    "
}


# LIST CLI ACTIONS

# Set options from CLI
case "$1" in
    --help|-h|help)
        display_help
        ;;
    --config|-c)
        print_xfwall_configuration
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
            *)
                echo "Error: Unrecognized option '$2'"
                exit 1
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
            *)
                echo "Error: Unrecognized option '$2'"
                exit 1
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