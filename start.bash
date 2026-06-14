#!/bin/bash
set -e
source /opt/ros/noetic/setup.bash

: ${Seed:=123}

echo "[RMUA] Starting roscore..."
roscore &
sleep 5

echo "[RMUA] Starting simulator with Seed=${Seed}"
exec /usr/local/Build/LinuxNoEditor/RMUA/Binaries/Linux/RMUA-Linux-Shipping \
    -RenderOffscreen \
    -seed ${Seed} \
    -windowed
