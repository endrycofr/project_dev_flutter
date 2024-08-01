# Use a base image for ARM64
FROM arm64v8/debian:bullseye

# Set non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package sources
RUN apt-get update

# Install base dependencies with error checking
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

# Install Flutter SDK
WORKDIR /home/pi
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.4.4-stable.tar.xz && \
    tar xf flutter_linux_3.4.4-stable.tar.xz && \
    rm flutter_linux_3.4.4-stable.tar.xz

# Set up Flutter environment
ENV PATH="/home/pi/flutter/bin:${PATH}"

# Copy your Flutter project into the container
COPY . /home/pi/project

# Set the working directory to your project
WORKDIR /home/pi/project

# Install Dart dependencies
RUN flutter pub get

# Build the Flutter project
RUN flutter build linux --release

# Expose the port your app will run on
EXPOSE 8080

# Run the Flutter application
CMD ["flutter", "run", "--release"]
