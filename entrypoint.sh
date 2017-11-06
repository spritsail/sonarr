#!/bin/sh
set -e

export CFG_DIR="${CFG_DIG:-/config}"

if ! su-exec "$UID:$GID" touch "$CFG_DIR/.write-test"; then
    2>&1 echo "Warning: No permission to write in '$CFG_DIR' directory."
    2>&1 echo "         It is likely that Sonarr will have permission issues"
    2>&1 echo
    chown $UID:$GID "$CFG_DIR"
    chmod o+rw "$CFG_DIR"
fi
# Remove temporary file
rm -f touch "$CFG_DIR/.write-test"

su-exec "$UID:$GID" gen-config.sh

exec su-exec "$UID:$GID" "$@"
