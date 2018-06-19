FROM ubuntu:bionic

RUN apt-get update
RUN apt-get -y install locales lsb-release wget gnupg

RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

RUN apt-get update

# Install Python 3
RUN apt-get install -y python3.6 libpython3.6

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## preesed tzdata, update package index, upgrade packages and install needed software
RUN echo "tzdata tzdata/Areas select US" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/Europe select San Francisco" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt-get update && \
    apt-get install -y tzdata

RUN apt-get install -y git wget
RUN apt-get install -y build-essential cppcheck cmake libopencv-dev python-empy python3-catkin-pkg-modules python3-dev python3-empy python3-nose python3-pip python3-pyparsing python3-setuptools python3-vcstool python3-yaml libtinyxml-dev libeigen3-dev libassimp-dev libpoco-dev
# dependencies for testing
RUN apt-get install -y clang-format pydocstyle pyflakes python3-coverage python3-mock python3-pep8 uncrustify
# Install argcomplete for command-line tab completion from the ROS2 tools.
# Install from pip rather than from apt-get because of a bug in the Ubuntu 16.04 version of argcomplete:
RUN python3 -m pip install argcomplete
# additional testing dependencies from pip (because not available on ubuntu 16.04)
RUN python3 -m pip install flake8 flake8-blind-except flake8-builtins flake8-class-newline flake8-comprehensions flake8-deprecated flake8-docstrings flake8-import-order flake8-quotes pytest pytest-cov pytest-runner
# dependencies for FastRTPS
RUN apt-get install -y libasio-dev libtinyxml2-dev
# dependencies for RViz
RUN apt-get install -y libfreetype6-dev libfreeimage-dev libzzip-dev libxrandr-dev libxaw7-dev freeglut3-dev libgl1-mesa-dev libcurl4-openssl-dev libqt5core5a libqt5gui5 libqt5opengl5 libqt5widgets5 libxaw7-dev libgles2-mesa-dev libglu1-mesa-dev qtbase5-dev

RUN mkdir /root/ros2_ws
RUN mkdir /root/ros2_ws/src
WORKDIR /root/ros2_ws
RUN wget https://raw.githubusercontent.com/ros2/ros2/master/ros2.repos
RUN vcs-import src < ros2.repos

RUN src/ament/ament_tools/scripts/ament.py build --build-tests --symlink-install

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# setup entrypoint
COPY ./ros2_entrypoint.sh /
ENTRYPOINT ["/ros2_entrypoint.sh"]
CMD ["bash"]
