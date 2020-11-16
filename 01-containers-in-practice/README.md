# TP 1: Linux Containers in Practice: a Docker flavor

- **Related course module**: IR.3504 - Convergent Services and Technologies
- **Tutorial scope**: OS Level Virtualization & Containers
- **Technologies**: Linux, Docker

During this tutorial, we will learn few things like:
- What is a container ?
- How to use the docker CLI (Command Line Interface) ?
- Create your first docker container
- Create your first docker image
- Create a stack using docker compose

> In the following, you will see `Discover` if you should play around
> and see the documentation or test. You will see `Action` if you should
> run a command, write a program, or something similar. You will see `Question` when there is a question to provide an answer to.

## Prerequisites

These prerequisites only concern you if you will use a Virtual Machine (VM) on a public cloud to execute the different steps. For that, you need to have:

- an **ssh client** already configured on you desktop
- pick an **account** from the accounts csv file containing: VM's public IP address and credentials needed for connecting

## Before you start

I recommend that you create a text file with your favorite editor where you will continuously copy the commands and their output to help you with your TP report.

> Please note that the **VM will be destroyed** upon finishing the TP with a **grace period of 1 hour** approximately.

## Environment Setup (~30 minutes)

### Environment properties

`Action` + `Discover`

In this section, you will explore your environment with a set of commands to know a bit more the configuration that you are provided with:

1. `dmidecode -s system-product-name`
2. `lshw -class system`
3. `systemd-detect-virt`
4. `uname -a`
5. `cat /etc/issue`
6. `date`
7. `uptime`
8. `lscpu`
9. `free -m`
10. `df -h`
11. `mount`
12. `ip a`
13. `ip r`
14. `curl http://ip-api.com/json/<public_ip> | jq` # You may need to install `jq`

Use `man` to lean about those commands.

These commands help you get some basic information about your environment such as: virtualization technology (if any!), distribution, hardware (cpu, memory, storage), network, etc.

### Linux Namespaces, Cgroups & Docker

`Discover`

Explore these links
- https://docs.docker.com/get-started/overview/
- https://man7.org/linux/man-pages/man7/namespaces.7.html
- https://man7.org/linux/man-pages/man7/cgroups.7.html


`Question`

- What is Docker ?
- What are the main components of Docker ?
- What are the technologies that Docker uses under the hood ?


### Install Docker Engine

`Action` + `Discover`

Use the official documentation to install docker engine: https://docs.docker.com/engine/install/

To verify if Docker Engine is correctly isntalled:

```console
docker --version
```

Run the following command:

```console
docker info
```

`Question`

- What is the Docker server (daemon) version ?
- What are the supported networking plugins ?
- Does Docker use SELinux ? If not, what are the supported tools ?

### Install Docker Compose

`Action` + `Discover`

Use the official documentation to install docker compose: https://docs.docker.com/compose/install/

To verify if Docker Compose is correctly installed:

```console
docker-compose --version
```

`Question`

- What is Docker Compose ?

### Docker CLI

`Action`

In your terminal, run the following command:

```console
docker --help
```

`Question`

- What are the CLI commands that can give you:
    - the list of the running containers
    - the list of available container images
    - some container statistics (CPU, RAM, I/O, etc.)
    - the list of networks created by default
- What is the command that can let you execute a command inside a running container ?
- What is the command that can let you download a container image ?


## What is a container ? (~45 minutes)

A container is simply another process on your system with some specific configurations that are applied to make sure that:
- the containerized process is **isolated** from the rest of the system
- and it has a **limited access to system resources**

resulting in a "sandboxed" program that acts as an independent system.

### Containers & Processes

`Action`

To see this in practice we will use a simple web server container using `httpd`. But first, let's make sure that no instances of `httpd` are already running on our system:

```console
ps -aef |grep httpd
```

Now you need to pull the image from the public Docker Hub repository:

```console
docker image pull httpd:alpine
```

List the local docker images:

```console
docker image ls
```

To run the docker container:

```console
docker run --name httpd -d -e INSTITUTION=isep httpd:alpine
```

> Note: `INSTITUTION` environment variable is just a dummy variable that has nothing to do with httpd but serves the purpose of this TP later on. You can modify it if you want !

`Question`

- What is the result of `ps -aef |grep httpd` now ?
- What is the `PID` and `PPID` of the parent `httpd` process ?

Compare that with the output of the following command:

```console
docker top httpd
```

`Question`

- What can you notice about both outputs ?

`Action`

Let's now see what this container (or iseolated Linux process) is made of. Just like a normal Linux process, you can find more details about it in the `/proc` (https://man7.org/linux/man-pages/man5/proc.5.html), the process information pseudo-filesystem.

Run the following command to list all the content of `/proc`:

```console
ls /proc
```

Now use `httpd` process ID that you got previously to explore its configuration under:

```console
ls /proc/<PID>/
```

Let's take a look at a particular file: `environ` which contains the environment variables of the process:

```console
cat /proc/<PID>/environ
```

Now execute `env` command inside the container by running:

```console
docker exec httpd env
```

`Question`

- What do you notice ?

You can also verify the container's default gateway, by comparing:

```console
cat /proc/<PID>/net/route
```

whith:

```console
docker exec httpd route
```

> Hint: to convert hex to decimal you can use `echo $((16#11))` which will convert hex 11 to decimal for example.

### Containers & Namespaces

The isolation property of containers is implemented by the means of Linux namespaces. To explore these, install the **container info** tool that you can find here: https://github.com/mhausenblas/cinf

```console
curl -s -L https://github.com/mhausenblas/cinf/releases/latest/download/cinf_linux_amd64.tar.gz \
    -o cinf.tar.gz && \
    tar xvzf cinf.tar.gz cinf && \
    mv cinf /usr/local/bin && \
    rm cinf*
```

Verify the installation by running:

```console
cinf -version
```

`Question`

- What `cinf` is used for ?

`Action` + `Question`

- What `namespaces` are used by `httpd` container ? How many ?
- What is the version of cgroups used by this container ? Justify whether it's v1 or v2.

### Containers & Linux Capabilities

`Discover`

Explore the following links to have an overview of Linux capabilities and their impact on a process/container:

- https://man7.org/linux/man-pages/man7/capabilities.7.html
- https://man7.org/linux/man-pages/man5/proc.5.html

`Question`

- How process capabilities can be listed ?

`Action`

Run the following command and find the lines that correspond to the container's capabilities:

```console
cat /proc/<PID>/status
```

`Question`

- What are the permitted capabilities of the `httpd` container ?

> Hint: to decode a specific capabilities set you can use: `capsh --decode=<hex value>`

### Linux Kernel

`Action` + `Question`

- What is the Linux kernel's version of the `httpd` container ?
- What can you say about it ?

### Inspecting a container

`Action` + `Question`

Run the following command:

```console
docker container inspect httpd
```

- What is the Hostname of the container ?
- What is the IP address of the container ?
- Does the container open any ports ? If yes, which ones ?
- What storage driver the containers uses ?

`Discover`

The complete list of storage drivers can found here: https://docs.docker.com/storage/storagedriver/select-storage-driver/


### Publishing ports

`Discover` + `Action`

By default, ports exposed by a container are only accessible by containers from the same network. To open ports at the Host level, you need to publish them: https://docs.docker.com/config/containers/container-networking/

Let's destroy the `httpd` container:

```console
docker rm -f httpd
```

and create a new one that publishes the port 80:

```console
docker run --name httpd -d -p 80:80 httpd:alpine
```

Verify that your container is now reachable from the outside world by opening your favorite internet browser and going to the following address:

```console
http://<public ip>/
```

If you see **It works** that means that it works.

## Docker Images (~30 minutes)

`Discover`

In this part of the tutorial, you will build a Docker image using the Netcat tool (https://nc110.sourceforge.io/)

### Dockerfile

`Discover`

To create a Docker image you need to create a `Dockerfile` which is basically a text file that contains a set of instructions that the Docker doemon will execute to create a filesystem known as `image`.

Refer to the following links to answer the questions:

- https://docs.docker.com/engine/reference/builder/
- https://docs.docker.com/storage/storagedriver/

`Question`

- What is the role of the `FROM` instruction ?
- What is an image layer ?
- What is the difference between a container layer and an image layer ?
- Is there any alternatives for Docker doemon to build a Docker image ?

`Action`

Create a file named `Dockerfile` with the following content:

```console
FROM alpine:latest
LABEL description "Simple netcat image"

RUN apk add --no-cache netcat-openbsd

ENTRYPOINT [ "nc" ]
```

### Build the image

`Action`

Build a Docker image by specifying the **tag** `netcat:latest` and the **file** `Dockerfile`

> Hint: Refer to the `docker build` documentation to find the correct syntax: https://docs.docker.com/engine/reference/commandline/build/

`Question`

- How many layers your `netcat:latest` image contains ? Explain why ?

### Run the container

`Action`

In your current terminal, start a netcat server container in an interactive mode:

```console
docker run --name nc-server -it netcat -l 8000
```

In a second terminal, retrieve the IP address of nc-server using:

```console
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nc-server
```

Then, start a netcat client container in an interactive mode:

```console
docker run -it netcat <nc-server ip> 8000
```

Start typing some text and see it printed on the server side when you hit enter.

To remove both containers, start a third terminal an run:

```console
docker rm -f nc-server nc-client
```

`Question`

- Why nc-client was able to connect to nc-server ?

## Docker Compose (~20 minutes)

`Action` + `Question`

Print docker-compose help and answer the following questions:

- Which command can be used to run a service ?
- Which command can be used to teardown a service ?

`Action`

Create a `docker-compose.yml` file with the following content:

```console
version: "3.8"
 
 networks:
   private-net:
 
 services:
   nc-server:
     build: .
     entrypoint: sleep 60
     networks:
       - private-net
 
   nc-client:
     build: .
     entrypoint: sleep 60
     networks:
        - private-net
```

`Question`

- What does this file contain ?
- What part of the default image is overriden ?

`Action`

Build all images of the compose file:

```console
docker-compose build
```

Run the stack:

```console
docker-compose up
```

`Question`

- What are the containers that are created by this compose file in the running containers' list ?

`Action`

In two different terminals, execute a server inside nc-server and a client inside nc-client to redo the test and verify that it works.

> Note: Adapt the sleep timer to suit your needs.

`Action`

Update the compose file to be able to connect to `nc-server` from a client that is not on the `private-net` network

## Go further

Docker can also be used as a lightwight container orchestration system using the Docker Swarm project: https://docs.docker.com/engine/swarm/

This orchestration system is currently beeing superseded by other projects like kubernetes.