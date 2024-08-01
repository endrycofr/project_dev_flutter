# Gunakan image dasar Debian Bullseye untuk ARM64
FROM debian:bullseye

# Set non-interaktif untuk menghindari prompt selama instalasi
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install additional dependencies for gstreamer (if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Clone flutter-engine-binaries-for-arm repository and install
RUN git clone --depth 1 https://github.com/ardera/flutter-engine-binaries-for-arm.git engine-binaries
WORKDIR /engine-binaries
RUN sudo ./install.sh

# Clone flutter-pi repository and compile
RUN git clone --recursive https://github.com/ardera/flutter-pi /usr/local/flutter-pi
WORKDIR /usr/local/flutter-pi
RUN mkdir build && cd build && cmake .. && make -j$(nproc) && sudo make install

# Install Flutter SDK
WORKDIR /home/pi/Documents
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.5-stable.tar.xz
RUN tar xf flutter_linux_2.10.5-stable.tar.xz

# Update PATH
RUN echo 'export PATH="$PATH:/home/pi/Documents/flutter/bin"' >> ~/.bashrc
RUN echo 'export PATH=$PATH:/opt/flutter-elinux/bin' >> ~/.bashrc
RUN echo 'export PATH=$PATH:/home/pi/snap/flutter/common/flutter' >> ~/.bashrc
RUN echo 'export PATH=$PATH:/home/pi/Documents/build/flutter_assets' >> ~/.bashrc
RUN echo 'export PATH=$PATH:/home/pi/Documents/flutters/bin' >> ~/.bashrc
RUN source ~/.bashrc

# Copy project files and build Flutter app
COPY flutter_gallery /home/pi/Documents/flutter_gallery
WORKDIR /home/pi/Documents/flutter_gallery
RUN flutter pub get
RUN flutter build bundle

# Sync build assets
RUN rsync -a ./build/flutter_assets /home/pi/Documents/flutter_gallery/build/flutter_assets

# Install xdg-user-dirs if needed
RUN apt-get update && apt-get install -y --no-install-recommends xdg-user-dirs && apt-get clean && rm -rf /var/lib/apt/lists/*

# Run the Flutter app in profile mode
CMD ["flutter", "run", "--profile"]
