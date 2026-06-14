# How to Run the RMUA Simulator

This is the simple run guide for the RMUA 2026 simulator on Ubuntu 22.04 using Docker.

## 1. Start the simulator

Go to the simulator folder:

```bash
cd ~/jacksit/rmua/IntelligentUAVChampionshipSimulator
```

Start the simulator container:

```bash
docker rm -f sim01 2>/dev/null

docker run -d \
  --net host \
  --gpus '"device=0"' \
  -e Seed=123 \
  --name sim01 \
  simulator01_fixed
```

or start with ue4 gui:

```bash
docker rm -f sim01

xhost +local:docker

docker run -it --rm \
  --net host \
  --gpus '"device=1"' \
  -e Seed=123 \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --name sim_gui \
  --entrypoint /bin/bash \
  simulator01_fixed -lc '
source /opt/ros/noetic/setup.bash
roscore &
sleep 5
exec /usr/local/Build/LinuxNoEditor/RMUA/Binaries/Linux/RMUA-Linux-Shipping \
  -seed 123 \
  -windowed
'
```

Check if it is running:

```bash
docker ps | grep sim01
```

If it shows `sim01` and `Up`, the simulator is running.

## 2. Check simulator logs

```bash
docker logs -f sim01
```

You should see something like:

```text
[RMUA] Starting roscore...
[RMUA] Starting simulator with Seed=123
```

Press `Ctrl+C` to stop watching logs. This does **not** stop the simulator.

## 3. Check ROS topics

Open another terminal:

```bash
source /opt/ros/noetic/setup.zsh
rostopic list
```

You should see topics like:

```text
/airsim_node/drone_1/gps
/airsim_node/drone_1/imu/imu
/airsim_node/drone_1/lidar
/airsim_node/drone_1/vel_body_cmd
/airsim_node/end_goal
/airsim_node/initial_pose
```

## 4. Quick sensor test

Check goal:

```bash
rostopic echo -n 1 /airsim_node/end_goal
```

Check GPS:

```bash
rostopic echo -n 1 /airsim_node/drone_1/gps
```

Check IMU rate:

```bash
rostopic hz /airsim_node/drone_1/imu/imu
```

If IMU is around `100 Hz`, the simulator is working.

## 5. Stop the simulator

```bash
docker rm -f sim01
```

## 6. Restart with another seed

Change `Seed=123` to another number:

```bash
docker rm -f sim01 2>/dev/null

docker run -d \
  --net host \
  --gpus '"device=0"' \
  -e Seed=456 \
  --name sim01 \
  simulator01_fixed
```

## Notes

- Use `simulator01_fixed`, not the broken original image.
- Do not use `./run_simulator.sh` on Ubuntu 22.04. It may fail with missing old Ubuntu 20.04 libraries.
- If `rostopic list` says it cannot communicate with master, check whether the simulator is still running:

```bash
docker ps -a | grep sim01
docker logs --tail 100 sim01
```
