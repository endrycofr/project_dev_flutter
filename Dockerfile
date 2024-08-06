# Use Ubuntu as the base image
FROM ubuntu:latest

# Set non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package sources and install dependencies
RUN apt -y update && 
RUN apt-get install -y  software-properties-common && \
    add-apt-repository multiverse && \
    apt -y update && \
    apt -y install -y \
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
    ttf-mscorefonts-installer && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/*

# Set the timezone
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /usr/local/flutter

# Set Flutter environment variables
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter dependencies
RUN flutter precache

# Accept Android licenses (if needed)
RUN yes | flutter doctor --android-licenses || true

# Run flutter doctor
RUN flutter doctor

# Create a directory for the project
WORKDIR /TOWER_DISPLAY

# Copy pubspec.yaml and install dependencies
COPY pubspec.yaml /TOWER_DISPLAY/
RUN flutter pub get

# Copy the rest of the application code
COPY . /TOWER_DISPLAY/

# Build the Flutter project
RUN flutter build linux

# Expose the necessary port (if your Flutter app serves on a port)
EXPOSE 8080

# Default command to run when the container starts
CMD ["bash"]
