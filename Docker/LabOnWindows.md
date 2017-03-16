# Docker Lab - Windows 10

This note records the differences between completing the lab using Docker for Windows rather than Docker hosted on Linux.

Docker for Windows is only available for Windows 10. This note does not address how to use what Docker refer to as legacy platforms.

This document currently only covers the excises up to and including the docker-compose exercises.


# Goal

At the end of this workshop you should be able to install Docker for Windows, be familiar with both docker and docker-compose commands.

The installation of Docker for Windows takes longer than it does on Linux platforms and may require a reboot. It is recommended that you install Docker for Windows before attending the lab.

# Author

michael.mayer@hpe.com

<!-- TOC -->

- [Docker Lab - Windows 10](#docker-lab---windows-10)
- [Goal](#goal)
- [Author](#author)
- [Creating text files.](#creating-text-files)
- [Environment setup](#environment-setup)
    - [Proxy consideration](#proxy-consideration)
    - [Software installation](#software-installation)
        - [Enable Virtualization instruction set](#enable-virtualization-instruction-set)
        - [Remove Virtualization software](#remove-virtualization-software)
        - [Enable HyperV](#enable-hyperv)
    - [Install Docker for Windows](#install-docker-for-windows)
    - [Docker configuration](#docker-configuration)
        - [Docker VM Memory Assignment](#docker-vm-memory-assignment)
        - [Enable Corporate network proxy](#enable-corporate-network-proxy)
        - [Enable HPE Docker repository](#enable-hpe-docker-repository)
        - [Check Installation](#check-installation)
- [Using Docker](#using-docker)
- [ownCloud containers](#owncloud-containers)
    - [Build warnings](#build-warnings)
    - [Running bare Apache container.](#running-bare-apache-container)
        - [Workaround for port 80 problems](#workaround-for-port-80-problems)
    - [Basic ownCloud container](#basic-owncloud-container)
    - [ownCloud container using local archive](#owncloud-container-using-local-archive)
        - [ownCloud download](#owncloud-download)
        - [Dockerfile](#dockerfile)
    - [ownCloud container with host volume](#owncloud-container-with-host-volume)
        - [Preparation](#preparation)
        - [Implementation](#implementation)
- [Docker-Compose](#docker-compose)
    - [First compose file](#first-compose-file)
    - [Going further docker-compose](#going-further-docker-compose)
- [Further exercises](#further-exercises)

<!-- /TOC -->

# Creating text files.

At various points in the lab, the instructions make use of the *IX here command pattern (e.g. "**cat > fileToCreate << EOF**").
You can directly replace this with Windows command redirection at the Command prompt. The following example shows how to create a plain text file using CMD redirection and then how to check the content of the file you created.

```
C:\Users\labuser>  >fileToCreate (
More? echo Text line 1
More? echo Text line 2
More? )
C:\Users\labuser>type fileToCreate
Text line 1
Text line 2
C:\Users\labtest>
```

While it is possible to work in this manner, it is easier to create text files using a text editor (e.g. Notepad or Notepad++ or Atom). If you choose to use Notepad, remember that it adds a ".txt" file extension to all files it creates so you will have to rename the file you have created to discard the filename extension.

# Environment setup
Estimated time: 45 minutes

## Proxy consideration

The course venue has direct access to the Internet and therefore there no need to use the corporate proxy. If you wish to use Docker for Windows within the corporate network, you will have to configure use of the network proxy. At this stage just obtain the details for the proxy and check connectivity.

1. Get the URL for the local proxy.
2. Check connectivity by running nslookup against the Fully Qualified Domain-name (FQDN) of the proxy.

## Software installation

The installation guide for Docker for Windows is at https://docs.docker.com/docker-for-windows/install/

### Enable Virtualization instruction set

Check that the Virtualization Instructions set for your CPU are enabled (open Task Manager, select the Performance tab and then examine the value in the Virtualization field).

If Virtualization is not enabled, you will have go into the BIOS/uEFI and enable it.

### Remove Virtualization software

If you have VMWare or VirtualBox products installed on your PC, I suggest that you remove the product before attempting to install Docker for Windows. I have seen reports of problems with HyperV if other Virtualization software are installed.

### Enable HyperV

Docker for Windows runs the containers in a HyperV VM. You therefore need to enable HyperV before installing Docker for Windows.

1. Open the Windows menu
2. Search for "Turn Windows features on or off"
3. When the Control Panel window appears, locate the checkbox for HyperV.
4. Select the HyperV checkbox.
5. Click the OK.
6. Accept the request to reboot the system.

## Install Docker for Windows

Follow the links on the installation page (see above) and download the MSI file. Run the virus checker on the MSI and then start it.

## Docker configuration

After Docker for Windows has been installed and the service is running (Docker icon is present in the taskbar), you may need to do some configuration.

Each of the following actions are atomic, so you will have to restart Docker once for each change you make.

### Docker VM Memory Assignment

Docker for Windows is conservative in quantity of RAM that it assigns to its HyperV VM. If you have more than 8GiB of RAM installed, you make wish to increase the RAM assigned to the Docker VM.

The steps to do this are:

1. Open the Docker context menu (right-click on the Dokcer icon in the taskbar).
2. Select the Settings menu item.
3. Select the Advanced tab and use the slider to increase the quantity of RAM assigned to the Docker VM.
4. Click the Apply button.
5. Wait for Docker to restart.

### Enable Corporate network proxy

As noted above, this step is only required when you use Docker for Windows on the corporate network. The steps are:

1. Open the Docker context menu (right-click on the Docker icon in the task-bar).
2. Select the Settings menu item.
3. Select the Proxies tab.
4. Check the "Manual Proxy configuration" radio button.
5. Enter the non-secure (http) URL for the network proxy in the "Web Server (HTTP)" field and the secure (https) URL for the network proxy in the "Secure Web Server (HTTPS)" field.
6. Enter "hpecorp.net" in the text field labelled "Bypass for these hosts and domains ...".
7. Click the Apply button.
8. Wait for Docker to restart.

### Enable HPE Docker repository

If you are using Docker for Windows within the corporate network you should use the corporate Docker repository.

1. Get the FQDN of the corporate repository.
2. Open the Docker context menu (right-click on the Docker icon in the taskbar).
3. Select the Settings menu item.
4. Select the Daemon tab.
5. Enter the FQDN for the corporate repository in the Registry Mirrors text field.
6. Click the Apply button.
7. Wait for Docker to restart.

### Check Installation

Open a CMD prompt. You can now run the Docker commands listed in the Lab document to test the installation.

# Using Docker

I had no problems running the Docker commands in the main lab document to create the first hello-world container.

02/2016 - I found that the latest Fedora image was not able to connect to its repositories when working on the corporate network. I encountered no problems when I created an Ubuntu container and modified the commands for Ubuntu. Here is the commands I used.

```
## Commands to create the Ubuntu container
docker search ubuntu
docker pull ubuntu
docker run -ti ubuntu /bin/bash

## Commands to run within the container
cat /etc/lsb-release
apt update
apt install -y wget
```

# ownCloud containers

I suggest that you delete Docker containers and images when you have finished with them. If you do not do this you will be left with redundant containers and images.


## Build warnings

When you build container image for a non-Windows guest on Windows, you will be presented with a security warning about default file permissions. This is not an issue while learning about Docker, but you should think about when working on anything more serious and most definitely before production use.

## Running bare Apache container.

The following Dockerfile for a container that includes a bare Apache instance is provided as assistance for those who are not attending a course.

```
FROM centos:6
RUN yum install -y httpd
MAINTAINER myself@mydomain.org
RUN cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf-ORIG
RUN echo "ServerName localhost:80" >> /etc/httpd/conf/httpd.conf
CMD /usr/sbin/apachectl -D FOREGROUND -k start
EXPOSE 80
```

### Workaround for port 80 problems

When I attempted to forward the localhost port 80 (default web server) to port 80 on the container, it was rejected with a permission problem. I tried disabling the IIS installation but found that there another Windows service running on the port. I decided that rather than keep modifying the Windows install, I would forward port 8080 (commonly used for proxies or secondary web servers) on localhost to the container.

The local port is set in the first field of the argument to the "-p" option of the "docker run" command. Here is an example of the workaround in use,

```
C:\Users\labtest>docker run -d -p 8080:80 d2b6d9f3c9a5
809a99671e44ab3c7862e24dff40071afb5c28650fd54634bd4f1e665bcd0275

C:\Users\labtest>docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                  NAMES
809a99671e44        d2b6d9f3c9a5        "/bin/sh -c '/usr/..."   About a minute ago   Up About a minute   0.0.0.0:8080->80/tcp   sharp_sammet

C:\Users\labtest>
```

If you have used this workaround, can access the default Apache page by navigating to the URL 'http://localhost:8080/' in your web browser.

## Basic ownCloud container

I encountered no problems creating and running a bare ownCloud container.

Here is an example Dockerfile for a ownCloud container.

```
FROM centos:6
RUN yum install -y httpd install php php-dom php-mbstring php-pdo php-gd
MAINTAINER myself@mydomain.org
RUN cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf-ORIG
RUN echo "ServerName localhost:80" >> /etc/httpd/conf/httpd.conf
CMD /usr/sbin/apachectl -D FOREGROUND -k start
RUN yum install -y tar bzip2
ADD http://labossi.hpintelco.net/owncloud-7.0.15.tar.bz2 /var/www/html/
RUN cd /var/www/html/ && tar xvfj owncloud-7.0.15.tar.bz2 && rm -f owncloud-7.0.15.tar.bz2
RUN chown -R apache:apache  /var/www/html/owncloud
EXPOSE 80
```

If you are using port 8080, the URL will be http://localhost:8080/owncloud.

## ownCloud container using local archive

### ownCloud download

The following one-line command replaces the wget command used to download the cwnCloud archive.

```
powershell Invoke-WebRequest -Uri http://labossi.hpintelco.net/owncloud-7.0.15.tar.bz2 -Outfile owncloud-7.0.15.tar.bz2
```

### Dockerfile

```
FROM centos:6
RUN yum install -y httpd install php php-dom php-mbstring php-pdo php-gd
MAINTAINER myself@mydomain.org
RUN cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf-ORIG
RUN echo "ServerName localhost:80" >> /etc/httpd/conf/httpd.conf
CMD /usr/sbin/apachectl -D FOREGROUND -k start
RUN yum install -y tar bzip2
# ADD http://labossi.hpintelco.net/owncloud-7.0.15.tar.bz2 /var/www/html/
COPY owncloud-7.0.15.tar.bz2 /var/www/html/
RUN cd /var/www/html/ && tar xvfj owncloud-7.0.15.tar.bz2 && rm -f owncloud-7.0.15.tar.bz2
RUN chown -R apache:apache  /var/www/html/owncloud
EXPOSE 80
```

## ownCloud container with host volume

### Preparation

Before you can make directories on the host available to any Docker containers, you will have to share the drive/s that contain the directories you wish to present.

You have to create network shares so that the Docker VM can access the host directories you wish to mount.

The process is:

* Open the context menu of the Docker icon on the Windows taskbar.
* Select the "Settings.." option.
* Select the "Shared Drives" tab.
* Select the radio button/s for the parent drive/s of the directories you wish to share.
* Click on the Apply button.
* You will be prompted for your password to confirm the creation of the network share.

You should remove the network share when you longer require it. I also suggest that at the same time you click on the "Reset credentials" link on the Sharing tab (Docker for Windows caches your credentials).

### Implementation

The following commands are a translation for the commands to create an example text file.

```
mkdir C:\Users\labtest\Data
date /t > C:\Users\labtest\Data\myfile.txt
time /t >> C:\Users\labtest\Data\myfile.txt
```

Here is an example Dockerfile that uses a host volume.

```
FROM centos:6
RUN yum install -y httpd install php php-dom php-mbstring php-pdo php-gd
MAINTAINER myself@mydomain.org
RUN cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf-ORIG
RUN echo "ServerName localhost:80" >> /etc/httpd/conf/httpd.conf
CMD /usr/sbin/apachectl -D FOREGROUND -k start
RUN yum install -y tar bzip2
# ADD http://labossi.hpintelco.net/owncloud-7.0.15.tar.bz2 /var/www/html/
COPY owncloud-7.0.15.tar.bz2 /var/www/html/
RUN cd /var/www/html/ && tar xfj owncloud-7.0.15.tar.bz2 && rm -f owncloud-7.0.15.tar.bz2
RUN chown -R apache:apache  /var/www/html/owncloud
EXPOSE 80
VOLUME /data
```

Here is an example of a Docker command to create a container that uses a directory on a Windows host. Note that the directory path must be fully qualified. I chose to quote the Windows directory path in order to avoid future problems with paths with embedded spaces.

```
docker run -d -p 8080:80 -v "C:\Users\labtest\Data":/data owncloud
```

When you configure ownCloud to use the /data volume, you will not be presented with the warning messages discussed in the main lab because the default file permissions for non-Windows guest operating systems are very open (as discussed above).


# Docker-Compose

There is no need to install docker-compose because Docker for Windows includes the current version of docker-compose.

## First compose file

Create a new directory and copy the Dockerfile and ownCloud archive into it.

Here is an example compose file.

```
version: '2'
services:
  web:
    build: .
    volumes:
      -  C:\Users\labtest\Data:/data
    ports:
      - "8080:80"
```

## Going further docker-compose

There should no need to make Windows specific changes to create and use a MariaDB container.

# Further exercises

It should be possible to convert the docker-machine exercise to use Azure. I have tried this.

I have not looked at either the Docker Swarm or the micro-service exercises. 
