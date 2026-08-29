#!/usr/bin/env bash

function wrapper() {
    read header
    echo "$header"
    
    read opening
    echo "$opening"
    
    prefix=""
    
    while true; do
        read line || break
        line="${line#,}"
    
        theme_output=$(cat /tmp/wal-theme 2> /dev/null | tail -1 | awk '{print $3}')
    
        modified=$(echo "$line" | jq --unbuffered --arg t "$theme_output" \
            '[{"name": "custom_theme", "instance": "0", "full_text": $t, "markup": "none", "min_width":60, "align": "center"}] + .')
    
        echo "$prefix$modified"
        prefix=","
    done
}

i3status -c ~/.config/i3/i3status.conf | wrapper
