FROM fedora:45

RUN dnf -y --setopt=install_weak_deps=False install \
	glslc \
	ccache \
	cmake \
	ninja \
	vulkan-loader-devel \
	vulkan-utility-libraries-devel \
	qt6-qtdeclarative-devel \
	qt6-qtimageformats \
	qt6-qtshadertools-devel \
	qt6-qtsvg-devel  \
	gcc \
	gcc-c++

RUN echo 'cd /src && cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DRMT_ENABLED=0' >> ~/.bash_history
RUN echo 'cd /src && cmake --build . --parallel' >> ~/.bash_history
RUN echo 'cd /src && ./packaging/build-appimage.sh' >> ~/.bash_history

RUN echo bind "'\"\\e[24~\": \" \\C-k\\C-u clear\\n\"'" >> ~/.bashrc
