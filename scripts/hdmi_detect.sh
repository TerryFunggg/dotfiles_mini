#!/bin/bash

LOG_FILE="/tmp/hdmi_handler.log"

# Function to log messages
log_message() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Check if xrandr is available
if ! command -v xrandr &> /dev/null; then
    log_message "xrandr command not found"
    exit 1
fi

# Get the list of connected monitors
monitors=$(xrandr --listmonitors | head -1 | cut -d ' ' -f 2)
if [ -z "$monitors" ]; then
    log_message "Failed to get monitor information"
    exit 1
fi

# Initialize variables
iseDP=0
isHDMI=0

# Detect connected monitors
connected_devices=$(xrandr | grep " connected" | awk '{print $1}')
for device in $connected_devices; do
    if [[ "$device" == *"eDP"* ]]; then
        iseDP=1
    elif [[ "$device" == *"HDMI"* ]]; then
        isHDMI=1
        hdmi_device="$device"
    fi
done

# Handle different monitor configurations
if [ "$monitors" -eq 2 ] && [ "$iseDP" -eq 1 ] && [ "$isHDMI" -eq 1 ]; then
    xrandr --output "$hdmi_device" --mode 3840x2160 --above eDP
    log_message "HDMI plug-in: $hdmi_device detected"
    notify-send "HDMI Input" "$hdmi_device is detected"

elif [ "$monitors" -eq 1 ] && [ "$iseDP" -eq 1 ]; then
    xrandr --output eDP --auto
    if [ "$isHDMI" -eq 1 ]; then
        xrandr --output "$hdmi_device" --off
    fi
    log_message "HDMI removed"

else
    xrandr --output eDP --auto
    if [ "$isHDMI" -eq 1 ]; then
        xrandr --output "$hdmi_device" --off
    fi
    log_message "Default monitor configuration applied"
fi
