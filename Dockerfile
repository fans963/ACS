# 使用官方 ROS2 Humble 桌面版作为基础镜像
FROM osrf/ros:humble-desktop

# Change bash as default shell instead of sh
SHELL ["/bin/bash", "-c"]

# Set timezone and non-interactive mode
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

# Install tools and libraries.
RUN apt-get update && apt-get -y install \
    vim wget curl unzip \
    zsh screen \
    usbutils net-tools iputils-ping \
    libusb-1.0-0-dev \
    libeigen3-dev \
    libopencv-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libatlas-base-dev \
    libsuitesparse-dev \
    libceres-dev \
    ros-humble-rviz2 \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# Install develop tools
RUN apt-get update && apt-get -y install \
    libc6-dev gcc-12 g++-12 \
    cmake make ninja-build \
    openssh-client \
    lsb-release software-properties-common gnupg sudo \
    python3-colorama python3-dpkt && \
    wget -O ./llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key && \
    apt-key add ./llvm-snapshot.gpg.key && \
    rm ./llvm-snapshot.gpg.key && \
    echo "deb https://apt.llvm.org/jammy/ llvm-toolchain-jammy main" > /etc/apt/sources.list.d/llvm-apt.list && \
    apt-get update && \
    version=`apt-cache search clangd- | grep clangd- | awk -F' ' '{print $1}' | sort -V | tail -1 | cut -d- -f2` && \
    apt-get install -y clangd-$version && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 50 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 50 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-$version 50 && \
    rm -rf /var/lib/apt/lists/*

# Add user
RUN useradd -m developer --shell /bin/zsh && echo "developer:developer" | chpasswd && adduser developer sudo && \
    echo "developer ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    gpasswd --add developer dialout
WORKDIR /home/developer
ENV USER=developer
ENV WORKDIR=/home/developer
USER developer


# 默认启动 bash 交互环境
CMD ["bash"]
