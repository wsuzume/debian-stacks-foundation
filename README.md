# debian-stacks-foundation
Development environment layer for a Debian-based image on Docker.

This extracts the user-switching functionality built into Jupyter's official images (e.g., minimal-notebook). By incorporating this layer into a Docker image, users can easily adjust the user ID and group ID when starting the container. This is extremely useful if you want to use Docker containers as your development environment.

# Usage
First, choose any Debian-based base image you like, such as bookworm or ubuntu (e.g., ubuntu:22.04). You can also use an image that you have customized. Next, decide on the tag for the image after applying this development layer (e.g., ubuntu-devel:22.04). Once you have made your selections, execute the following command.

```
DOCKER_BUILD_ARGS="--build-arg ROOT_CONTAINER=ubuntu:22.04" TAG="ubuntu-devel:22.04" make build
```

If you need to use sudo to run docker commands, change the command to `make sudo_build`.

When you start a container using the development image created by the above steps, the default user will be `uid=1000(morgan) gid=100(users) groups=100(users)`.

```
$ sudo docker container run -it --rm ubuntu-devel:22.04
Entered start.sh with args:
Running hooks in: /usr/local/bin/start.d as uid: 1000 gid: 100
Done running hooks in: /usr/local/bin/start.d
Running hooks in: /usr/local/bin/init.d as uid: 1000 gid: 100
Done running hooks in: /usr/local/bin/init.d
Executing the command: bash
morgan@f03bad688337:~$ id
uid=1000(morgan) gid=100(users) groups=100(users)
```

When specifying `root` as the user at container startup, it is possible to specify environment variables such as `USER`, `UID`, and `GID`.

```
$ sudo docker container run -it --rm -u root -e USER=jovyan -e UID=1200 -e GID=2000 ubuntu-d
evel:22.04
Entered start.sh with args:
Running hooks in: /usr/local/bin/start.d as uid: 0 gid: 0
Done running hooks in: /usr/local/bin/start.d
Updated the morgan user:
- username: morgan       -> jovyan
- home dir: /home/morgan -> /home/jovyan
Update jovyan's UID:GID to 1200:2000
userdel: group jovyan not removed because it is not the primary group of user jovyan.
Attempting to copy /home/morgan to /home/jovyan...
Success!
Changing working directory to /home/jovyan/
Running hooks in: /usr/local/bin/init.d as uid: 0 gid: 0
Done running hooks in: /usr/local/bin/init.d
Running as jovyan: bash
jovyan@1702d80c380f:~$ id
uid=1200(jovyan) gid=2000(jovyan) groups=2000(jovyan),100(users)
```

Additionally, by specifying `-u root` along with `-e GRANT_SUDO=yes`, you can enable the use of sudo within the container.

```
$ sudo docker container run -it --rm -u root -e GRANT_SUDO=yes ubuntu-devel:22.04
Entered start.sh with args:
Running hooks in: /usr/local/bin/start.d as uid: 0 gid: 0
Done running hooks in: /usr/local/bin/start.d
Granting morgan passwordless sudo rights!
Running hooks in: /usr/local/bin/init.d as uid: 0 gid: 0
Done running hooks in: /usr/local/bin/init.d
Running as morgan: bash
morgan@5011d0d9149f:~$ sudo ls
work
```