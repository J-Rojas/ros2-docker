#!/bin/bash
set -e

# setup ros2 environment
export ROS2_WS=~/ros2_ws
. $ROS2_WS/install/local_setup.bash
exec "$@"
