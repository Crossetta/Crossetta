FROM ubuntu:22.04

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
    checkinstall --install=no --nodoc --pkgname=cmake --pkgversion=${CMAKE_VERSION} -y && \
    apt -y remove cmake cmake-data && \
    dpkg -i cmake_${CMAKE_VERSION}*.deb && \
    rm -rf /cmake-build

# Mount local ./qt source tree into the container
RUN --mount=from=qt,target=/src/qt --mount=type=cache,target=/root/.ccache \
    mkdir /build && \
    cd /build && \
    /src/qt/configure \
        -prefix /usr \
        -opensource \
        -confirm-license \
        -release \
        -ccache \
        -xcb \
        -opengl \
        -skip qt3d \
        -skip qtcharts \
        -skip qtdatavis3d \
        -skip qtgamepad \
        -skip qtgraphs \
        -skip qtmqtt \
        -skip qtopenapi \
        -skip qtquick3d \
        -skip qtquick3dphysics \
        -skip qtquickeffectmaker \
        -skip qtremoteobjects \
        -skip qtsensors \
        -skip qtserialbus \
        -skip qtserialport \
        -skip qtspeech \
        -skip qtwebchannel \
        -skip qtwebengine \
        -skip qtwebsockets \
        -nomake examples \
        -nomake tests && \
    cmake --build . --parallel && \
    cmake --install . && \
    rm -r /build

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
    checkinstall --install=no --nodoc --pkgname=glslc --pkgversion=${GLSLC_VERSION} -y && \
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
    checkinstall --install=no --nodoc --pkgname=libvulkan1 --pkgversion=${VULKAN_VERSION} -y && \
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
    checkinstall --install=no --nodoc --pkgname=vulkan-utility-libraries-dev --pkgversion=${VULKAN_VERSION} -y && \
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
    checkinstall --install=no --nodoc --pkgname=libvulkan-dev --pkgversion=${VULKAN_VERSION} -y && \
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
    checkinstall --install=no --nodoc --pkgname=extra-cmake-modules --pkgversion=${EXTRA_CMAKE_MODULES_VERSION} -y && \
    dpkg -i extra-cmake-modules_${EXTRA_CMAKE_MODULES_VERSION}*.deb && \
    rm -rf /extra-cmake-modules-build

RUN python3 -m pip install meson==0.64.0 && \
    ln -sT /usr/local/bin/meson /usr/bin/meson

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /wayland-protocols-build && \
    cd /wayland-protocols-build && \
    git clone --depth 1 --branch ${WAYLAND_PROTOCOLS_VERSION} https://gitlab.freedesktop.org/wayland/wayland-protocols.git && \
    cd wayland-protocols && \
    /usr/local/bin/meson setup build \
        -Dtests=false \
        --prefix=/usr \
        --buildtype=release && \
    meson compile -C build && \
    checkinstall --install=no --nodoc --pkgname=wayland-protocols --pkgversion=${WAYLAND_PROTOCOLS_VERSION} -y meson install -C build && \
    dpkg -i wayland-protocols_${WAYLAND_PROTOCOLS_VERSION}*.deb && \
    rm -rf /wayland-protocols-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /plasma-wayland-protocols-build && \
    cd /plasma-wayland-protocols-build && \
    git clone --depth 1 --branch v${PLASMA_WAYLAND_PROTOCOLS_VERSION} https://invent.kde.org/libraries/plasma-wayland-protocols.git && \
    cd plasma-wayland-protocols && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=plasma-wayland-protocols --pkgversion=${PLASMA_WAYLAND_PROTOCOLS_VERSION} -y && \
    dpkg -i plasma-wayland-protocols_${PLASMA_WAYLAND_PROTOCOLS_VERSION}*.deb && \
    rm -rf /plasma-wayland-protocols-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kconfig-build && \
    cd /kconfig-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kconfig.git && \
    cd kconfig && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_{TESTING,FUZZERS}=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kconfig --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kconfig_${KDE_VERSION}*.deb && \
    rm -rf /kconfig-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kguiaddons-build && \
    cd /kguiaddons-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kguiaddons.git && \
    cd kguiaddons && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_PYTHON_BINDINGS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kguiaddons --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kguiaddons_${KDE_VERSION}*.deb && \
    rm -rf /kguiaddons-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /ki18n-build && \
    cd /ki18n-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/ki18n.git && \
    cd ki18n && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=ki18n --pkgversion=${KDE_VERSION} -y && \
    dpkg -i ki18n_${KDE_VERSION}*.deb && \
    rm -rf /ki18n-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kcolorscheme-build && \
    cd /kcolorscheme-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kcolorscheme.git && \
    cd kcolorscheme && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kcolorscheme --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kcolorscheme_${KDE_VERSION}*.deb && \
    rm -rf /kcolorscheme-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /karchive-build && \
    cd /karchive-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/karchive.git && \
    cd karchive && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=karchive --pkgversion=${KDE_VERSION} -y && \
    dpkg -i karchive_${KDE_VERSION}*.deb && \
    rm -rf /karchive-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kwidgetsaddons-build && \
    cd /kwidgetsaddons-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kwidgetsaddons.git && \
    cd kwidgetsaddons && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_PYTHON_BINDINGS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kwidgetsaddons --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kwidgetsaddons_${KDE_VERSION}*.deb && \
    rm -rf /kwidgetsaddons-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kiconthemes-build && \
    cd /kiconthemes-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kiconthemes.git && \
    cd kiconthemes && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DUSE_BreezeIcons=OFF && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kiconthemes --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kiconthemes_${KDE_VERSION}*.deb && \
    rm -rf /kiconthemes-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kirigami-build && \
    cd /kirigami-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kirigami.git && \
    cd kirigami && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kirigami --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kirigami_${KDE_VERSION}*.deb && \
    rm -rf /kirigami-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /qqc2-breeze-style-build && \
    cd /qqc2-breeze-style-build && \
    git clone --depth 1 --branch v${QQC2_BREEZE_STYLE_VERSION} https://invent.kde.org/plasma/qqc2-breeze-style.git && \
    cd qqc2-breeze-style && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=qml6-module-org-kde-breeze --pkgversion=${QQC2_BREEZE_STYLE_VERSION} -y && \
    dpkg -i qml6-module-org-kde-breeze_${QQC2_BREEZE_STYLE_VERSION}*.deb && \
    rm -rf /qqc2-breeze-style-build

# For palette changes.
RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kitemviews-build && \
    cd /kitemviews-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kitemviews.git && \
    cd kitemviews && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kitemviews --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kitemviews_${KDE_VERSION}*.deb && \
    rm -rf /kitemviews-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kcoreaddons-build && \
    cd /kcoreaddons-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kcoreaddons.git && \
    cd kcoreaddons && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_PYTHON_BINDINGS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kcoreaddons --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kcoreaddons_${KDE_VERSION}*.deb && \
    rm -rf /kcoreaddons-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kcodecs-build && \
    cd /kcodecs-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kcodecs.git && \
    cd kcodecs && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO-DBUILD_FUZZERS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kcodecs --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kcodecs_${KDE_VERSION}*.deb && \
    rm -rf /kcodecs-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kconfigwidgets-build && \
    cd /kconfigwidgets-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kconfigwidgets.git && \
    cd kconfigwidgets && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kconfigwidgets --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kconfigwidgets_${KDE_VERSION}*.deb && \
    rm -rf /kconfigwidgets-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kglobalaccel-build && \
    cd /kglobalaccel-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kglobalaccel.git && \
    cd kglobalaccel && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kglobalaccel --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kglobalaccel_${KDE_VERSION}*.deb && \
    rm -rf /kglobalaccel-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kxmlgui-build && \
    cd /kxmlgui-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kxmlgui.git && \
    cd kxmlgui && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_PYTHON_BINDINGS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kxmlgui --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kxmlgui_${KDE_VERSION}*.deb && \
    rm -rf /kxmlgui-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kwindowsystem-build && \
    cd /kwindowsystem-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kwindowsystem.git && \
    cd kwindowsystem && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kwindowsystem --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kwindowsystem_${KDE_VERSION}*.deb && \
    rm -rf /kwindowsystem-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kservice-build && \
    cd /kservice-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kservice.git && \
    cd kservice && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kservice --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kservice_${KDE_VERSION}*.deb && \
    rm -rf /kservice-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /solid-build && \
    cd /solid-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/solid.git && \
    cd solid && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=solid --pkgversion=${KDE_VERSION} -y && \
    dpkg -i solid_${KDE_VERSION}*.deb && \
    rm -rf /solid-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kcrash-build && \
    cd /kcrash-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kcrash.git && \
    cd kcrash && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kcrash --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kcrash_${KDE_VERSION}*.deb && \
    rm -rf /kcrash-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kdbusaddons-build && \
    cd /kdbusaddons-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kdbusaddons.git && \
    cd kdbusaddons && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kdbusaddons --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kdbusaddons_${KDE_VERSION}*.deb && \
    rm -rf /kdbusaddons-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kbookmarks-build && \
    cd /kbookmarks-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kbookmarks.git && \
    cd kbookmarks && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kbookmarks --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kbookmarks_${KDE_VERSION}*.deb && \
    rm -rf /kbookmarks-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kstatusnotifieritem-build && \
    cd /kstatusnotifieritem-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kstatusnotifieritem.git && \
    cd kstatusnotifieritem && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_PYTHON_BINDINGS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kstatusnotifieritem --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kstatusnotifieritem_${KDE_VERSION}*.deb && \
    rm -rf /kstatusnotifieritem-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /knotifications-build && \
    cd /knotifications-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/knotifications.git && \
    cd knotifications && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_PYTHON_BINDINGS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=knotifications --pkgversion=${KDE_VERSION} -y && \
    dpkg -i knotifications_${KDE_VERSION}*.deb && \
    rm -rf /knotifications-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kjobwidgets-build && \
    cd /kjobwidgets-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kjobwidgets.git && \
    cd kjobwidgets && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_PYTHON_BINDINGS=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kjobwidgets --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kjobwidgets_${KDE_VERSION}*.deb && \
    rm -rf /kjobwidgets-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kcompletion-build && \
    cd /kcompletion-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kcompletion.git && \
    cd kcompletion && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kcompletion --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kcompletion_${KDE_VERSION}*.deb && \
    rm -rf /kcompletion-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /kio-build && \
    cd /kio-build && \
    git clone --depth 1 --branch v${KDE_VERSION} https://invent.kde.org/frameworks/kio.git && \
    cd kio && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=kio --pkgversion=${KDE_VERSION} -y && \
    dpkg -i kio_${KDE_VERSION}*.deb && \
    rm -rf /kio-build

RUN --mount=type=cache,target=/root/.ccache \
    mkdir /plasma-integration-build && \
    cd /plasma-integration-build && \
    git clone --depth 1 --branch v${PLASMA_INTEGRATION_VERSION} https://invent.kde.org/plasma/plasma-integration.git && \
    cd plasma-integration && \
    mkdir build && \
    cd build && \
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=NO -DBUILD_QT5=NO && \
    cmake --build . --parallel && \
    checkinstall --install=no --nodoc --pkgname=plasma-integration --pkgversion=${PLASMA_INTEGRATION_VERSION} -y && \
    dpkg -i plasma-integration_${PLASMA_INTEGRATION_VERSION}*.deb && \
    rm -rf /plasma-integration-build

RUN wget https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage && \
    chmod +x appimagetool-x86_64.AppImage && \
    mv appimagetool-x86_64.AppImage /usr/bin/appimagetool

RUN wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage && \
    chmod +x linuxdeployqt-continuous-x86_64.AppImage && \
    mv linuxdeployqt-continuous-x86_64.AppImage /usr/bin/linuxdeployqt

RUN echo 'cd /src && cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DRMT_ENABLED=0' >> ~/.bash_history
RUN echo 'cd /src && cmake --build . --parallel' >> ~/.bash_history
RUN echo 'cd /src && ./packaging/build-appimage.sh' >> ~/.bash_history

RUN echo bind "'\"\\e[24~\": \" \\C-k\\C-u clear\\n\"'" >> ~/.bashrc
