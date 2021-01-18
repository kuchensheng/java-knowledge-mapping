# 云原生之服务

## 服务是什么

将运行在一组 [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 上的应用程序公开为网络服务的抽象方法。

使用 Kubernetes，你无需修改应用程序即可使用不熟悉的服务发现机制。 Kubernetes 为 Pods 提供自己的 IP 地址，并为一组 Pod 提供相同的 DNS 名， 并且可以在它们之间进行负载均衡。

Pod RC 与Service的逻辑关系

![img](C:\Users\78721\AppData\Local\Temp\企业微信截图_16101648738073.png)

每个Pod都会提供一个单独的IP地址，而且每个Pod都提供了一个独立的Endpoint（Pod IP + ContainerPort）以被客户端访问，当多个Pod副本组成一个集群来提供服务，那么客户端如何来访问？

Kubernetes发明了一种很巧妙又影响深远的设计：Service没有共用一个负载均衡器的IP地址，每个Service都被分配了一个全局唯一的虚拟IP地址，这个虚拟IP被称为Cluster IP。这样一来，每个服务就变成了具备唯一IP地址的通信节点，服务调用就变成了最基础的TCP网络通信问题

运行在每个Node上的kubeproxy进程其实就是一个智能的软件负载均衡器，负责把对Service的请求转发到后端的某个Pod实例上，并在内部实现服务的负载均衡与会话保持机制。Kubernetes提供了两种负载分发策略：RoundRobin和SessionAffinity。

- RoundRobin：轮询模式，即轮询将请求转发到后端的Pod上
- SessionAffinity：基于客户端IP地址进行会话保持的模式

默认采用RoundRobin模式

。而Service一旦被创建，Kubernetes就会自动为它分配一个可用的Cluster IP，而且在Service的整个生命周期内，它的Cluster IP不会发生改变

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tomcate-service
spec:
  ports:
  - port: 8080
  selector:
    tier: frountend
```

查看endpoints命令信息

`kubectl get endpoints`

查看service详细信息

`kubect get svc tomcat-service -o yaml`

Service多端口。Service支持多个Endpoint，在存在多个Endpoint的情况下，要求每个Endpoint都定义一个**名称**来区分

## Service的概念及属性说明

通过创建Service，可以为一组具有相同功能的容器应用提供一个统一的入口地址，并且将请求负载分发到后端的各个容器应用上

各属性说明

| 属性名称                             | 取值类型 | 必选 | 描述                                                         |
| ------------------------------------ | -------- | ---- | ------------------------------------------------------------ |
| version                              | string   | 是   | v1                                                           |
| kind                                 | string   | 是   | Service                                                      |
| metadata                             | object   | 是   | 元数据                                                       |
| metadata.name                        | string   | 是   | Service名称                                                  |
| metadata.namespace                   | string   | 是   | 命名看空间，默认default                                      |
| metadata.labels[]                    | list     |      | 自定义标签                                                   |
| metadata.annotaition[]               | list     |      | 自定义注解                                                   |
| spec                                 | object   | 是   | 详细描述                                                     |
| spec.selector[]                      | list     | 是   | Label Selector配置，将选择具有指定Label标签的Pod作为管理范围 |
| spec.type                            | string   | 是   | Service类型，默认ClusterIP。<br>(1)ClusterIP：虚拟的服务IP地址，用于K8s集群内部访问<br>(2)NodePort：使用宿主机的端口，使能够访问各Node的外部客户端通过Node的IP地址和端口号就能访问服务<br>(3)LoadBalancer:使用外接负载均衡器完成到服务的负载分发，需要在spec.status.loadBalancer字段中指定外部负载均衡器的IP地址，并同时定义nodePort和clusterIP，用于公有云环境<br>(4)ExternalName:通过返回CNAME和值，可以将服务映射到externalName字段的内容，例如foo.bar.example.com。没有任何类型代理被创建 |
| spect.clusterIP                      | string   |      | 虚拟服务IP地址，若不指定，则系统自动分配，也可手工指定。设置为None表示创建Headless Service（不需要负载均衡） |
| spec.sessionAffinity                 | string   |      | 是否支持Session，默认为空                                    |
| spec.ports[]                         | list     |      | Service需要暴露的端口列表                                    |
| spec.ports[].name                    |          |      | 端口名称                                                     |
| spec.ports[].protocol                |          |      | 端口协议，支持TCP和UDP，默认TCP                              |
| spec.ports[].targetPort              |          |      | 需要转发到后端Pod的端口号                                    |
| spec.ports[].nodePort                |          |      | 映射到物理机的端口号                                         |
| Status                               | object   |      | 设置外部负载均衡器的地址                                     |
| status.loadBalancer                  | object   |      | 外部负载均衡器相关设置                                       |
| status.loadBalancer.ingress          | object   |      |                                                              |
| status.loadBalancer.ingress.ip       | string   |      |                                                              |
| status.loadBalancer.ingress.hostname | string   |      |                                                              |

## Service 的基本用法

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: isc-bap-service
  namespace: default
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      annotations:
        com.isyscore.restart/hash: v0.0.1
      labels:
        app: isc-bap-service
    spec:
      volumes:
        - name: isc-bap-service-pvc
          persistentVolumeClaim:
            claimName: common-pvc
        - configMap:
            defaultMode: 420
            items:
            - key: isc-bap-service-local-cm.yml
              path: application-default.yml
            name: isc-bap-service-local-cm
          name: isc-bap-service-cm
      initContainers:
      - name: check-redis
        image: 10.30.30.22:9080/library/alpine-curl:3.7
        command: ['python3','/root/testport.py','redis-service','26379']
      - name: check-mysql
        image: 10.30.30.22:9080/library/alpine-curl:3.7
        command: ['python3','/root/testport.py','mysql-service','23306']
      - name: check-ldap
        image: 10.30.30.22:9080/library/alpine-curl:3.7
        command: ['python3','/root/testport.py','openldap-service','20389']
      - name: check-eurake
        image: 10.30.30.22:9080/library/alpine-curl:3.7
        command: ['python3','/root/testport.py','common-eureka-service','31200']
      containers:
        - name: isc-bap-service
          image: isc-bap-service:v0.0.1
          imagePullPolicy: Always
          env:
          - name: JAVA_OPTS
            value: "-Xms128m -Xmx1g -Xss256k -Dproject.type=isc-os -Dproject.name=isc-bap-service -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:CMSInitiatingOccupancyFraction=80 -XX:+UseCMSInitiatingOccupancyOnly -verbose:gc -Xloggc:logs/gc.log -XX:+PrintGCDetails  -XX:+PrintGCDateStamps -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=log/heapdump.hprof"
          - name: CONFIG_ADDITIONAL_LOCATION
            value: "--spring.config.additional-location=./config/application-default.yml"
          - name: PROFILE_ACTIVE
            value: "--spring.profiles.active=default"
          volumeMounts:
            - mountPath: "/home/isc-bap-service/logs"
              name: isc-bap-service-pvc
              subPath: isc-bap-service/logs
            - mountPath: /home/isc-bap-service/config
              name: isc-bap-service-cm
          ports:
            - containerPort: 36300
          livenessProbe:
            httpGet:
              path: /api/bap/system/status
              port: 36300
              httpHeaders:
               - name:  X-Custom-Header
                 value: Awesome
            initialDelaySeconds: 300
            periodSeconds: 10
            timeoutSeconds: 2
          readinessProbe:
            httpGet:
              path: /api/bap/system/status
              port: 36300
              httpHeaders:
               - name:  X-Custom-Header
                 value: Awesome
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
          resources:
            limits:
              memory: "1Gi"
            requests:
              memory: "256Mi"
      imagePullSecrets:
      - name: regsecret
---
apiVersion: v1
kind: Service
metadata:
  name: isc-bap-service
  namespace: default
  labels:
    name: isc-bap-service
spec:
  type: NodePort
  ports:
  - name: isc-bap-service
    port: 36300
    targetPort: 36300
    protocol: TCP
    nodePort: 36300
  selector:
    app: isc-bap-service
```

直接通过Pod的IP地址和端口号可以访问到容器应用内的服务，但是Pod的IP地址是不可靠的，例如当Pod所在的Node发生故障时，Pod将被Kubernetes重新调度到另一个Node，Pod的IP地址将发生变化。更重要的是，如果容器应用本身是分布式的部署方式，通过多个实例共同提供服务，就需要在这些实例的前端设置一个负载均衡器来实现请求的分发。Kubernetes中的Service就是用于解决这些问题的核心组件。

### 创建service

通过命令创建service  

创建文件，webapp-test.yaml，内容和格式如下：

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: webapp-test
spec:
  replicas: 2
  template:
    metadata:
      name: webapp-test
      labels:
        app: webapp-test
    spec:
      containers:
      - name: webapp
        image: tomcat
        ports:
        - containerPort: 8080
```

创建rc

`kubectl create -f webapp-rc.yaml`

replicationcontroller/webapp-test created

获取PodIP

```text
[root@isyscore-basic78 ~]# kubectl get pods -l app=webapp-test -o yaml |grep podIP
          f:podIP: {}
          f:podIPs:
    podIP: 10.244.0.61
    podIPs:
          f:podIP: {}
          f:podIPs:
    podIP: 10.244.0.62
    podIPs:

```

创建rc完毕后，通过expose命令创建service

```text
[root@isyscore-basic78 ~]# kubectl expose rc webapp-test
service/webapp-test exposed
[root@isyscore-basic78 ~]# kubectl get svc |grep webapp
webapp-test                           ClusterIP   10.102.135.182   <none>        48080/TCP       18s

```

### 多端口Service

有时一个容器应用也可能提供多个端口的服务，那么在Service的定义中，可以设置多个端口对应到多个应用服务。

```
apiVersion: v1
kind: Service
metadata:
  name: emqx-service
  namespace: default
  labels:
    name: emqx-service
spec:
  type: NodePort
  ports:
  - name: emqx
    port: 21883
    targetPort: 1883
    protocol: TCP
    nodePort: 21883
  - name: emqx-manage
    port: 18083
    targetPort: 18083
    protocol: TCP
    nodePort: 18083
  - name: emqx-ws
    port: 28083
    targetPort: 8083
    protocol: TCP
    nodePort: 28083
  - name: emqx-internal-tcp
    port: 11883
    targetPort: 11883
    protocol: TCP
    nodePort: 11883
  - name: emqx-ssl
    nodePort: 28883
    port: 28883
    protocol: TCP
    targetPort: 8883
  selector:
    app: emqx
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: emqx
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: emqx
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: emqx
    spec:
      containers:
      - args:
        - /bin/sh
        - -c
        - \cp -f /opt/emqx/etc/emqx.conf.ori /opt/emqx/etc/emqx.conf; chown emqx:emqx /opt/emqx/data/mnesia && su -l emqx -p -c /usr/bin/start.sh
        image: 10.30.30.22:9080/library/emqx:v4.1.0
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          initialDelaySeconds: 60
          periodSeconds: 10
          successThreshold: 1
          tcpSocket:
            port: 1883
          timeoutSeconds: 2
        name: emqx
        ports:
        - containerPort: 1883
          protocol: TCP
        - containerPort: 18083
          protocol: TCP
        - containerPort: 8083
          protocol: TCP
        - containerPort: 11883
          protocol: TCP
        - containerPort: 28883
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          initialDelaySeconds: 15
          periodSeconds: 20
          successThreshold: 1
          tcpSocket:
            port: 1883
          timeoutSeconds: 2
        resources:
          limits:
            memory: 8Gi
          requests:
            memory: 256Mi
        securityContext:
          runAsUser: 0
        volumeMounts:
        - mountPath: /opt/emqx/etc/emqx.conf.ori
          name: emqx-cm
          subPath: emqx.conf.ori
        - mountPath: /opt/emqx/etc/acl.conf
          name: emqx-cm
          subPath: acl.conf
        - mountPath: /opt/emqx/etc/certs/key.pem
          name: emqx-cm
          subPath: key.pem
        - mountPath: /opt/emqx/etc/certs/cert.pem
          name: emqx-cm
          subPath: cert.pem
        - mountPath: /opt/emqx/data/loaded_plugins
          name: emqx-cm
          subPath: loaded_plugins
        - mountPath: /opt/emqx/etc/plugins/emqx_auth_mysql.conf
          name: emqx-cm
          subPath: emqx_auth_mysql.conf
      dnsPolicy: ClusterFirst
      imagePullSecrets:
      - name: regsecret
      restartPolicy: Always
      volumes:
      - name: emqx-pvc
        persistentVolumeClaim:
          claimName: common-pvc
      - configMap:
          defaultMode: 420
          items:
          - key: emqx_auth_mysql.conf
            path: emqx_auth_mysql.conf
          - key: acl.conf
            path: acl.conf
          - key: cert.pem
            path: cert.pem
          - key: emqx.conf
            path: emqx.conf.ori
          - key: key.pem
            path: key.pem
          - key: loaded_plugins
            path: loaded_plugins
          name: emqx-cm
        name: emqx-cm
```

### 外部服务Service

在某些环境中，应用系统需要将一个外部数据库作为后端服务进行连接，或将另一个集群或Namespace中的服务作为服务的后端，这时可以通过创建一个无Label Selector的Service来实现

```yaml
apiVersion: v1
kind: Service
metadata: 
  name: my-service
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

通过该定义创建的一个**不带标签选择器**的service，即无法选择后端的Pod，系统不会自动创建EndPoint，因此需要**手动创建**一个和该Service**同名**的Endpoint，用于指向实际的后端访问地址。创建EndPoint的配置文件如下：

```yaml
kind: Endpoints
apiVersion: v1
metadata:
  name: my-service
subsets:
- address:
  - IP: 1.2.3.4
  ports:
  - port: 80
```

其架构如下：

![kubernetes-service-4](E:\githubProject\java-knowledge-mapping\imgs\kubernetes-service-4.png)

### 无头服务（Headless Service）

开发人员希望自己控制负载均衡策略，不使用Service提供的默认负载均衡策略的功能，或应用程序希望知道属于同组服务的其他实例。Kubernetes提供了Headless Service来实现这种功能。不为Service设置ClusterIP（入口IP），仅通过Label Selector将后端的Pod列表返回给调用的客户端

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
  clusterIP: None
  selector:
    app: nginx
```

这样，Service就不再具有一个特定的ClusterIP地址，对其进行访问将获得包含Label“app=nginx”的全部Pod列表,然后客户端程序自行决定如何处理这个Pod列表。这为类似于StatefulSet部署的提供了LoadBalance基础

一般“去中心化”类的应用集群比较适用HeadLess Service。

## 从集群外部访问Pod或Service

Pod和Service都是Kubernetes内部的概念，如何让外部访问这个服务，可以将Pod或Service端口号映射到宿主机来实现。

### 将容器应用的端口号映射到物理机(一般不建议)

1. 通过设置容器级别的hostPort，将容器应用的端口号映射到物理机上

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  containers:
  - name: webapp
    image: tomcat
    ports:
    - containerPort: 80
      hostPort: 8081
```

2. 通过设置Pod级别的hostNetwork=true，将该Pod中所有容器的端口号都被直接映射到物理机上。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  hostNetwork: true
  containers:
  - name: webapp
    image: tomcat
    ports:
    - containerPort: 80
```

### 将Service的端口号映射到物理机

1. 通过设置nodePort映射到物理机，同时设置Service的类型为NodePort。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 80801
  selector:
    app: webapp
```

2. 通过设置LoadBalancer映射到云服务商提供的LoadBalander地址，这种做法可维护性差，一般不建议

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  containers:
  - name: webapp
    image: tomcat
    ports:
    - containerPort: 80
      port: 80
      targetPort: 9376
      nodePort: 30061
      protocol: TCP
    clusterIP: 10.0.171.239
    type: LoadBalancer
  status:
    loadBalancer:
      ingress:
      - ip: 14.148.47.155
```

## CoreDNS说明

CoreDNS的主要功能是通过插件系统实现的。CoreDNS实现了一种链式插件结构，将DNS的逻辑抽象成了一个个插件，能够灵活组合使用。架构如下：

![kubernetes-service-5](E:\githubProject\java-knowledge-mapping\imgs\kubernetes-service-5.png)

常用的插件如下。
◎　loadbalance：提供基于DNS的负载均衡功能。
◎　loop：检测在DNS解析过程中出现的简单循环问题。
◎　cache：提供前端缓存功能。
◎　health：对Endpoint进行健康检查。
◎　kubernetes：从Kubernetes中读取zone数据。
◎　etcd：从etcd读取zone数据，可以用于自定义域名记录。
◎　file：从RFC1035格式文件中读取zone数据。
◎　hosts：使用/etc/hosts文件或者其他文件读取zone数据，可以用于自定义域名记录。
◎　auto：从磁盘中自动加载区域文件。
◎　reload：定时自动重新加载Corefile配置文件的内容。
◎　forward：转发域名查询到上游DNS服务器。
◎　proxy：转发特定的域名查询到多个其他DNS服务器，同时提供到多个DNS服务器的负载均衡功能。
◎　prometheus：为Prometheus系统提供采集性能指标数据的URL。
◎　pprof：在URL路径/debug/pprof下提供运行时的性能数据。
◎　log：对DNS查询进行日志记录。
◎　errors：对错误信息进行日志记录。

### Pod级别的DNS

除了使用集群范围的DNS服务，Pod级别也可设置DNS的相关策略和配置。但很少使用，这里不再赘述

## 服务发现

在 Kubernetes 集群中，每个 Node 运行一个 `kube-proxy` 进程。 `kube-proxy` 负责为 Service 实现了一种 VIP（虚拟 IP）的形式，而不是 [`ExternalName`](https://kubernetes.io/zh/docs/concepts/services-networking/service/#externalname) 的形式。

服务发现有两种方式：

- userspace代理模式

这种模式，kube-proxy 会监视 Kubernetes 主控节点对 Service 对象和 Endpoints 对象的添加和移除操作。 对每个 Service，它会在本地 Node 上打开一个端口（随机选择）。 任何连接到“代理端口”的请求，都会被代理到 Service 的后端 `Pods` 中的某个上面（如 `Endpoints` 所报告的一样）。 使用哪个后端 Pod，是 kube-proxy 基于 `SessionAffinity` 来确定的。

最后，它配置 iptables 规则，捕获到达该 Service 的 `clusterIP`（是虚拟 IP） 和 `Port` 的请求，并重定向到代理端口，代理端口再代理请求到后端Pod。

默认情况下，用户空间模式下的 kube-proxy 通过轮转算法选择后端。

![services-userspace-overview](E:\githubProject\java-knowledge-mapping\imgs\services-userspace-overview.svg)

- iptables代理模式

这种模式，`kube-proxy` 会监视 Kubernetes 控制节点对 Service 对象和 Endpoints 对象的添加和移除。 对每个 Service，它会配置 iptables 规则，从而捕获到达该 Service 的 `clusterIP` 和端口的请求，进而将请求重定向到 Service 的一组后端中的某个 Pod 上面。 对于每个 Endpoints 对象，它也会配置 iptables 规则，这个规则会选择一个后端组合。

默认的策略是，kube-proxy 在 iptables 模式下随机选择一个后端。

![kubernetes-service-3](E:\githubProject\java-knowledge-mapping\imgs\kubernetes-service-3.png)

使用 iptables 处理流量具有较低的系统开销，因为流量由 Linux netfilter 处理， 而无需在用户空间和内核空间之间切换。 这种方法也可能更可靠。

- ipvs代理模式

在 `ipvs` 模式下，kube-proxy 监视 Kubernetes 服务和端点，调用 `netlink` 接口相应地创建 IPVS 规则， 并定期将 IPVS 规则与 Kubernetes 服务和端点同步。 该控制循环可确保IPVS 状态与所需状态匹配。访问服务时，IPVS 将流量定向到后端Pod之一。

IPVS代理模式基于类似于 iptables 模式的 netfilter 挂钩函数， 但是使用哈希表作为基础数据结构，并且在内核空间中工作。 这意味着，与 iptables 模式下的 kube-proxy 相比，IPVS 模式下的 kube-proxy 重定向通信的延迟要短，并且在同步代理规则时具有更好的性能。 与其他代理模式相比，IPVS 模式还支持更高的网络流量吞吐量。

IPVS 提供了更多选项来平衡后端 Pod 的流量。 这些是：

- `rr`：轮替（Round-Robin）
- `lc`：最少链接（Least Connection），即打开链接数量最少者优先
- `dh`：目标地址哈希（Destination Hashing）
- `sh`：源地址哈希（Source Hashing）
- `sed`：最短预期延迟（Shortest Expected Delay）
- `nq`：从不排队（Never Queue）

![services-ipvs-overview](E:\githubProject\java-knowledge-mapping\imgs\services-ipvs-overview.svg)

## Ingress:Http 7层路由机制

#### Ingress 是什么

[官方文档](https://kubernetes.io/zh/docs/concepts/services-networking/ingress/)对Ingress的定义如下：

Ingress 是对集群中服务的外部访问进行管理的 API 对象，典型的访问方式是 HTTP。

Ingress 可以提供负载均衡、SSL 终结和基于名称的虚拟托管

[Ingress](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#ingress-v1beta1-networking-k8s-io) 公开了从集群外部到集群内[服务](https://kubernetes.io/zh/docs/concepts/services-networking/service/)的 HTTP 和 HTTPS 路由。 流量路由由 Ingress 资源上定义的规则控制。

#### Ingress有什么用

对于基于HTTP的服务来说，不同的URL地址经常对应到不同的后端服务或者虚拟服务器，这些应用层的转发机制仅通过Kubernetes的Service机制是无法实现的。Kubernetes的Ingress资源对象，用于将不同URL的访问请求转发到后端不同的Service，以实现HTTP层的业务路由机制。Kubernetes使用了一个Ingress策略定义和一个具体的
Ingress Controller，两者结合并实现了一个完整的Ingress负载均衡器。一个所有流量都发到同一个Service的简单Ingress示例：

![Kubernetes-service-ingress](E:\githubProject\java-knowledge-mapping\imgs\Kubernetes-service-ingress.png)

使用了Ingress后能够实现的HTTP例子如下：

流量首先到达外部负载均衡器，这个负载均衡器是由我们自己部署的，然后转发到Ingress控制器的`Service`上，然后再转发到Ingress控制器的`Pod`上，通过Ingress控制器基于`Ingress`资源定义的规则将客户端请求流量直接转发至与`Service`对应的后端`Pod`上。这种转发机制会绕过`Service`，从而<u>省去了由`kube-proxy`实现的端口代理开销，Ingress规则需要由一个`Service`资源对象辅助识别相关的所有`Pod`资源。</u>

![Kubernetes-service-ingress-1](E:\githubProject\java-knowledge-mapping\imgs\Kubernetes-service-ingress-1.png)

### 如何创建Ingress

在定义Ingress策略之前，先部署Ingress Controller，以实现为所有后端Service提供一个统一的入口。

关于ingress的各字段含义，可以通过`kubectl explain ingress.spec`查看，结果如下：

```text
KIND:     Ingress
VERSION:  extensions/v1beta1

RESOURCE: spec <Object>

DESCRIPTION:
     Spec is the desired state of the Ingress. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

     IngressSpec describes the Ingress the user wishes to exist.

FIELDS:
   backend	<Object>
     A default backend capable of servicing requests that don't match any rule.
     At least one of 'backend' or 'rules' must be specified. This field is
     optional to allow the loadbalancer controller or defaulting logic to
     specify a global default.

   ingressClassName	<string>
     IngressClassName is the name of the IngressClass cluster resource. The
     associated IngressClass defines which controller will implement the
     resource. This replaces the deprecated `kubernetes.io/ingress.class`
     annotation. For backwards compatibility, when that annotation is set, it
     must be given precedence over this field. The controller may emit a warning
     if the field and annotation have different values. Implementations of this
     API should ignore Ingresses without a class specified. An IngressClass
     resource may be marked as default, which can be used to set a default value
     for this field. For more information, refer to the IngressClass
     documentation.

   rules	<[]Object>
     A list of host rules used to configure the Ingress. If unspecified, or no
     rule matches, all traffic is sent to the default backend.

   tls	<[]Object>
     TLS configuration. Currently the Ingress only supports a single TLS port,
     443. If multiple members of this list specify different hosts, they will be
     multiplexed on the same port according to the hostname specified through
     the SNI TLS extension, if the ingress controller fulfilling the ingress
     supports SNI.
```



```yaml
apiVersion: extensions:v1beta1
kind: DaemonSet
metadata:
  name: nginx-ingress-lb
  labels:
    name: nginx-ingress-lb
  namespace: kube-system
spec:
  template:
    metadata:
      labels:
      name: nginx-ingress-lb
      spec:
        terminationGracePeriodSecond: 60
        containers:
        - image: gcr.io/goole_containers/nginx-ingress-controller:0.9.0-beta.2
          name: nginx-ingress-lb
          readinessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
          livenessProbe:
            httpGet:
              path: /healthz
              port: 10254
              schema: HTTP
            initialDelaySeconds: 10
            timeoutSecond: 1
          ports:
          - containerPort: 80
            hostPort: 80
          - containerPort: 443
            hostPort: 443
          env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POS_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
           args:
           - /nginx-ingress-controller
           - --default-backed-service=${POD_NAMESPACE}/default-http-backend
```

当然还需要配置backend

这个backend服务用任何应用实现都可以，只要满足对根路径“/”的访问返回404应答，并且提供/healthz路径以使kubelet完成对它的健康检查

#### Ingress如何配

1. 主机名统配符

   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: ingress-wildcard-host
   spec:
     rules:
     - host: "foo.bar.com"
       http:
         paths:
         - pathType: Prefix
           path: "/api/sso"
           backend:
             service:
               name: isc-sso-service
               port:
                 number: 32200
          - pathType: Prefix
            path: "/api/core/platform"
            backend:
              service:
                name: isc-pivot-platform
                port:
                  number: 31700
   ```

   