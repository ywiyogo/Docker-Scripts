# Use your base development environment
FROM wiyogo/ubuntu2404_on_arch:latest

# Set ROS2 version
ARG ROS_DISTRO=jazzy

# Switch to root user for installation
USER root

# Add ROS2 apt repository
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2 packages and Gazebo simulator
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-ros-base \
    ros-dev-tools \
    ros-${ROS_DISTRO}-ros-gz \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Switch back to the default user if needed
USER $USERNAME

# Source ROS2 in bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/$USERNAME/.bashrc 

# Set up ROS2 workspace
RUN mkdir -p ~/ros2_ws/src

WORKDIR /home/$USERNAME/ros2_ws

# Default command
CMD ["/bin/bash"]
