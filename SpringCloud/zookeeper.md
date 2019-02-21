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

![Zookeeper中的znode](https://images0.cnblogs.com/blog/671563/201411/301534562152768.png)

* Znode 结构

ZooKeeper命名空间中的Znode，兼具文件和目录两种特点。既像文件一样维护着数据、元信息、ACL、时间戳等数据结构，又像目录一样可以作为路径标识的一部分。图中的每个节点称为一个Znode。 每个Znode由3部分组成:

① stat：此为状态信息, 描述该Znode的版本, 权限等信息

② data：与该Znode关联的数据

③ children：该Znode下的子节点

* 数据访问

ZooKeeper中的每个节点存储的数据要被**原子性的操作**。也就是说读操作将获取与节点相关的所有数据，写操作也将替换掉节点的所有数据。每一个节点都拥有自己的ACL(访问控制列表),这个列表规定了用户的权限，即限定了特定用户对目标节点可以执行的操作.

* 节点类型

ZooKeeper中的节点有两种，分别为临时节点和永久节点。节点的类型在创建时即被确定，并且不能改变。

① 临时节点：该节点的生命周期依赖于**创建它们的会话**。一旦会话(Session)结束，临时节点将被自动删除，当然可以也可以手动删除。虽然每个临时的Znode都会绑定到一个客户端会话，但他们对所有的客户端还是可见的。另外，ZooKeeper的**临时节点不允许拥有子节点。**

② 永久节点：该节点的生命周期不依赖于会话，并且只有在**客户端显示执行删除操作**的时候，他们才能被删除。

* Watch

客户端可以在节点上设置watch，我们称之为监视器。当**节点状态发生改变时(Znode的增、删、改)**将会触发watch所对应的操作。当watch被触发时，ZooKeeper将会向客户端发送且仅发送一条通知，因为watch只能被触发一次，这样可以减少网络流量。


# Zookeeper中的事件和状态
Zookeeper主要为了统一分布式系统中各个节点的工作状态，在资源冲突的情况下协调提供节点资源抢占，提供给每个节点了解集群所处状态的途径。这一切都依赖于zookeeper中的使劲监听和通知机制。

**事件和监听**构成了zookeeper客户端连接描述的两个维度。


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