FROM ubuntu:26.04

ARG CMAKE_VERSION="4.3.2"
ARG VULKAN_VERSION="1.4.351"
ARG GLSLC_VERSION="2026.2"
ARG EXTRA_CMAKE_MODULES_VERSION="6.26.0"
ARG KDE_VERSION="6.26.0"
ARG MESON_VERSION="0.64.0"
ARG WAYLAND_PROTOCOLS_VERSION="1.48"
ARG PLASMA_WAYLAND_PROTOCOLS_VERSION="1.15.0"
ARG QQC2_BREEZE_STYLE_VERSION="6.6.4"
ARG PLASMA_INTEGRATION_VERSION="6.6.4"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    perl \
    python3 \
    git \
    ninja-build \
    cmake \
    ccache \
    libssl-dev \
    checkinstall \
    libwayland-dev \
    libxrandr-dev \
    patchelf \
    wget \
    fuse3 \
    pkg-config \
    rsync \
    libharfbuzz-dev \
    libfribidi-dev \
    libfontconfig-dev \
    libgl1-mesa-dev \
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-glx0-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-sync-dev \
    libxcb-xfixes0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-util-dev \
    libxcb-xinerama0-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxcb-xinput-dev \
    libegl1-mesa-dev \
    libxkbfile-dev \
    libxtst-dev \
    libxshmfence-dev \
    libxcursor-dev \
    libxcomposite-dev \
    libdrm-dev \
    libxcb-dri3-dev \
    libxcb-cursor-dev \
    libxcb-res0-dev \
    libdbus-1-dev \
    libdbus-c++-dev \
    libzstd-dev \
    liblzma-dev \
    libbz2-dev \
    gettext \
    python3-pip \
    flex \
    bison \
    libudev-dev \
    libcanberra-dev \
    qt6-declarative-dev \
    qt6-svg-dev \
    qt6-shadertools-dev \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /cmake-build && \
    cd /cmake-build && \
    git clone --depth 1 --branch v${CMAKE_VERSION} https://github.com/Kitware/CMake.git && \
    cd CMake && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . --parallel && \
    checkinstall --install=no --fstrans=no --nodoc --pkgname=cmake --pkgversion=${CMAKE_VERSION} -y && \
    apt -y remove cmake cmake-data && \
    dpkg -i cmake_${CMAKE_VERSION}*.deb && \
    rm -rf /cmake-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /glslc-build && \
    cd /glslc-build && \
    git clone --depth 1 --branch v${GLSLC_VERSION} https://github.com/google/shaderc.git && \
    cd shaderc && \
    python3 utils/git-sync-deps && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DSHADERC_SKIP_TESTS=ON -DSPIRV_SKIP_TESTS=ON -DSHADERC_SKIP_EXAMPLES=ON && \
    cmake --build . --parallel && \
    checkinstall --install=no --fstrans=no --nodoc --pkgname=glslc --pkgversion=${GLSLC_VERSION} -y && \
    dpkg -i glslc_${GLSLC_VERSION}*.deb && \
    rm -rf /glslc-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /Vulkan-Loader-build && \
    cd /Vulkan-Loader-build && \
    git clone --depth 1 --branch v${VULKAN_VERSION} https://github.com/KhronosGroup/Vulkan-Loader.git && \
    cd Vulkan-Loader && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DUPDATE_DEPS=On && \
    cmake --build . --parallel && \
    checkinstall --install=no --fstrans=no --nodoc --pkgname=libvulkan1 --pkgversion=${VULKAN_VERSION} -y && \
    apt -y remove libvulkan-dev && \
    dpkg -i libvulkan1_${VULKAN_VERSION}*.deb && \
    rm -rf /Vulkan-Loader-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /Vulkan-Utility-Libraries-build && \
    cd /Vulkan-Utility-Libraries-build && \
    git clone --depth 1 --branch v${VULKAN_VERSION} https://github.com/KhronosGroup/Vulkan-Utility-Libraries.git && \
    cd Vulkan-Utility-Libraries && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DUPDATE_DEPS=On && \
    cmake --build . --parallel && \
    checkinstall --install=no --fstrans=no --nodoc --pkgname=vulkan-utility-libraries-dev --pkgversion=${VULKAN_VERSION} -y && \
    dpkg -i vulkan-utility-libraries-dev_${VULKAN_VERSION}*.deb && \
    rm -rf /Vulkan-Utility-Libraries-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /Vulkan-Headers-build && \
    cd /Vulkan-Headers-build && \
    git clone --depth 1 --branch v${VULKAN_VERSION} https://github.com/KhronosGroup/Vulkan-Headers.git && \
    cd Vulkan-Headers && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . --parallel && \
    checkinstall --install=no --fstrans=no --nodoc --pkgname=libvulkan-dev --pkgversion=${VULKAN_VERSION} -y && \
    dpkg -i libvulkan-dev_${VULKAN_VERSION}*.deb && \
    rm -rf /Vulkan-Headers-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /extra-cmake-modules-build && \
    cd /extra-cmake-modules-build && \
    git clone --depth 1 --branch v${EXTRA_CMAKE_MODULES_VERSION} https://github.com/KDE/extra-cmake-modules.git && \
    cd extra-cmake-modules && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . --parallel && \
    checkinstall --install=no --fstrans=no --nodoc --pkgname=extra-cmake-modules --pkgversion=${EXTRA_CMAKE_MODULES_VERSION} -y && \
    dpkg -i extra-cmake-modules_${EXTRA_CMAKE_MODULES_VERSION}*.deb && \
    rm -rf /extra-cmake-modules-build

RUN echo 'cd /src && cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DRMT_ENABLED=0' >> ~/.bash_history
RUN echo 'cd /src && cmake --build . --parallel' >> ~/.bash_history
RUN echo 'cd /src && ./packaging/build-appimage.sh' >> ~/.bash_history

RUN echo bind "'\"\\e[24~\": \" \\C-k\\C-u clear\\n\"'" >> ~/.bashrc
