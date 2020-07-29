# 1 Kubernetes简介
+ Kubernetes是一个全新的基于容器技术的分布式架构领先方案
+ 如果我们的系统设计遵循了Kubernetes的设计思想，那么与业务无关的此等代码或功能模块将从我们的实现中小时，我们不仅节省了不少于30%的开发成本，还可以将经历更加集中于业务本身
+ Kubernetes是一个开发的平台。不局限于开发语言，通过标准的TCP通信协议进行交互。无侵入
+ Kubernetes是一个完备的分布式系统支撑平台。具有完备的集群管理能力，包括多层次的安全防护和准入机制、多租户应用支撑能力、透明的服务注册和发现机制、内建的智能负载均衡器、强大的故障发现和自我修复能力、服务滚动升级和在线扩容能力、可扩展的资源自动调度机制，以及多粒度的资源配额管理能力。

# 2 Kubernetes特点
+ “一切以服务为中心，一切围绕服务运转”
+ 自动化。在Kubernetes的解决方案中，一个服务可以自我扩展、自我诊断，并且升级容易， 在收到服务扩容请求后，Kubernetes会触发调度流程，最终在选定的目标节点上启动相应数量的服务实例副本。这些服务实例副本在*启动成功*后会自动加入负载均衡器中并生效。
+ 定时巡查。确保每个服务的所有实例的可用性，确保服务实例*数量*始终保持为预期的数量，当它发现某个实例不可用时，会自动重启该实例或者在其他节点上重新调度、运行一个新实例。

# 3 为什么要用Kubernetes
**IT行业从来都是由新技术推动的。**

- 首先，可以“轻装上阵”开发复杂系统，一名架构师负责系统中的服务组件的架构建设，几名开发工程师负责业务代码开发，一名系统兼运维工程师负责Kubernetes的部署和运维。
- 其次，可以全面拥抱微服务架构。微服务架构的核心是将一个巨大的单体应用分解为很多小的互相连接的微服务，一个微服务可能由多个实例副本支撑，副本的数量可以随着系统的负荷变化进行调整。
- 再次，可以随时随地将系统整体“搬迁”到公有云上。
- 然后，Kubernetes内在的服务弹性扩容机制可以让我们轻松应对突发流量。通过快速扩容实现
- 最后，Kubernetes系统脚骨超强的横向扩容能力可以让我们的竞争力大大提升

# 4 Kubernetes基础知识
Kubernetes中，Service是分布式集群架构的核心，一个Service对象具有以下特征：
+ 拥有唯一指定的名称
+ 拥有一个虚拟IP（Cluster IP、Service IP或VIP）和端口号
+ 能够提供某种远程服务能力
+ 被映射到提供这种能力服务的一组容器应用上
http://mirrors.163.com/centos/6/os/x86_64/Packages/python-2.6.6-66.el6_8.x86_64.rpm
Service的进程目前都是基于Socket通信方式对外提供服务。
容器提供了强大的隔离能力，所以有必要把为Service提供服务的这组进程放入容器中进行隔离。为此Kubernetes设计了Pod对象，将每个服务进程都包装到对应的Pod中，使其成为在Pod中运行的一个容器。为了建立Service和Pod间的关联关系，Kubernetes首先给每个Pod都贴上了一个标签（Label），然后给相应的Service定义标签选择器（Label Selector）来解决Service和Pod的关联问题。

** Pod的简单介绍**

+ 首先，Pod运行在一个节点（Node）上，这个节点既可以是物理机，也可以是虚拟机，通常一个节点上运行几百个Pod；
+ 其次，每个Pod中都运行这一个特殊的被称为**Pause**的容器，其他容器则为业务容器，这些业务容器共享Pause容器的网络栈和Volume挂载卷。因此我们通常将密切相关的服务进程放入同一个Pod中。
+ 最后，需要注意的是，并不是每个Pod和它里面的运行的容器都能被映射到一个Service，只有提供服务的那组Pod才会被映射为一个服务。

在集群管理方面，Kubernetes将集群中的机器划分为**一个Master**和一些Node。在Master上运行着集权管理相关的一组进程*kubeapiserver、kube-controller-manager和kubescheduler*，这些进程实现了整个集群的资源管理、Pod调度、弹性伸缩、安全控制、系统监控和纠错等管理功能。**Node作为集群中的工作节点，运行真正的应用程序**，在Node上，Kubernetes管理的最小运行单元是Pod。在Node上运行着Kubernetes的*kubelet、kube-proxy服务进程*，这些进程负责Pod的创建、启动、监控、重启、销毁以及实现软件模式的负载均衡器。

在Kubernetes集群中，只需为需要扩容的Service关联的Pod创建一个RC（Replication Controller）来实现服务扩容和服务升级。在一个RC定义文件中包括以下3个关键信息。
- 目标Pod的定义
- 目标Pod需要运行的副本数量
- 要监控的目标Pod的标签

在创建好RC后，Kubernetes会通过在RC中定义的Label筛选出对应的Pod实例并实时监控其状态和数量，如果实例数量少于定义的副本数量，则会根据在RC中定义的Pod模板创建一个新的Pod，然后将此Pod调度到合适的Node上启动运行，直到Pod实例的数量达到预定目标。有了RC，服务扩容就变成了一个纯粹的简单数字游戏了，只需要修改RC的副本数量即可。

# 5 Kubernetes的基本概念和术语
Kubernetes中的大部分概念，如：Node、Pod、Replication Controller、Service都可以被看作一种资源对象，几乎所有资源对象都可以通过Kubernetes提供的kubectl工具执行增删改查等操作并将其保存在etcd中持久化存储。

## 5.1 Master
Kubernetes里的Master指的是集群控制节点，在每个Kubernetes集群里都需要有一个Master来负责整个集群的管理和控制，基本上**Kubernetes**里的所有控制命令都发给它，它负责具体的执行过程。Master通常会占据一个独立的服务器，主要原因是它太重要了，是整个集群的首脑，如果它宕机或者不可用，那么对集群内容器应用的管理都将失效。
Master运行的关键进程如下：
- Kubernetes API Server（kube-apiserver）：提供了HTTP Rest接口
- Kubernetes Controller Manager（kube-controller-manager）：Kubernetes里所有资源对象的自动化控制中心
- Kubernetes Scheduler(kube-scheduler)：负责资源调度（Pod调度）的进程
另外，在Master上通常还需要部署etcd服务，因为Kubernetes里的所有资源对象的数据都被保存在etcd中

## 5.2 Node
除了Master，Kubernetes集群中的其他机器被称为Node。当某个Node宕机时，其上的工作负载会被Master自动转移到其他节点上
Node运行的关键进程如下：
- kubelet：负责Pod对应的容器的创建、启停等任务
- kube-proxy：实现Kubernetes Service的通信与负载均衡机制
- Docker Engine（docker）：Docker引擎，负责本机的容器创建和管理工作。

```
//通过kubectl get nodes 查看集群中有多少node
[root@isys-dev test]# kubectl get nodes
NAME       STATUS     ROLES    AGE    VERSION
isys-dev   Ready      master   191d   v1.15.3
monitor    NotReady   <none>   112d   v1.15.3

//然后通过kubectl describe node <node_name>查看某个Node的详细信息
[root@isys-dev test]# kubectl describe node monitor
Name:               monitor //Node的名字
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64 //标签，key=value
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=monitor
                    kubernetes.io/os=linux
                    monitor-label=monitor-only
Annotations:        flannel.alpha.coreos.com/backend-data: {"VtepMAC":"1e:c2:6b:6b:51:10"} //注解，不能被当做选择器过滤器条件
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 10.30.30.200
                    kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Wed, 15 Jan 2020 17:29:23 +0800 //创建时间
Taints:             node.kubernetes.io/unreachable:NoExecute
                    key=monitor:NoSchedule
                    node.kubernetes.io/unreachable:NoSchedule
Unschedulable:      false
// Node当前状态：磁盘空间是否不足（DiskPressure）、内存是否不足（MemoryPressure），网络是否正常（NetworkUnavailable），PID资源是否充足（PIDPressure）。
// 在一切正常时设置Node为Ready状态(Ready=Ture)，表示健康。
Conditions:
  Type             Status    LastHeartbeatTime                 LastTransitionTime                Reason              Message
  ----             ------    -----------------                 ------------------                ------              -------
  MemoryPressure   False   Thu, 07 May 2020 10:27:15 +0800   Sun, 26 Apr 2020 16:27:28 +0800   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Thu, 07 May 2020 10:27:15 +0800   Sun, 26 Apr 2020 16:27:28 +0800   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Thu, 07 May 2020 10:27:15 +0800   Sun, 26 Apr 2020 16:27:28 +0800   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Thu, 07 May 2020 10:27:15 +0800   Sun, 26 Apr 2020 16:27:31 +0800   KubeletReady                 kubelet is posting ready status

// Node主机地址与主机名
Addresses:
  InternalIP:  10.30.30.200
  Hostname:    monitor

// Node上的资源数量，包括：CPU、内存数量、最大可调度Pod数量
Capacity:
 cpu:                4
 ephemeral-storage:  50081904Ki
 hugepages-2Mi:      0
 memory:             8009256Ki
 pods:               110

// Node上的可调度数量，包括：CPU、内存数量、最大可调度Pod数量
Allocatable:
 cpu:                4
 ephemeral-storage:  46155482650
 hugepages-2Mi:      0
 memory:             7906856Ki
 pods:               110
//主机系统信息，包括主机ID、系统UUDI、Linux kernel版本号、操作系统类型与版本、Docker版本号、kubelet与kube-proxy的版本号等
System Info:
 Machine ID:                 ce4e8358122c404199fa9884f686d88d
 System UUID:                4CDC1E42-8F17-9CC7-5373-45D2CDD128C0
 Boot ID:                    4a534ff4-2d97-41c1-a77c-72a733dbc6b1
 Kernel Version:             3.10.0-957.el7.x86_64
 OS Image:                   CentOS Linux 7 (Core)
 Operating System:           linux
 Architecture:               amd64
 Container Runtime Version:  docker://19.3.5
 Kubelet Version:            v1.15.3
 Kube-Proxy Version:         v1.15.3

//当前运行的Pod列表概要信息
PodCIDR:                     10.244.2.0/24
Non-terminated Pods:         (8 in total)
  Namespace                  Name                              CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
  ---------                  ----                              ------------  ----------  ---------------  -------------  ---
  default                    alertmanager-68c68b48f8-s7pt5     100m (2%)     100m (2%)   200Mi (2%)       200Mi (2%)     56d
  default                    aliyundns-ops-67699bd5cb-xpm99    0 (0%)        0 (0%)      200Mi (2%)       600Mi (7%)     54d
  default                    centos                            0 (0%)        0 (0%)      0 (0%)           0 (0%)         83d
  default                    grafana6.0.0-5657695986-cm4b4     500m (12%)    500m (12%)  800Mi (10%)      800Mi (10%)    112d
  default                    prometheus-7f6c87f864-h9gm8       0 (0%)        0 (0%)      4000Mi (51%)     7000Mi (90%)   106d
  kube-system                kube-flannel-ds-amd64-l5dgn       100m (2%)     100m (2%)   50Mi (0%)        50Mi (0%)      112d
  kube-system                kube-proxy-r5zkw                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         112d
  monitoring                 node-exporter-tsp7j               112m (2%)     270m (6%)   200Mi (2%)       220Mi (2%)     112d

//已分配的资源使用概要信息，资源申请的最低、最大允许使用量占系统总量的百分比
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests      Limits
  --------           --------      ------
  cpu                812m (20%)    970m (24%)
  memory             5450Mi (70%)  8870Mi (114%)
  ephemeral-storage  0 (0%)        0 (0%)
Events: 
```

## 5.3 Pod
Pod是Kubernetes最重要的基本概念，每个Pod都有一个特殊的根容器-**Pause容器**。Pause容器的状态代表了整个容器组的状态。Pod里的多个业务容器共享Pause容器的IP，共享Pause容器挂载的Volume，解决了密切关联的业务容器之间的通信问题，也解决了他们之间的文件共享问题。
Pod资源定义文件：
```
apiVersion: v1
kind: Pod
metadata:
	name: myweb
	labels:
		name: myweb
spec:
	containers:
	- name: myweb
	  image: kubeguide/tomcat-app:v1
	  ports:
	  - containerPort:8080
	  env:
	  - name: MYSQL_SERVICE_HOST
	    value: 'mysql'
	  - name: MYSQL_SERVICE_PORT
	    value: '3306'
```
Kind为Pod表明这是一个Pod的定义
metadata里的name为Pod的名称
metadata里定义资源对象的标签
在Pod里包含的容器组的定义则在**spec**一节中声明
Event是一个事件的记录，记录了事件的最早产生时间、最后重现时间、重复次数、发起者、类型以及导致此事件的原因等众多信息。Event通常会被关联到某个具体的资源对象上，是排查故障的重要参考信息。

每个Pod都可以对其能使用的服务器上的计算资源设置限额，当前可以设置限额的计算资源有**CPU和Memory**两种，其中CPU的资源单位为CPU（Core）的数量是一个绝对值而不是相对值。

对于绝大多数容器来说，一个CPU的资源配额相当大，所以在Kubernetes里通常以千分之一的CPU配额为最小单位，用m来表示，例如
**通常一个容器的CPU配额被定义为100~300m，即占用0.1~0.3个CPU**
在Kubernetes里，一个计算资源进行限额时需要设定以下两个参数：
- Requests:该资源的最小申请量，系统必须要求
- Limits：该资源最大允许使用量，不能被突破，当容器试图使用超过这个量的资源时，可能会被Kubernetes杀掉并重启。

## 5.4 Label
Label（标签）是Kubernetes系统中另外一个核心概念。一个Label是一个key=value的键值对，其中key与value由用户自己指定。Label可以被附加到各种资源对象上，例如Node、Pod、Service、RC等，一个资源对象可以定义任意数量的Label，同一个Label也可以被添加到任意数量的资源对象上。Label通常在资源对象定义时确定，也可以在对象创建后动态添加或者删除。

**我们可以通过给指定的资源对象捆绑一个或多个不同的Label来实现多维度的资源分组管理功能，以便灵活、方便地进行资源分配、调度、配置、部署等管理工作。例如，部署不同版本的应用到不同的环境中；监控和分析应用（日志记录、监控、告警）等。**

**给某个资源对象定义一个Label，就相当于给它打了一个标签，随后可以通过LabelSelector（标签选择器）查询和筛选拥有某些Label的资源对象，Kubernetes通过这种方式实现了类似SQL的简单又通用的对象查询机制。**

**可以通过多个Label Selector表达式的组合实现复杂的条件选择，多个表达式之间用“，”进行分隔即可，几个条件之间是“AND”的关系，即同时满足多个条件**

## 5.5 Replication Controller
简称RC。即声明某种Pod的副本数量在任意时刻都符合某个预期值，所以RC的定义包括如下几个部分。
◎　Pod期待的副本数量。

◎　用于筛选目标Pod的Label Selector。

◎　当Pod的副本数量小于预期数量时，用于创建新Pod的Pod模板（template）。

示例如下：
```
apiVersion: v1
kind: Replication Controller
metadata:
	name: frontend
spec:
	replicas: 1
	selector:
		tier: frontend
	template:
		metadata:
			labels:
				app: app-demo
				tier: frontend
		spec: 
			containers:
			- name: tomcat-demo
			  image:tomcat
			  imagePullPolicy: IfNotPresent
			  env:
			  - name: GET_HOSTS_FROM
			    value: dns
			  ports:
			  - containerPort: 80
```

在我们定义了一个RC并将其提交到Kubernetes集群中后，Master上的Controller Manager组件就得到通知，定期巡检系统中当前存活的目标Pod，并确保目标Pod实例的数量刚好等于此RC的期望值，如果有过多的Pod副本在运行，系统就会停掉一些Pod，否则系统会再自动创建一些Pod

**注意：**删除RC并不会影响通过该RC已创建好的Pod。为了删除所有Pod，可以设置replicas的值为0，然后更新该RC。另外，kubectl提供了stop和delete命令来一次性删除RC和RC控制的全部Pod。

应用升级时，通常会使用一个新的容器镜像版本替代旧版本。我们希望系统平滑升级，比如在当前系统中有10个对应的旧版本的Pod，则最佳的系统升级方式是旧版本的Pod每停止一个，就同时创建一个新版本的Pod，在整个升级过程中此消彼长，而运行中的Pod数量始终是10个，几分钟以后，当所有的Pod都已经是新版本时，系统升级完成。通过RC机制，Kubernetes很容易就实现了这种高级实用的特性，被称为“滚动升级”（Rolling Update）

Replica Set与RC当前的唯一区别是，Replica Sets支持基于集合的Label selector（Set-based selector），而RC只支持基于等式的Label Selector（equality-based selector），这使得Replica Set的功能更强。

我们当前很少单独使用Replica Set，它主要被Deployment这个更高层的资源对象所使用，从而形成一整套Pod创建、删除、更新的编排机制。我们在使用Deployment时，无须关心它是如何创建和维护Replica Set的，这一切都是自动发生的。

## 5.6 Deployment
Deployment用于更好地解决Pod的编排问题。为此Deployment在内部使用了ReplicaSet来实现目的，Deployment的典型使用场景：

- 创建一个Deployment对象来生成对应的Replica Set并完成Pod副本的创建。
- 检查Deployment的状态来看部署动作是否完成（Pod副本数量是否达到预期的值）
- 更新Deployment以创建新的Pod（比如镜像升级）
- 如果当前Deployment不稳定，则回滚到早先的一个Deployment版本 
- 暂停Deployment以便于一次性修改多个PodTemplateSpec的配置项，之后再恢复Deployment进行新的发布
- 扩展Deployment以对应高负载
- 查看Deployment的状态，以此作为发布是否成功的指标
- 清理不再需要的旧版本ReplicaSets。

```

```
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: isc-application-apply-service
  name: isc-application-apply-service
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: isc-application-apply-service
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      annotations:
        com.isyscore.restart/hash: v0.0.79
      creationTimestamp: null
      labels:
        app: isc-application-apply-service
    spec:
      containers:
      - env:
        - name: JAVA_OPTS
          value: -javaagent:/sidecar/agent/skywalking-agent.jar -Xms2g -Xmx2g -Xss256k
            -XX:ParallelGCThreads=5 -Dca-key-path=/home/isc-application-apply-service/caKey
            -Dskywalking.trace.ignore_path=/**/system/status,/eureka/apps/**
        - name: SW_AGENT_NAME
          value: isc-application-apply-service
        - name: SW_AGENT_COLLECTOR_BACKEND_SERVICES
          value: skywalking-oap-server.monitoring.svc.cluster.local:11800
        - name: SW_LOGGING_LEVEL
          value: ERROR
        image: 10.30.30.22:9080/development/isc-application-apply-service:f4fb4d
        imagePullPolicy: IfNotPresent
        name: isc-application-apply-service
        ports:
        - containerPort: 8879
          protocol: TCP
        resources:
          limits:
            memory: 3Gi
          requests:
            memory: 512Mi
        volumeMounts:
        - mountPath: /home/isc-application-apply-service/logs
          name: isc-application-apply-service-pvc
          subPath: isc-application-apply-sevice/logs
        - mountPath: /home/isc-application-apply-service/caKey
          name: docker-tls
        - mountPath: /home/isc-application-apply-service/nginx
          name: isc-application-apply-service-pvc
          subPath: isc-application-apply-sevice/nginx/conf.d
        - mountPath: /home/isc-application-apply-service/www
          name: isc-application-apply-service-pvc
          subPath: isc-application-apply-sevice/nginx/www
        - mountPath: /home/isc-application-apply-service/ibo
          name: isc-application-apply-service-pvc
          subPath: isc-application-apply-sevice/ibo
      imagePullSecrets:
      - name: regsecret
      initContainers:
      - command:
        - python3
        - /root/testport.py
        - common-eureka-service
        - "31201"
        image: 10.30.30.22:9080/library/alpine-curl:3.7
        imagePullPolicy: IfNotPresent
        name: check-eurake
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      - command:
        - python3
        - /root/testport.py
        - mysql-service
        - "3306"
        image: 10.30.30.22:9080/library/alpine-curl:3.7
        imagePullPolicy: IfNotPresent
        name: check-mysql
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      - command:
        - python3
        - /root/testport.py
        - redis-service
        - "6379"
        image: 10.30.30.22:9080/library/alpine-curl:3.7
        imagePullPolicy: IfNotPresent
        name: check-redis
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - name: isc-application-apply-service-pvc
        persistentVolumeClaim:
          claimName: common-pvc
      - name: docker-tls
        secret:
          defaultMode: 420
          secretName: docker-tls
```