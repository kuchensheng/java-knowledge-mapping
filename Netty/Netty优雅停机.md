# Netty优雅退出机制
强制将某个进程杀掉可能导致的问题：
1. 缓存中的数据尚未持久化到磁盘中，导致数据丢失
2. 正在进行文件的写操作，没有跟新完成，突然退出，导致文件损坏
3. 线程的消息队列中尚有接收到但还没来得及处理的消息，导致请求消息丢失
4. 数据库已完成操作，例如账户余额更新，准备应答消息给客户端时，消息尚在通信线程的发送队列中等待，进程强制退出导致应答消息没有返回给客户端
5. 句柄资源没有及时释放

## Java优雅退出机制
Java的优雅停机通常是通过注册JDK的ShutdownHook来实现，当系统接收到退出指令时，首先标记系统处于退出状态，不再接收新的消息，然后将积压的消息处理完毕，最后调用资源回收接口将资源销毁，各线程退出执行。
```java
Runtime.getRuntime().addShutdownHook(new Thread(() ->{
                    System.out.println("Shutdown Hook executor start...");
                    System.out.println("Netty NioEventLoopGroup shutdownGracefully...");
                    try {
                        TimeUnit.SECONDS.sleep(5);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println("ShutdownHook execute end...");
                },""));
                TimeUnit.SECONDS.sleep(7);
                System.exit(0);
```
除了注册ShutdownHook，还可以通过监听信号量并注册SignalHandler的方式实现优雅退出。

**优雅停机注意点**

1. ShutdownHook在某些情况下不会执行，例如JVM崩溃，无法接受信号量和 kill -9 pid等
2. 当存在多个ShutdownHook时，JVM无法保证它们的执行顺序
3. 在JVM关闭期间不能动态添加或者删除ShutdownHook
4. 不能在ShutdownHook中调用System.exit()，它会卡住JVM，导致进程无法退出。

## Netty优雅退出原理
Netty优雅退出总结起来有三大类操作：
1. 把NIO线程的状态位设置成ST_SHUTTING_DOWN，不再处理新的消息
2. 退出前的预处理操作：把发送队列中尚未发送或者正在发送的消息发送完
3. 资源的释放操作：所有Channel的释放，多路复用器的去注册和关闭，所有队列和定时任务的清空取消，最后是EventLoop线程的退出
Netty优雅退出的接口和总入口是EventLoopGroup，调用它的shutdownGracefully方法即可。
## Netty优雅退出原理
1. NioEventLoopGroup实际上是NioEventLoop线程组，它便利EvnetLoop数组，循环调用它们的shutdownGracefully方法。
2. NioEventLoop，调用NioEventLoop的shutdownGracefully方法，首先要修改线程状态位正在关闭状态，这里需要对线程状态进行并发保护（加锁）

