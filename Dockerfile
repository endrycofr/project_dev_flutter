# Gunakan image dasar Debian Bullseye untuk ARM64
FROM debian:bullseye

# Set non-interaktif untuk menghindari prompt selama instalasi
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    git \
    wget \
    curl \
    unzip \
    xz-utils \
    libglu1-mesa \
    mesa-utils \
    libegl1-mesa-dev \
    libgbm-dev \
    libgles2-mesa-dev \
    libdrm-dev \
    udev \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-linux-desktop

# Install Flutter Pi
RUN git clone https://github.com/ardera/flutter-pi.git /usr/local/flutter-pi
RUN cd /usr/local/flutter-pi && make

# Copy project files
WORKDIR /app
COPY pubspec.yaml /app/pubspec.yaml
COPY pubspec.lock /app/pubspec.lock
RUN flutter pub get
COPY . /app

# Build the Flutter app for Linux
RUN flutter build linux --release

# Run the app using Flutter Pi
CMD ["flutter-pi", "/app/build/linux/release/bundle"]
