#!/bin/bash

export CONFIG_FILE_PATH=~/.xfwall/config.json
export XFWALL_VERSION="0.2.0"
export OUTPUT_JSON="/tmp/output.json"

# Monitor name
get_all_monitors() {
    xrandr | grep " connected" | awk '{print $1}'
}

# FUNCTIONALITY

# Check that required dependencies are installed
check_dependencies() {
    local dependencies=("jq" "curl" "xrandr")

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: '$dep' is not installed. Please install before executing xfwall."
            exit 1
        fi
    done
}

check_dependencies

# URL Encoder for special characters
url_encode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos = 0 ; pos < strlen ; pos++ )); do
    c=${string:$pos:1}
    case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * ) printf -v o '%%%02x' "'$c" ;;
    esac
    encoded+="${o}"
    done

    echo "${encoded}"
}

# Get wallpaper URL and select one randomly
get_random_wallpaper_url() {
    local tag="$1"
    local categories=$(get_categories)
    local purity=$(get_purity)
    local apikey=$(get_apikey)
    local resolutions=$(get_resolutions)
    local sorting=$(get_sorting)

    local tag_encoded=$(url_encode "$tag")
    
    curl -s "https://wallhaven.cc/api/v1/search?q=$tag_encoded&categories=$categories&purity=$purity&resolutions=$resolutions&sorting=$sorting&apikey=$apikey" > "$OUTPUT_JSON"

    local random_index
    total_elements=$(jq '.data | length' "$OUTPUT_JSON")
    random_index=$(shuf -i 0-$((total_elements - 1)) -n 1)

    local wallpaper_url
    wallpaper_url=$(jq -r ".data[$((random_index))].path" "$OUTPUT_JSON")

    rm "$OUTPUT_JSON"

    echo "$wallpaper_url"
}

# Get exact wallpaper from id
get_wallpaper_url_from_id() {
    local id="$1"
    local apikey=$(get_apikey)

    local id_encoded=$(url_encode "$id")

    curl -s "https://wallhaven.cc/api/v1/w/$id_encoded?apikey=$apikey" > "$OUTPUT_JSON"

    local wallpaper_url
    wallpaper_url=$(jq -r ".data.path" "$OUTPUT_JSON")

    echo "$wallpaper_url"

}

# Download and set wallpaper
update_wallpaper() {
    local wallpaper_url="$1"
    local image_path=~/.xfwall/history/last_img.jpg
    local monitors=$(get_all_monitors)

    for monitor in $monitors; do
        curl -o "$image_path" "$wallpaper_url"

        if [ $? -eq 0 ]; then
            xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor$monitor/workspace0/last-image --set "$image_path"
            echo "Wallpaper updated for monitor: $monitor"
        else
            echo "Error: The wallpaper could not be downloaded"
        fi
    done
}

# Change wallpaper
do_wallpaper_replacement () {
    wallpaper_url=$(get_random_wallpaper_url "$1")
    echo "Actual wallpaper: $wallpaper_url"
    update_wallpaper "$wallpaper_url"
}

# Change actual wallpaper to exact wallpaper id
do_wallpaper_replacement_from_id () {
    wallpaper_url=$(get_wallpaper_url_from_id "$1")
    echo "Actual wallpaper: $wallpaper_url"
    update_wallpaper "$wallpaper_url"
}

# Start xfwall
start () {
    
    while true; do
        local interval=$(get_interval)
        local tag=$(get_random_tag)
        do_wallpaper_replacement "$tag"
        sleep "$interval"
    done
}

# Stop xfwall by killing all xfwall start processes
stop () {
    for pid in $(pgrep -f "xfwall start") $(pgrep -f "xfwall.sh start"); do
        kill -9 $pid
    done
}


# Show versin
display_version() {
    echo "xfwall version: $XFWALL_VERSION"
}

# Show help
display_help() {
    echo "

        ___   ___  ___________    __    ____  ___       __       __      
        \  \ /  / |   ____\   \  /  \  /   / /   \     |  |     |  |     
         \  V  /  |  |__   \   \/    \/   / /  ^  \    |  |     |  |     
          >   <   |   __|   \            / /  /_\  \   |  |     |  |     
         /  .  \  |  |       \    /\    / /  _____  \  |  \`----.|  \`----.
        /__/ \__\ |__|        \__/  \__/ /__/     \__\ |_______||_______|
                                                                 

                                                                 


        Version: "$XFWALL_VERSION"

        By Alonso González-Leal @agopdev

        Usage: xfwall [command|option] [value]


        Commands:
        start                   Start xfwall with the actual configuration.
        stop                    Kills all xfwall start processes.
        change                  Change current wallpaper to a random tag already added, doesn't restart timer
        add                     Add a search parameter
        del                     Remove a search parameter
        enable                  Enable a search option
        disable                 Disable a search option


        Global options:
        -h, --help              Prints this screen
        -sc, --show-config      Prints the actual configuration
        -sm, --show-monitors    Prints the available monitors
        -v, --version           Prints the version of xfwall


        Change options:
        \"\"                    Change actual wallpaper from the previously added tags. Ex. xfwall change
        -q, --query             Change actual wallpaper from a specific query. Ex. xfwall change --query \"rain city\"
        -i, --id                Change actual wallpaper from id. Ex. xfwall change --id \"94x38z\"

        Search options:
        -c, --categories        Accepted values: general, anime, people. Ex. xfwall enable -c \"anime\"
        -p, --purity            Accepted values: sfw, sketchy, nsfw. Ex. xfwall disable -p \"nsfw\"

        Search parameters:
        -r, --resolution        Resolution for the search. Ex. xfwall add --resolution \"1920x1080\"
        -t, --tag               Tag for the search. Ex. xfwall add --tag \"city lights\"


        Config options:
        --interval          Set time in seconds until next wallpaper. Ex. xfwall --interval \"300\"
        --api-key           Set api key for the nsfw purity option. Ex. xfwall --api-key \"API_KEY\"
        
        
    "
}


# CONFIGURATIONS

# Edit JSON
edit_json_file(){
    jq "$1" $CONFIG_FILE_PATH > /tmp/config.json && mv /tmp/config.json $CONFIG_FILE_PATH
}

# Interval
set_interval(){
    edit_json_file ".config.interval = "$1""
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
    edit_json_file '.wallhaven.apikey = "'"$1"'"'
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
    --version|-v)
        display_version
        ;;
    --help|-h)
        display_help
        ;;
    --show-config|-sc)
        print_xfwall_configuration
        ;;
    --show-monitors|-sm)
        get_all_monitors
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    change)
        case "$2" in
            "")
                tag=$(get_random_tag)
                do_wallpaper_replacement "$tag"
                ;;
            --query|-q)
                do_wallpaper_replacement "$3"
                ;;
            --id|-i)
                do_wallpaper_replacement_from_id "$3"
                ;;
            *)
                echo "Error: Unrecognized option '$2'"
                exit 1
                ;;
        esac
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
    --api-key)
        set_apikey "$2"
        ;;
    --interval)
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