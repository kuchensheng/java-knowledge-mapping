# 1 为什么使用docker
1. Docker容器的启动可以在秒级实现，这比传统的虚拟机方式快的多
2. Docker对资源利用率高，一台主机上可以同时运行数千个Docker容器
3. 更快速的交付和部署
4. 更高效的虚拟化
5. 更轻松的迁移和扩展
6. 更简单的管理。

# 2 Docker镜像
 运行容器之前需要本地存在对应的镜像，如果镜像不存在本地，Docker会从镜像仓库下载
## 2.1 获取镜像
通过网址可以找到目标镜像：https://hub.docker.com/explore
可以使用**docker pull [registry/]imageName:tag**命令拉取镜像

## 2.2 查询镜像
利用**docker images**获取本地的镜像列表
利用**docker search**查询镜像
利用**docker remove**移除镜像

# 3 docker容器管理
## 3.1 启动容器
两种方式：基于镜像新建一个容器，另一个是将在终止状态的容器重新启动

删除和创建容器
```
docker run :Run a command in a new container

docker create 
docker start
docker restart
```
# 4 Docker中的网络功能
docker在安装时其实是安装了网络两端。在宿主机安装veth -> 虚拟网卡.在docker容器中安装eth0 网卡模块，进行通信。
## 4.1 查看网桥
brctl show 查看网桥
## 4.2 修改网段配置
cat /etc/docker/daemon.json添加内容“bip”:"ip/netmask"
## 4.3 外部访问容器
可以通过 -P或-p参数来指定端口映射。

# 5 数据卷
