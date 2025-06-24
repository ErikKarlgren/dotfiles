#!/bin/bash

# Path to store the notification ID
NOTIFICATION_ID_FILE="/tmp/power-monitor-notification-id"

# Find the active user and their display
get_active_user() {
    loginctl list-sessions --no-legend | while read -r session _ user _ _ _ _ _ _; do
        if loginctl show-session "$session" -p Active | grep -q "yes"; then
            echo "$user"
            return
        fi
    done
}

USER=$(get_active_user)
USER_ID=$(id -u "$USER")

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

AC_ONLINE=$(cat /sys/class/power_supply/AC*/online 2>/dev/null || cat /sys/class/power_supply/ADP*/online 2>/dev/null)

send_notification() {
    local urgency="$1"
    local icon="$2"
    local summary="$3"
    local body="$4"
    local expire_time="$5"
    
    # Check if we have a previous notification ID
    if [ -f "$NOTIFICATION_ID_FILE" ]; then
        REPLACE_ID=$(cat "$NOTIFICATION_ID_FILE")
        NOTIFICATION_ID=$(sudo -u "$USER" DISPLAY=$DISPLAY DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
            notify-send --urgency "$urgency" --icon "$icon" --app-name "Power Monitor" \
            --expire-time "$expire_time" --print-id --replace-id="$REPLACE_ID" \
            "$summary" "$body")
    else
        NOTIFICATION_ID=$(sudo -u "$USER" DISPLAY=$DISPLAY DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
            notify-send --urgency "$urgency" --icon "$icon" --app-name "Power Monitor" \
            --expire-time "$expire_time" --print-id \
            "$summary" "$body")
    fi
    
    # Store the notification ID for future replacements
    echo "$NOTIFICATION_ID" | tee "$NOTIFICATION_ID_FILE"
}

if [ "$AC_ONLINE" = "0" ]; then
    # Send critical notification (stays longer)
    send_notification "critical" "battery-caution" "Power Disconnected" "Running on battery power" "0"
    echo "Power Disconnected: Running on battery power" >&2
else
    send_notification "normal" "battery-full-charging" "Power Connected" "Running on AC power" "1000"
    echo "Power Connected"
    rm -f "$NOTIFICATION_ID_FILE"
fi
