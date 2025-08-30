# =========================================================
# Base image
# =========================================================
FROM osrf/ros:noetic-desktop-full

SHELL ["/bin/bash", "-c"]

# =========================================================
# User setup
# =========================================================
ARG USERNAME=ros
ARG USER_UID=1001
ARG USER_GID=${USER_UID}

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && mkdir /home/$USERNAME/.config && chown ${USER_UID}:${USER_GID} /home/${USERNAME}/.config

# Setup sudo
RUN apt-get update \
    && apt-get install -y sudo \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# =========================================================
# Environment variables
# =========================================================
ENV ROS_DISTRO=noetic
ENV CATKIN_WS=/home/${USERNAME}/clio_ws
ENV DEBIAN_FRONTEND=noninteractive

# =========================================================
# Install system dependencies not included in desktop-full
# =========================================================
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    build-essential git wget cmake tmux python3-pip \
    python3-rosdep python3-catkin-tools python3-virtualenv \ 
    python3-catkin-tools python3-rosinstall python3-rosinstall-generator python3-wstool \
    python3-vcstool python3-virtualenv python3-dev python3-setuptools \
    libopencv-dev qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 \
    libpcl-dev libyaml-cpp-dev nlohmann-json3-dev libgoogle-glog-dev \
    python3-flask pybind11-dev libgflags-dev libgrpc-dev libgrpc++-dev \
    libprotobuf-dev libprotobuf-c-dev protobuf-compiler-grpc \
    libzmq5-dev libzmqpp-dev libzmq3-dev \
    && sudo rm -rf /var/lib/apt/lists/*

# =========================================================
# Create and Build Clio workspace
# =========================================================
COPY clio_ws/ /home/${USERNAME}/clio_ws/
RUN sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/clio_ws

WORKDIR $CATKIN_WS/src
COPY clio.rosinstall $CATKIN_WS/src/clio.rosinstall
RUN vcs import < clio.rosinstall

WORKDIR $CATKIN_WS

# Configure catkin (force Release + modern C++)
RUN catkin init && \
    catkin config \
      -DCMAKE_BUILD_TYPE=Release \
      -DGTSAM_USE_SYSTEM_EIGEN=ON \
      --skiplist khronos_eval
    #   -a -DSEMANTIC_INFERENCE_USE_TRT=OFF

# Install package dependencies, including GTSAM
RUN rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    sudo rm -rf /var/lib/apt/lists/*

# Build workspace (must source ROS setup first)
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin build"

# =========================================================
# Python virtual environments for semantic packages
# =========================================================
RUN python3 -m virtualenv /home/${USERNAME}/clio_env --system-site-packages && \
    source /home/${USERNAME}/clio_env/bin/activate && \
    pip install -e ./src/llm_graphs && \
    deactivate

# =========================================================
# Setup environment for shell
# =========================================================
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/${USERNAME}/.bashrc && \
    echo "source $CATKIN_WS/devel/setup.bash" >> /home/${USERNAME}/.bashrc && \
    echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:$CATKIN_WS/src" >> /home/${USERNAME}/.bashrc

WORKDIR $CATKIN_WS

# =========================================================
# Entrypoint
# =========================================================
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD ["bash"]
