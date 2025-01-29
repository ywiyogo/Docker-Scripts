# Scripts for running Docker

## Enabling GPU support

On Arch Linux, need to install the NVIDIA Container Toolkit to enable GPU support in Docker. Please run `sudo pacman -S nvidia-container-toolkit` if the toolkit isn't installed yet.

## Dealing with Nvidia and libOgre crash on Qt application

This is an example of the backtrace running `gdb rviz2`
```bash
#0  0x0000779c4c93514d in ?? () from /usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.0
#1  0x0000779c3e8b3943 in ?? () from /usr/lib/x86_64-linux-gnu/libnvidia-glcore.so.565.77
#2  0x0000779c4c95615e in ?? () from /usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.0
#3  0x0000779c4c924490 in ?? () from /usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.0
#4  0x0000779c5fce82aa in Ogre::RenderSystem::_swapAllRenderTargetBuffers() ()
   from /opt/ros/jazzy/opt/rviz_ogre_vendor/lib/libOgreMain.so.1.12.10
#5  0x0000779c5fd2039b in Ogre::Root::_updateAllRenderTargets() ()
   from /opt/ros/jazzy/opt/rviz_ogre_vendor/lib/libOgreMain.so.1.12.10
#6  0x0000779c5fd18890 in Ogre::Root::renderOneFrame() ()
   from /opt/ros/jazzy/opt/rviz_ogre_vendor/lib/libOgreMain.so.1.12.10
```

In order to fix this, `/etc/docker/daemon.json`should be created and contains:
```json
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```

then restart docker `sudo systemctl restart docker` and add `--runtime nvidia` in the `docker run` argument.

## Allowing UDP Multicast for multi robot communication

If the ufw firewall is enabled, the ROS node and topic won't be detected. In order to see the UDP multicast, allow the UDP multicast in localhost. If our local network is has this IP 192.168.8.X, we can allow it using this:

```
sudo ufw allow in proto udp from 192.168.8.0/24 to any
```