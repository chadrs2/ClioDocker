# ClioDocker
Docker container enabling use of [Clio](https://github.com/MIT-SPARK/Clio) repository.

## Installation

1. Clone repository
2. Enable X11 access control for container: `xhost +local:docker`
3. Download `clio_ws` [here](https://www.dropbox.com/scl/fi/q4ws6wnh5z9l1jdxztbf9/clio_ws.zip?rlkey=cgjrob8ddkyhof0rosizw7jmw&e=1&st=thdh8o5m&dl=0)
4. Inside the `clio_ws/src` delete the old version of teaser_plusplus (the fixed/updated version is installed in the `clio.rosinstall` file)
5. Build the docker image: `docker build -t clio_archive .`
6. Run the docker image in a container with the following command: 
```
docker run -it --user ros --network=host --ipc=host -v /<path_to_clio_dataset>:/clio_dataset -v /tmp/.X11-unix:/tmp/.X11-unix:rw --gpus all --runtime nvidia --env="QT_X11_NO_MITSHM=1" --env="NVIDIA_DRIVER_CAPABILITIES=all" --env="NVIDIA_VISIBLE_DEVICES=all" --device=/dev/dri:/dev/dri --env=DISPLAY clio_archive
```

## Running

### Clio-Online
1. In `clio_ws`, `source ~/clio_env/bin/activate`
2. `source devel/setup.bash`
3. Edit the `realsense_pipeline.yaml` file in the `clio` package to match camear intrinsics.
4. `roslaunch hydra_llm_ros realsense.launch scene:=<scene_name> tasks_file:=<filepath_to_tasks.yaml> sensor_max_range:=20.0 log_path:=<path_to_save_scene_graph_results>`
5. In another terminal in the container, play the rosbag. I had to slow down to around `-r 0.1` rate for best performance
6. Run evaluation scripts in up-to-date [Clio](https://github.com/MIT-SPARK/Clio) repo