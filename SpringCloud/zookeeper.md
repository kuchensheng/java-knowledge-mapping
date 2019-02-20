# Zookeeper介绍
Apache Zookeeper提供了统一命名服务、配置管理、分布式锁等分布式基础服务。它是分布式系统中的协调系统，可提供的服务主要有：配置服务、名字服务、分布式同步、组服务等
# Zookeeper特点
+ 简单

Zookeeper的核心是一个精简的文件系统，它支持一些简单的操作和一些抽象操作，例如，排序和通知。

+ 丰富

Zookeeper的基本操作是一组丰富的“构件”，可用于实现多种协调数据结构和协议。例如：分布式队列、分布式锁和一组同级别节点中的“领导者选举”

+ 高可靠性

Zookeeper支持集群模式，可以很容易的解决单点故障问题。

# Zookeeper安装
这里不再赘述
# Zookeeper中的组成员关系
Zookeeper的数据存储采用的是结构化存储，结构化存储是没有文件和目录的概念，里边的目录和文件被抽象成了节点（node），zookeeper里可以称为znode。Znode的层次结构如下图：

![Zookeeper中的znode](https://images0.cnblogs.com/blog/562023/201411/161806258225888.png)

# ZkClinet使用介绍

## ZkClient的API

|方法|参数描述|方法说明|
| ----- | ----- | ----- |
|ZkClient(String serverstring)|serverstring的格式为host1:port1,host2:port2组成的字符串| |
|ZkClient(String zkServers, int connectionTimeout)|connectionTimeout创建连接的超时时间，单位为秒| |
|ZkClient(String zkServers, int sessionTimeout, int connectionTimeout)|sessionTimeout 会话超时时间，单位是秒| |
|ZkClient(String zkServers, int sessionTimeout, int connectionTimeout, ZkSerializer zkSerializer)|zkSerializer 自定义zk节点存储数据的序列化方式| |
|ZkClient(IZkConnection connection)|connection IZkConnection接口自定义实现| |
|ZkClient(IZkConnection connection, int connectionTimeout)|| |
|ZkClient(IZkConnection zkConnection, int connectionTimeout, ZkSerializer zkSerializer)|| |
|subscribeChildChanges(String path, IZkChildListener listener)||注册监听器listener，监听路径path下子节点的变化 |
|ZkClient(IZkConnection connection, int connectionTimeout)|| |
|ZkClient(IZkConnection connection, int connectionTimeout)|| |