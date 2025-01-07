# Docker entry point script

#!/bin/bash

set -e


# If running as root, setup permissions and switch to user
if [ "$(id -u)" = "0" ]; then
    # Setup runtime directory for the user
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
    chown "$USERNAME" "$XDG_RUNTIME_DIR"

    # Setup Wayland socket permissions if mounted
    if [ -n "$WAYLAND_DISPLAY" ] && [ -e "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
        chmod 0600 "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
        chown "$USERNAME" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    fi

    # Setup X11 permissions if needed
    if [ -e "/tmp/.X11-unix" ]; then
        chmod 1777 /tmp/.X11-unix
    fi

    # Setup PulseAudio/PipeWire socket permissions
    for socket in /tmp/pulse-* /tmp/pipewire-*; do
        if [ -e "$socket" ]; then
            chown "$USERNAME" "$socket"
        fi
    done

    # Setup GPU access
    if [ -d "/dev/dri" ]; then
        for device in /dev/dri/*; do
            if [ -e "$device" ]; then
                group=$(stat -c '%g' "$device")
                usermod -a -G "$group" "$USERNAME" 2>/dev/null || true
            fi
        done
    fi

    # Switch to the user using gosu
    exec gosu "$USERNAME" "$@"
else
    # Already running as user, just execute the command
    exec "$@"
fi