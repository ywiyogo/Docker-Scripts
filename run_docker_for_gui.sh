#!/bin/bash

# Set ubuntu:24.04 as default docker image if no image name is set
if [ $# -ne 0 ]; then
    IMAGE_NAME=$1
else
    IMAGE_NAME=ubuntu:24.04
fi

# Default working directory, can be overridden by environment variable
WORK_DIR=${WORK_DIR:-"/home/$USER"}

# Detect if running under Wayland or X11
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "Wayland session detected"
    # Set up Wayland-specific environment
    DOCKER_DISPLAY_ARGS="-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
                        -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
                        -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY \
                        -e QT_QPA_PLATFORM=wayland \
                        -e GDK_BACKEND=wayland"
else
    echo "X11 session detected"
    # Check if X11 is available
    if ! xset q &>/dev/null; then
        echo "Warning: X11 display not found"
    fi
    DOCKER_DISPLAY_ARGS="-e DISPLAY=$DISPLAY"
fi

# Ensure required directories exist
if [ ! -d "/home/$USER" ]; then
    echo "Error: Home directory not found"
    exit 1
fi

# Check if nvidia-smi exists and add GPU support if available
if command -v nvidia-smi &> /dev/null; then
    GPU_ARGS="--gpus all"
    echo "NVIDIA GPU support enabled"
else
    GPU_ARGS=""
fi

# Docker run configuration:
#
# Security:
# - no-new-privileges: Prevents privilege escalation
# - init: Adds init process for proper signal handling
#
# Network & System:
# - host network and IPC for X11/Wayland support
# - proxy settings from host environment
#
# User & Environment:
# - runs as host user (UID/GID mapping)
# - preserves common environment variables
# - sets up display for GUI applications
#
# Volumes:
# - mounts home directory
# - mounts SSH keys (read-only)
# - mounts system files (read-only)
# - mounts temporary directories
#
# GPU Support:
# - includes NVIDIA GPU support if available
# - configures NVIDIA environment variables

docker run --rm -it \
    --security-opt=no-new-privileges \
    --init \
    --env HTTP_PROXY="${docker_http_proxy:-}" \
    --env HTTPS_PROXY="${docker_https_proxy:-}" \
    --env NO_PROXY="${docker_no_proxy:-},localhost" \
    --user "$(id -u):$(id -g)" \
    --net="host" \
    --ipc="host" \
    -e USER="$USER" \
    -e HOME="$HOME" \
    -e "TERM=xterm-256color" \
    -h "$HOSTNAME" \
    $DOCKER_DISPLAY_ARGS \
    $GPU_ARGS \
    -v /tmp:/tmp \
    -v "/run/user/$(id -u):/run/user/$(id -u)" \
    -v "/home/$USER:/home/$USER" \
    -v "$HOME/.ssh:/home/$USER/.ssh:ro" \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e USERNAME="$USER" \
    -e SSH_AUTH_SOCK="$SSH_AUTH_SOCK" \
    -e NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all} \
    -e NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-all} \
    -w "$WORK_DIR" \
    "$IMAGE_NAME" \
    /bin/bash
