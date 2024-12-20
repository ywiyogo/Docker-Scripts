FROM ubuntu:24.04

# Accept build arguments for user creation
ARG USERNAME
ARG USER_UID
ARG USER_GID

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Create the user first so all subsequent operations can be owned by this user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Basic system utilities and common dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    # Version control
    git \
    # Basic utilities
    curl \
    wget \
    vim \
    nano \
    htop \
    tree \
    tmux \
    zip \
    unzip \
    # Terminal utilities
    ncurses-term \
    bash-completion \
    # AppImage support
    fuse \
    libfuse2 \
    libfuse-dev \
    && rm -rf /var/lib/apt/lists/*

# Development tools and SDKs
RUN apt-get update && apt-get install -y \
    # C/C++ development
    gcc \
    g++ \
    gdb \
    clang \
    clangd \
    lldb \
    valgrind \
    clang-format \
    # Python development
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    ipython3 \
    # Go development
    golang \
    # GUI and graphics development
    libgtk-3-dev \
    libsdl2-dev \
    libglfw3-dev \
    libglew-dev \
    # Video and image processing
    ffmpeg \
    v4l-utils \
    # OpenCV dependencies
    libopencv-dev \
    python3-opencv \
    # Cryptography dependencies
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install common Python packages
RUN pip3 install --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    scipy \
    scikit-learn \
    jupyter \
    opencv-python \
    cryptography \
    requests \
    flask \
    django \
    pytorch \
    tensorflow

# GUI and Desktop application support
RUN apt-get update && apt-get install -y \
    # X11 support
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxinerama-dev \
    libxi-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxtst6 \
    # Additional GUI libraries
    libqt5widgets5 \
    libqt5gui5 \
    libqt5dbus5 \
    libqt5network5 \
    libqt5core5a \
    # Audio support
    pulseaudio \
    alsa-utils \
    # Video codecs
    libavcodec-extra \
    # Additional AppImage dependencies
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Web development tools
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install common web development tools
RUN npm install -g \
    yarn \
    typescript \
    @angular/cli \
    create-react-app \
    vue-cli

# Video editing tools
RUN apt-get update && apt-get install -y \
    kdenlive \
    obs-studio \
    && rm -rf /var/lib/apt/lists/*

# ImGui setup
RUN git clone https://github.com/ocornut/imgui.git /usr/local/imgui

# Setup common build tools
RUN apt-get update && apt-get install -y \
    make \
    autoconf \
    automake \
    libtool \
    meson \
    && rm -rf /var/lib/apt/lists/*

# Configure FUSE for AppImage
RUN setcap cap_sys_admin+ep /usr/sbin/fusermount

# Setup locale
RUN apt-get update && apt-get install -y \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# Setup terminal colors
RUN echo 'eval "$(dircolors -b)"' >> /etc/bash.bashrc && \
    echo 'alias ls="ls --color=auto"' >> /etc/bash.bashrc && \
    echo 'alias ll="ls -la --color=auto"' >> /etc/bash.bashrc


# Set ownership for relevant directories
RUN chown -R $USERNAME:$USERNAME /workspace

# Switch to the new user
USER $USERNAME

# Set working directory
WORKDIR /home/$USERNAME