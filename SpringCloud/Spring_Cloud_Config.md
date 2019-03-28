# Spring Cloud Config 分布式配置中心

# 1. 简介

在分布式系统中，由于服务数量巨多，为了方便服务配置文件统一管理，实时更新，所以需要分布式配置中心组件。市面上开源的配置中心有很多，BAT每家都出过，360的QConf、淘宝的diamond、百度的disconf、阿里巴巴的Nacos都是解决这类问题。国外也有很多开源的配置中心Apache的Apache Commons Configuration、owner、cfg4j等等。在Spring Cloud中，有分布式配置中心组件spring cloud config ，它支持配置服务放在配置服务的内存中（即本地），也支持放在远程Git仓库中。在spring cloud config 组件中，分两个角色，一是config server，二是config client。

**Spring Cloud Config 服务端**特性：

* HTTP：HTTP请求为外部配置提供基于资源的API
* 属性值的加解密（对称加密和非对称加密）
* 通过使用@EnableConfigServer在Spring boot中快速嵌入
* 支持加入Eureka服务治理，以实现高可用

**Spring Cloud Config 客户端**特性：

* 绑定Config服务端，并使用远程的属性源初始化Spring环境
* 属性值的加解密
* 失败快速响应与重试
* 动态刷新配置

**Spring Cloud Config 缺点**：
1. config server的git的用户名/密码明文配置，如果节点服务较多，有造成服务泄露的危险
2. config server没有提供图形化界面。配置变更需要git来操作。使用不方便
3. config server的配置采用默认采用Git，其动态配置还需要配合Web Hook来完成
