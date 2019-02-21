# 分布式服务跟踪：Spring Cloud Sleuth
在微服务中，一个客户端发起的请求在后端系统中会经过多个不同的微服务调用来协同产生最后的结果，在复杂的微服务架构系统中，几乎每一个前端请求都会形成一条复杂的分布式服务调用链路，在每条链路中任何一个依赖服务出现延迟过高或错误的时候都有可能引起请求最后的失败。这时候，对于每个请求，全链路调用的跟踪就变得越来越重要，通过实现对请求调用的跟踪可以帮助我们快速发现错误根源以及监控分析每条链路上的性能瓶颈。
针对这种情况Spring Cloud Sleuth为微服务架构增加分布式服务跟踪的能力

# 实现跟踪
添加spring-cloud-starter-sleuth依赖即可。
```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
```

# 几个重要概念
## Span
span表示一个基本工作单元。例如，在一个新建span中发送一个RPC等同于发送一个回应请求给RPC，span通过一个64位ID唯一标识(SpanID)。trace以另一个64位ID表示，span还有其他数据信息，比如摘要、时间戳事件、关键值注释(tags)、span的ID、以及进度ID(通常是IP地址)。span在不断的启动和停止，同时记录了时间信息，当你创建了一个span，你必须在未来的某个时刻停止它。
## Trace
一系列spans组成的一个树状结构，例如，如果你正在跑一个分布式大数据工程，你可能需要创建一个trace。TraceID用来标识一条请求链路
## Annotation
用来及时记录一个事件的存在，一些核心annotations用来定义一个请求的开始和结束 
+ cs(Client Sent):客户端发起一个请求，这个annotion描述了这个span的开始
+ sr(Server Received):服务端获得请求并准备开始处理它，如果将其sr减去cs时间戳便可得到网络延迟
+ ss(Server Sent):注解表明请求处理的完成(当请求返回客户端)，如果ss减去sr时间戳便可得到服务端需要的处理请求时间
+ cr(Client Received):表明span的结束，客户端成功接收到服务端的回复，如果cr减去cs时间戳便可得到客户端从服务端获取回复的所有所需时间 

# 跟踪原理
分布式系统中的服务跟踪在理论上并不复杂，主要包括以下两点：
* 为了实现请求跟踪，当请求发送到分布式系统的入口端时，只需要服务跟踪框架为该请求创建一个唯一的跟踪标识（**TraceID**），同时在分布式系统内部流转的时候，框架始终保持传递该唯一标识，直到返回给请求方为止，这样我们就能将所有的请求过程的日志关联起来。
* 为了统计各处理单元的时间延迟，当请求到达个服务组件时，或是处理逻辑到达某个状态时，通过SpanId来标记它的开始、具体过程以及结束。

将span和trace在一个系统中的过程图形化如下图：

![sleuth](imgs/sleuth.png)

# 与ELK整合
[更多详情点击这里](https://www.cnblogs.com/duanxz/p/7552857.html)
