# 了解Pod

本章内容：

+ Pod和容器的使用
+ 应用配置管理
+ Pod的控制和调度管理
+ Pod的升级和回滚
+ Pod的扩缩容机制

## Pod定义详解

Pod组成示意图

![微信截图_20210104102118](C:\Users\78721\Desktop\微信截图_20210104102118.png)

每个Pod都有一个特殊的，被称为“根容器”的Pause容器，Pause容器对应的镜像属于Kubernetes平台的一部分，除此之外，每个Pod还包含一个或多个紧密相关的用户业务容器

Pod里的多个业务容器共享Pause容器的IP，共享Pause容器挂接的Volume。这样即简化了密切相关的业务容器之间的通信问题，也很好地解决了他们之间的文件共享问题。不过一般而言，一个Pod里有多个业务容器的话，要考虑管理成本（扩缩容、灰度发布）

在Kubernetes里，一个Pod里的容器与另外主机上的Pod容器能够直接通信

Pod有两种类型：普通Pod和静态Pod（static Pod）。后者比较特殊，它并没有被存放在Kubernetes的etcd存储里，而是被存放在某个具体的Node的一个具体文件中，并且只在此Node上启动、运行。而普通的Pod一旦被创建，就会被放入etcd中存储，随后会被Kubernetes Master调度到某个具体的Node上进行绑定（Binding），随后该Pod被对应的Node上的kubelet进行实例化成一组相关的Docker容器并启动。在默认情况下，当Pod里的某个容器停止时，Kubernetes会自动检测到这个问题并重新启动这个Pod。

| 属性名称                                         | 取值类型 | 必选 | 取值说明                                                     |
| ------------------------------------------------ | -------- | ---- | ------------------------------------------------------------ |
| version                                          | string   | 是   | 版本号，例如v1                                               |
| kind                                             | string   | 是   | Pod                                                          |
| metedata                                         | Object   | 是   | 元数据                                                       |
| metedata.name                                    | string   | 是   | Pod的名称                                                    |
| metedata.namespace                               | string   | 是   | Pod所属命名空间，默认为default                               |
| metadata.labels[]                                | List     |      | 自定义标签列表                                               |
| metadata.anntation[]                             | List     |      | 自定义注解列表                                               |
| Spec                                             | Object   | 是   | Pod中容器的详细定义                                          |
| spec.containers[]                                | List     | 是   | Pod中的容器列表                                              |
| spec.containers[].name                           | string   | 是   | 容器名称                                                     |
| spec.containers[].image                          | string   | 是   | 容器的镜像名称                                               |
| spec.containers[].imagePullPolicy                | string   |      | 镜像拉取策略，可选值：Always、Never、IfNotPresent，默认值为Always。<br>(1) Always:表示每次都尝试重新拉取镜像<br>(2) IfNotPresend:表示如果本地有该镜像，则使用本地镜像，本地不存在时拉取镜像<br>(3)Never:表示仅使用本地镜像<br>另外，如果包含以下设置，系统将默认设置imagePullPolicy=Always，如：<br>(1) 不设置imagePullPolicy，也为指定镜像tag<br>(2) 不设置imagePullPolicy，镜像tag为latest<br>(3) 启用名为AlwaysPullImages的准入控制器 |
| spec.containers[].command[]                      | List     |      | 容器的启动命令列表，如果不指定，则使用镜像打包时使用的启动命令 |
| spec.containers[].args[]                         | List     |      | 容器的启动命令参数列表                                       |
| spec.containers[].workdingDir                    | string   |      | 容器的工作目录                                               |
| spec.containers[].volumeMounts[]                 | List     |      | 挂载到容器内部的配置存储卷配置                               |
| spec.containers[].volumeMounts[].name            | string   |      | 引用Pod定义的共享存储卷的名称，需要使用volumes[]部分定义的共享存储卷名称 |
| spec.containers[].volumeMounts[].mountPath       | string   |      | 存储卷在容器内Mount的绝对路径                                |
| spec.containers[].volumeMounts[].readOnly        | Boolean  |      | 是否为只读模式，默认为读写模式                               |
| spec.containers[].ports[]                        | List     |      | 容器需要暴露的端口号列表                                     |
| spec.containers[].ports[].name                   | string   |      | 端口名称                                                     |
| spec.containers[].ports[].containerPort          | Int      |      | 容器需要监听的端口号                                         |
| spec.containers[].ports[].hostPort               | Int      |      | 容器所在主机需要监听的端口号，默认与containerPort相同        |
| spec.containers[].ports[].protocal               | String   |      | 端口协议，支持TCP和UDP，默认TCP                              |
| spec.containers[].env[]                          | List     |      | 容器运行前需设置的环境变量列表                               |
| spec.containers[].env[].name                     | string   |      | 环境变量名称                                                 |
| spec.containers[].env[].value                    | string   |      | 环境变量的值                                                 |
| spec.containers[].resources                      | Object   |      | 资源限制和资源请求的设置                                     |
| spec.containers[].resources.limits               | Object   |      | 资源限制的设置                                               |
| spec.containers[].resources.limits.cpu           | string   |      | CPU限制，单位为core数                                        |
| spec.containers[].resources.limits.memory        | string   |      | 内存限制，党委可以诶MiB、GiB                                 |
| spec.containers[].resources.requests             | Object   |      | 资源限制的设置                                               |
| spec.containers[].resources.cpu                  | string   |      | 容器启动的初始可用数量                                       |
| spec.containers[].resources.request.memroy       | string   |      | 容器启动的初始可用数量                                       |
| spec.volumes[]                                   | List     |      | 在该Pod上定义的共享存储卷列表                                |
| spec.volumes[].name                              | string   |      | 共享存储卷的名称，spec.containers[].volumeMounts[].name将引用该名称。<br>Volume的类型包括：emptyDir、hostPath、secret、configMap、nfs等 |
| spec.volumes[].emptyDir                          | Object   |      | 表示与Pod同生命周期的一个临时目录                            |
| spec.volumes[].hostPath                          | Object   |      | 表示挂载Pod所在宿主机的目录，通过volumes[].hostPaht.path指定 |
| spec.volumes[].secret                            | Object   |      | 表示挂载集群预定义的secret对象到容器内部                     |
| spec.volumes[].configMap                         | Object   |      | 表示挂载集群预定义的configMap对象到容器内部                  |
| spec.volumes[].livenessProbe                     | Object   |      | 对Pod内各容器健康检查的设置，当探测无响应几次之后，系统将自动重启改容器，可以设置的方法包括：exec、httpGet和tcpSocket |
| spec.volumes[].livenessProbe.initialDelaySeconds | Number   |      | 容器启动完成后首次探测的时间                                 |
| spec.volumes[].livenessProbe.timeoutSeconds      | Number   |      | 对容器健康检查的探测等待响应的超时时间设置，默认为1s。如果超过，会被判定为不健康的容器，会被重启 |
| spec.volumes[].livenessProbe.periodSeconds       | Number   |      | 对容器健康检查的定期探测时间设置，默认10s一次                |
| spec.restartPolicy                               | String   |      | Pod的重启策略，可选值为Always\|OnFailure。默认Always。<br>（1）Always：Pod一旦终止运行，则无论容器是如何终止的，kubelet都将重启它<br>(2)OnFailure：只有Pod以非零退出码终止时，kubelet才会重启该容器。如果容器正常结束，则kubelet不会重启它 |
| spec.nodeSelector                                | Object   |      | 设置Node的Label，以key-value格式指定Pod将被调度到具有这些Label的Node上 |
| spec.imagePullSecrets                            | Object   |      | pull镜像时使用的Secret名称，以name：secretkey格式指定        |
| spec.hostNetwork                                 | Boolean  |      | 是否使用主机网络模式，默认为false，设置为true表示容器使用宿主机网络，不再使用Docker网桥，该Pod将无法在同一个宿主机上启动第二个副本 |

## Pod的基本用法

### pod查询

```text
kubectl get pod:获取namespace=default的pod列表
kubectl get pod -n test : 获取指定namespace的pod列表
kubectl get pod -A : 获取所有命名空间的pod列表
kubectl get pod | grep podId: grep过滤
kubectl get pod [[-A | -n namespace] [| grep name]
```

### pod创建

```yaml
## pod的定义文件frontend.yml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  containers:
  - name: frontend
    image: http://host:port/path
    env: 
    - name: GET_HOST_FROM
      value: test_env
    ports:
    - containerPort: 80
```

运行kubectl create命令创建该Pod

```
$ kubectl create -f frontend.yml
pod "frontend" created
```

###  查询单个pod的详细信息

```
kubectl describe pod podId
```

### pod删除

```text
kubelet delete pod podId
注意：这里删除pod，pod会重启
```

##  静态Pod

静态Pod是由kubelet进行管理的仅存在于特定Node上的Pod。它们不能通过API Server进行管理，无法与ReplicationController、Deployment或者DaemonSet进行关联，并且kubelet无法对它们进行健康检查。静态Pod总是由kubelet创建。

创建静态pod的两种方式：

- 配置文件方式

首先，需要设置kubelet的启动参数“--config”，指定kubelet需要监控的配置文件所在的目录，kubelet会定期扫描该目录，并根据该目录下的.yaml或.json文件进行创建操作。

- HTTP方式

通过设置kubelet的启动参数“--manifest-url”，kubelet将会定期从该URL地址下载Pod的定义文件，并以.yaml或.json文件的格式进行解析，然后创建Pod。其实现方式与配置文件方式是一致的。

## Pod容器共享volume

## Pod健康检查和服务可用性检查

Kubernetes对Pod的健康状态可以通过两类指针来检查：LivenessProbe和ReadinessProbe。

- LiveNessProbe探针：用于判断容器是否存活，如果LivenessProbe探针探测到容器不健康，则kubelet将杀掉该容器，并根据容器的重启策略做相对应的处理。

- ReadinessProbe探针：用于判断容器服务是否可用（Ready状态），达到Ready状态的Pod才可以接收请求。

## Pod调度

大多数情况下，我们会通过RC、Deployment、DaemonSet、Job等控制器来完成一组Pod副本的创建、调度及全生命周期的自动控制任务。

大多数情况下，我们希望Deployment创建的Pod副本被成功调度到集群中的任何一个可用节点上，而不关心具体会调度到哪个节点。但是在真实的生产环境中，却也存在一种需求：希望某种Pod的部分全部在指定的一个或一些节点上运行，比如希望MySQL的Pod调度到一个具有SSD磁盘的目标节点上，此时Pod模板中的NodeSelector属性就开始发挥作用了。

+ 将MySQL定向调度案例的事项方式可以分两步：
  - 把具有SSD磁盘的Node都打上自定义标签“disk=ssd”
  - 在Pod模板中设定NodeSelector的值为"disk:ssd"

在真实的生产环境中，还存在：

+ 不同Pod之间的亲和性。比如MySQL和Redis中间件不能被调度到同一个目标节点上，或者两种Pod必须调度到同一个Node上，这是`PodAffinity`要解决的问题
+ 有状态的调度。对于ZK、ES、MongoDB、Kafka等有状态集群，虽然集群中的每个Worker节点看起来都是相同的，但每个Worker节点都必须有明确的、不变的唯一ID（主机名或IP），这些节点的启动和停止次序通常有着严格的顺序。此外，由于集群需要持久化保存状态数据，所以集群中的Worker节点对应的Pod不管在哪个Node上恢复，都需要挂载原来的Volume，因此这个Pod还需要绑定具体的PV。这对这些复杂的需求，Kubernetes提供了`StatefulSet`这种特殊的副本控制器来解决问题。
+ 在每个Node上调度并且仅仅创建一个Pod副本。这种调度通常用于系统监控相关的Pod，比如日志采集、主机性能采集等进程需要被部署到集群中的每个节点，并且只能部署一个副本，这就是`DaemonSet`这种特殊Pod副本控制器所解决的问题
+ 对于批处理作业，需要创建多个Pod副本来协同工作，当这些副本都完成自己的任务时，整个批处理作业就结束了。这种Pod运行仅运行一次的特殊调度是`Job`所解决的问题，并继续延伸了定时作业调度控制器`CronJob`

```text
在RC等对象被删除后，他们所创建的Pod副本都会被删除，如果不希望这样做，可以通过--cascade参数来取消
kubectl delete replicaset my-repset --cascade=false
```

### Deployment或RC：全自动调度

Deployment或RC的主要功能之一就是自动部署一个容器应用的多份副本，以及持续监控副本的数量，在集群内始终维持用户指定的副本数量。

### NodeSelector：定向调度

需要将Pod调度到指定的一些Node上，可以通过Node的标签（Label）和Pod的nodeSelector属性相匹配，来达到定向调度的目的

（1）首先通过kubectl label命令给目标Node打上一些标签：

```
kubectl label nodes <node-name> <lable-key>=<lable-value>
```

（2）然后，在Pod的定义中加上nodeSelector的设置

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: redis
  labels:
    name: redis
spec:
  replicas: 1
  selecotr:
    name: redis
  template:
    metadata:
      labels:
        name: redis-master
    spec:
      containers:
      - name: master
        image: kubeguide/redis-master
        ports:
        - containerPort: 6379
      nodeSelecotr:
        zone: north
```

使用kubectl get pods -o wide 命令验证Pod所在的Node

```
[root@arch-master ~]# kubectl get pods -o wide
NAME                   READY   STATUS      RESTARTS   AGE     IP             NODE         
redis-6b5848597d-fdvb2 1/1     Running     1          49d     10.244.0.11    arch-master

```

NodeSelector通过标签的方式，简单实现了限制Pod所在节点的方法。

### NodeAffinity: Node亲和性调度

NodeAffinity意为Node亲和性的调度策略，是用于替换NodeSelector的全新调度策略。目前有两种节点亲和性表达。

+ RequiredDuringSchedulingIgnoredDuringExecution：必须满足指定的规则才可以调度Pod到Node上（功能与nodeSelector很像，但是使用的是不同的语法），相当于硬限制。
+ PreferredDuringSchedulingIgnoredDuringExecution：强调优先满足指定规则，调度器会尝试调度Pod到Node上，但并不强求，相当于软限制。多个优先级规则还可以设置权重（weight）值，以定义执行的先后顺序。

IgnoredDuringExecution的意思是：如果一个Pod所在的节点在Pod运行期间标签发生了变更，不再符合该Pod的节点亲和性需求，则系统将忽略Node上Label的变化，该Pod能继续在该节点运行。

### PodAffinity：Pod亲和与互斥调度策略

