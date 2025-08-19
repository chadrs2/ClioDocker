# ClioDocker
Docker container enabling use of [Clio](https://github.com/MIT-SPARK/Clio) repository.

## Installation

1. Clone repository
2. Enable X11 access control for container: `xhost +local:docker`
3. Build the docker image: `docker build -t clio_ros1 .`
4. Run the docker image in a container with the following command: 
```
docker run -it --user ros --network=host --ipc=host -v /<path_to_clio_dataset>:/clio_dataset -v /tmp/.X11-unix:/tmp/.X11-unix:rw --gpus all --runtime nvidia --env="QT_X11_NO_MITSHM=1" --env="NVIDIA_DRIVER_CAPABILITIES=all" --env="NVIDIA_VISIBLE_DEVICES=all" --device=/dev/dri:/dev/dri --env=DISPLAY clio_ros1
```
5. Go to the [Clio](https://github.com/MIT-SPARK/Clio) repository for details on running and testing with Clio.