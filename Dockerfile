# Use Ubuntu as the base image
FROM ubuntu:latest

# Set non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Use a faster mirror (optional, adjust to your region)
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirror.speedpartner.de/ubuntu/|g' /etc/apt/sources.list

# Update package sources and upgrade
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y

# Install basic utilities and dependencies
RUN apt-get install -y \
    git \
    wget \
    curl \
    unzip \
    build-essential \
    cmake \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libegl1-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    fontconfig \
    libsystemd-dev \
    libinput-dev \
    libudev-dev \
    libxkbcommon-dev \
    libglfw3-dev \
    libwayland-dev \
    pkg-config \
    liblz4-tool && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the timezone
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /usr/local/flutter

# Set Flutter environment variables
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Create a non-root user and switch to that user
RUN useradd -ms /bin/bash flutteruser

# Change ownership of the Flutter directory
RUN chown -R flutteruser:flutteruser /usr/local/flutter

# Switch to the non-root user
USER flutteruser
WORKDIR /home/flutteruser

# Run flutter doctor to verify the setup
RUN flutter doctor -v

# Pre-download Flutter dependencies
RUN flutter precache 

# Clone flutter-pi repository
RUN git clone https://github.com/ardera/flutter-pi.git /home/flutteruser/flutter-pi

# Build flutter-pi
WORKDIR /home/flutteruser/flutter-pi
RUN mkdir build && cd build && cmake .. && make -j$(nproc)

# Create a directory for the project
WORKDIR /home/flutteruser/TOWER_DISPLAY

# Copy pubspec.yaml and install dependencies
COPY pubspec.yaml /home/flutteruser/TOWER_DISPLAY/
RUN flutter pub get

# Copy the rest of the application code
COPY . /home/flutteruser/TOWER_DISPLAY/

# Change ownership of the copied files
USER root
RUN chown -R flutteruser:flutteruser /home/flutteruser/TOWER_DISPLAY

# Switch back to non-root user
USER flutteruser

# Build the Flutter project for Linux
RUN flutter build linux

# Expose the necessary port (if your Flutter app serves on a port)
EXPOSE 8080

# Default command to run when the container starts
CMD ["bash"]
