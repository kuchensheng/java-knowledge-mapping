# 1 Dubbo的总体架构设计
Dubbo的框架一共划分了10层
+ 服务接口层（Service）：实际业务逻辑相关，提供服务提供者和服务消费者的业务设计对应的接口和实现
+ 配置层（Config）：对外的配置接口，以ServiceConfig和ReferenceConfig为中心，可以直接创建一个对象，也可以通过Spring解析配置生成配置类对象
+ 服务代理层（Proxy）：服务接口的透明代理
+ 服务注册层（Registry）：封装服务的注册与发现，以URL为中心，扩展接口有RegistryFactory、Registry和RegistryService。可能没有注册中心，此时服务提供者直接暴露服务。
+ 集群层（Cluster）：封装多个提供者的路由及负载均衡，并桥接注册中心，以Invokerwer为中心，扩展为Cluster、Directory、Router和LoadBalance。将多个服务提供者组合为一个服务提供者，实现对服务消费者透明。
+ 监控层（Monitor）：RPC调用的次数和调用时间的监控，以Statistics为中心，扩展接口为MonitorFactory、Monitor和MonitorService
+ 远程调用层（Protocol）：封装RPC调用，以Invocation和Result为中心，扩展接口为Protocol、Invoker和Exporter。Protocol是服务域，它是Invoker暴露和引用的主要功能接口，负责Invoker的生命周期管理。Invoker是实体域，是Dubbo的核心模型。
+ 信息交换层（Exchange）：封装请求响应模型，同步转化为异步，以Request和Response为中心，扩展接口为Exchanger、ExchangeChannel、ExchangeClient和ExchangeServer。
+ 网络传输层（Transport）：抽象mina和netty为统一接口，以Message为中心，扩展接口为Channel、Transporter、Client、Server和Codec
+ 数据序列化层（Serialize）：工具类

# 2 Dubbo服务暴露过程
	简单总结为：具体服务到Invoker转化、Invoker转化为Exporter
	- ServiceBean实现ApplicationListener接口，监听容器加载完成事件ContextRefreshedEvent，开始export();
	- ServiceConfig#export() 会判断是否延迟暴露，如果是，则开启一个守护线程睡眠一段时间后，再暴露，否则直接暴露。
	- ServiceConfig#doExportUrls 执行loadRegistries()遍历注册中心，根据注册中心生成要发布的URL，遍历所有协议，为每个协议执行doExportUrlsFor1Protocol().
	- DubboProtocol类中export()方法调用了openServer()方法，再调用createServer()方法。在createServer()方法中通过server = Exchangers.bind(url,requestHandler)最终调用了NettyServer类中的doOpen方法完成服务暴露。
# 3 Dubbo服务引用