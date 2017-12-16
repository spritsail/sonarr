#!/bin/sh
set -e

CFG_FILE="$CFG_DIR/config.xml"
CFG_FILE_BAK="$(mktemp -u "$CFG_FILE.bak.XXXXXX")"

if [ -f "$CFG_FILE" ]; then
    # Preserve old configuration, in case of ENOSPC or other errors
    cp "$CFG_FILE" "$CFG_FILE_BAK" || (echo "Error: Could not backup config file" >&2; exit 99)
fi

getOpt() {
    xmlstarlet sel -t -c /Config/"$1" "$CFG_FILE"
}
setOpt() {
    # If element exists
    if xmlstarlet sel -Q -t -c "/Config/$1" "$CFG_FILE"; then
        # Update the existing element
        xmlstarlet ed -O -L -u "/Config/$1" -v "$2" "$CFG_FILE"
    else
        # Insert a new sub-element
        xmlstarlet ed -O -L -s /Config -t elem -n "$1" -v "$2" "$CFG_FILE"
    fi
}
bool() {
    local var="$(echo "$1" | tr 'A-Z' 'a-z')"
    case "$var" in
        y|ye|yes|t|tr|tru|true|1)
            echo True;;
        n|no|f|fa|fal|fals|false|0)
            echo False;;
    esac
}
upper() {
    echo $1 | awk '{print toupper($0)}'
}
camel() {
    echo $1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}'
}

# Create empty config.xml file (or fill existing empty file)
if [ ! -f "$CFG_FILE" ] || [ ! -s "$CFG_FILE" ]; then
    (echo '<Config>'; echo '</Config>') > "$CFG_FILE"
fi

# Add options that are specified in the environment 
# and set some sane defaults.
[ -n "$API_KEY" ]   && setOpt ApiKey $(upper "$API_KEY")
setOpt AnalyticsEnabled $(bool "${ANALYTICS:-false}")
setOpt Branch "${BRANCH:-master}"
setOpt BindAddress '*'
setOpt EnableSsl $(bool "${ENABLE_SSL:-false}")
setOpt LaunchBrowser False
setOpt LogLevel $(camel "${LOG_LEVEL:-info}")
setOpt UpdateAutomatically $(bool "${AUTOUPDATE:-false}")
setOpt UrlBase "$URL_BASE"

# NOTE: If these defaults need to be set differently,
# please open an issue or pull request on the repo: 
#   https://github.com/Adam-Ant/docker-sonarr

# Format the document pretty :)
xmlstarlet fo "$CFG_FILE" >/dev/null

# Finally, remove backup file after successfully creating new one
# This is done to prevent trampling the config when the disk is full
rm -f "$CFG_FILE_BAK"
