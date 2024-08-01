# Use Debian Bullseye base image for ARM64
FROM debian:bullseye

# Set non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package sources
RUN apt-get update

# Install base dependencies
RUN apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    unzip \
    xz-utils \
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
    sudo

# Clean up package cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install additional dependencies for GStreamer (if needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    gstreamer1.0-alsa && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone and install Flutter engine binaries for ARM
RUN git clone --depth 1 https://github.com/ardera/flutter-engine-binaries-for-arm.git /engine-binaries && \
    cd /engine-binaries && \
    sudo ./install.sh

# Clone and build Flutter-pi
RUN git clone --recursive https://github.com/ardera/flutter-pi /usr/local/flutter-pi && \
    cd /usr/local/flutter-pi && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    sudo make install

# Install Flutter SDK
WORKDIR /home/rootnow
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.5-stable.tar.xz && \
    tar xf flutter_linux_2.10.5-stable.tar.xz

# Install xdg-user-dirs if needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends xdg-user-dirs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the default command to run the Flutter app in profile mode
CMD ["flutter", "run", "--profile"]
