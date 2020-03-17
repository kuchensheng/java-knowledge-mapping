# 使用Dockerfile创建镜像
Dockerfile是一个文本格式的配置文件，用户可以使用Dockerfile来快速创建自定义的镜像。

# 1. 基本结构
Dockerfile由一行行命令语句组成，支持以#开头的注释行。

Dockerfile分为四部分：基础镜像信息、维护者信息、镜像操作指令和容器启动时指令。例如：

```
# This is dockerfile uses the ubuntu image
# VERSION 2 - EDITION 1
# Author:docker_user
# Command format: Instruction [arguments / command]..

# Base image to use,this must be set as the first line
FROM ubuntu

# Maintainer:docker_user <docker_user at email.com>(@docker_user)
MAINTAINER docker_user docker_user@email.com

# Commands to update the image
RUN echo "deb http://archive.ubuntu.com/ubuntu/ raring main universe" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Commands when create a new container
CMS /usr/sbin/nginx
```