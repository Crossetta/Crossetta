FROM fedora:45

RUN dnf -y --setopt=install_weak_deps=False install \
	glslc \
	ccache \
	mingw64-vulkan-loader \
	mingw64-vulkan-utility-libraries \
	mingw64-adwaita-qt6 \
	mingw64-qt6-qtdeclarative \
	mingw64-qt6-qtimageformats \
	mingw64-qt6-qtshadertools \
	mingw64-qt6-qtsvg \
	msitools \
	mingw64-dlfcn \
	mingw64-gcc \
	mingw64-gcc-c++

ENV CC=x86_64-w64-mingw32-gcc
ENV CXX=x86_64-w64-mingw32-g++
ENV PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/
ENV CMAKE_PREFIX_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/cmake/

RUN echo mkdir -p build-msi > ~/.bash_history
RUN echo 'cd /src/build-msi && cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES:PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/include/ -DCMAKE_SYSTEM_NAME=Windows -DRMT_ENABLED=0' >> ~/.bash_history
RUN echo 'cd /src/build-msi && cmake --build . --parallel' >> ~/.bash_history
RUN echo 'cd /src && ./packaging/build-msi.sh' >> ~/.bash_history
RUN echo 'cd /src && ./packaging/package-msi.sh "$PWD"/build-msi "$PWD"' >> ~/.bash_history

RUN echo bind "'\"\\e[24~\": \" \\C-k\\C-u clear\\n\"'" >> ~/.bashrc
