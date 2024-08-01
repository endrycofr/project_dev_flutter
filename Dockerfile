# Use Ubuntu as the base image
FROM ubuntu:latest

# Set non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package sources and install basic utilities
RUN apt -y update && \
    apt -y install \
    git \
    wget \
    build-essential \
    cmake \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libegl1-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    ttf-mscorefonts-installer \
    fontconfig \
    libsystemd-dev \
    libinput-dev \
    libudev-dev \
    libxkbcommon-dev \
    && apt -y clean && \
    rm -rf /var/lib/apt/lists/*

# Set the timezone
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# STEP 1: Install Flutter engine binaries
WORKDIR /TOWER_DISPLAY
RUN git clone --depth 1 https://github.com/ardera/flutter-engine-binaries-for-arm.git engine-binaries && \
    cd engine-binaries && \
    ./install.sh

# STEP 2: Install additional dependencies
RUN fc-cache

# STEP 3: Compile Flutter-pi
RUN git clone https://github.com/ardera/flutter-pi && \
    cd flutter-pi && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j $(nproc) && \
    make install

# Set working directory
WORKDIR /TOWER_DISPLAY

# Expose the necessary port
EXPOSE 8080

# Default command to run when the container starts
CMD ["bash"]
