# EventLoop和线程模型
# 线程模型概述
线程模型指定了操作系统、编程语言、框架或者应用程序的上下文中的线程管理的关键信息。
# EventLoop接口
运行任务来处理在连接生命周期内发生的事件是任何网络框架的基本功能。与之相应的编程上的构造通常称为事件循环。Netty使用EventLoop接口来实现

```java
while(!terminated) {
	List<Runnable> readyEvents = blocUnitEventReady();
	for(Runnable ev : readyEvents) {
		ev.run();
	}
}
```

EventLoop的类层次结构

![eventLoop类层次结构](../imgs/netty_eventloop.png)

在这个模型中，一个EventLoop将由一个永远都不会改变的Thread驱动，同时任务可以直接提交给EventLoop实现，以实现立即执行或者调度执行。

# 任务调度
JDK采用“juc”包下的ScheduledExecutorService来实现任务调度。但是Netty是用EventLoop实现任务调度。

# EventLoop线程的分配
服务于Channel的I/O和事件的EventLoop包含在EventLoopGroup中，根据不同的传输实现，EventLoop的创建和分配也不同
 ## 1.异步传输
 异步传输实现只使用了少量的EventLoop（以及和它们相关联的Thread），而且在当前的线程模型中，他们可能会被多个Channel所共享。这使得可以通过尽可能少量的Thread来支撑大量的Channel，而不是每个Channel分配一个Thread。

 ![Netty_eventloop_channel](../imgs/netty_eventloop_channel.png)

 EventLoopGroup负责为每个新建的Channel分配一个EventLoop。在当前实现中，使用顺序循环的方式进行分配以获取一个均衡的分布，并且相同的EventLoop可能会被分配给多个Channel。

 一旦一个Channel被分配给一个EventLoop，它将在它的整个生命周期中都使用这个EventLoop。

 **PS**：正因为一个EventLoop通常被用于支撑多个Channel，所以对于所有相关联的Channel来说，ThreadLocal都将是一样的。这使得它对于实现状态追踪等功能来说是个糟糕的选择。

 ## 2. 阻塞传输
 这里每一个Channel都将被分配一个EventLoop

 ![Netty_eventloop_channel_1](../imgs/netty_eventloop_channel_1.png)