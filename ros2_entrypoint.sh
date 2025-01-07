#!/bin/bash
set -e

# Debug printing
echo "ROS_DISTRO: '$ROS_DISTRO'"

# Fallback mechanism with explicit checks
if [ -z "$ROS_DISTRO" ]; then
    echo "ROS_DISTRO is empty! Setting to jazzy."
    ROS_DISTRO="jazzy"
fi

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
exec "$@"