# Netty入门
# Netty的核心组件
+ Channel

Java NIO的一个基本构造（表示一个实体的开放连接，如读写操作）。可以把Channel看作是传入（入站）或者传出（出站）数据的载体。

+ 回调

一个回调就是一个方法，一个指向已经被提供给另一个方法的方法的引用。这使得接收回调的方法可以在适当时候调用回调。

例如：当一个新的连接被建立时，ChannelHandler的channelActive()回调方法会被调用。

+ Future

Future提供了另一种在操作完成时通知应用程序的方式。这个对象是一个异步操作结果的占位符；它在未来的某个时刻完成，并提供结果的访问。Netty实现了自己的ChannelFuture，用于在执行异步操作的时候使用。**每个Netty的出站I/O操作都将会返回一个ChannelFuture；也就是说它们都不会阻塞**

+ 事件和ChannelHandler

Netty是一个网络编程框架，所以事件是按照它们与入站或出站数据流的相关性进行分类的。可能由入站数据或者相关的状态更改而触发：连接激活/失活、数据读取、用户事件、错误事件、打开/关闭远程节点的连接、将数据flush到套接字等。

# Netty示例
## EchoServer 服务引导类
```
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;

import java.net.InetSocketAddress;

/**
 * Desription:
 * 创建一个ServerBootStrap的实例以引导和绑定服务器
 * 创建并分配一个NIOEventLoopGroup实例以进行事件的处理，如接受新连接以及读/写数据
 * 指定服务器绑定的本地InetSocketAddress
 * 使用一个EchoServerHandler的实例初始化每一个新的Channel
 * 调用ServerBootStrap.bind()方法以绑定服务器
 * @author:Hui CreateDate:2018/10/21 23:27
 * version 1.0
 */
public class EchoNettyServer {
    private final int port;

    public EchoNettyServer(int port) {
        this.port = port;
    }

    public static void main(String[] args) throws Exception {
        if(args.length != 1) {
            System.err.println(
                    "Usage:"+EchoNettyServer.class.getSimpleName() +
                            "<port>"
            );

        }
        int port = Integer.parseInt(args[0]);
        new EchoNettyServer(port).start();
    }

    private void start() throws Exception{
        final EchoServerHandler serverHandler = new EchoServerHandler();

        //创建EventLoopGroup
        EventLoopGroup group = new NioEventLoopGroup();
        //创建ServerBootStrap
        ServerBootstrap bootstrap = new ServerBootstrap();

        try {
            bootstrap.group(group)
            		//指定所使用的NIO传输Channel
                    .channel(NioServerSocketChannel.class)
                    .localAddress(new InetSocketAddress(port))
                    /* ChannelInitializer的作用，当一个新的连接被接受时，将会创建一个新的Channel。
                     * 而ChannelInitializer将会把你的EchoServerHandler的实例添加到该Channel的ChannelPipeline中
                     * 这个ChannelHandler将会受到有关入站消息的通知
                     **/
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) throws Exception {
                        	//EchoServerHandler被标注为@Shareable，所以我们总是使用同样的实例
                            ch.pipeline().addLast(serverHandler);
                        }
                    });
            ChannelFuture future = bootstrap.bind().sync();
            future.channel().closeFuture().sync();
        } finally {
            group.shutdownGracefully().sync();
        }
    }
}
```

## EchoServerHandler 
因为Echo服务器会响应传入的消息，所以它需要实现ChannelInboundHandler接口，用来定义响应入站事件的方法。
ChannelInboundHandlerAdpter类提供了ChannelInboundHandler的默认实现，当程序只需要少量的ChannelInboundHandler的方法时可以继承此类实现。

```
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.util.CharsetUtil;

@ChannelHandler.Sharable //标示一个ChannelHandler可以被多个Channel安全地共享
public class EchoServerHandler extends ChannelHandlerAdapter {

	//对于每个传入的消息都要调用
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        // 获取channel消息
        ByteBuf in = (ByteBuf) msg;
        System.out.println("Server received:"+in.toString(CharsetUtil.UTF_8));
        ctx.write(in);
    }

    //通知ChannelInboundHandler最后一次对channelRead()的调用是当前批量读取中的最后一条
    @Override
    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
        ctx.writeAndFlush(Unpooled.EMPTY_BUFFER).addListener(ChannelFutureListener.CLOSE);
    }

    //在读取操作期间，有异常抛出会调用
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        cause.printStackTrace();
        ctx.close();
    }
}
```
## 客户端代码
```java
import io.netty.bootstrap.Bootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import java.net.InetSocketAddress;

public class EchoClient {
    private final String host;
    private final int port;

    public EchoClient(String host, int port) {
        this.host = host;
        this.port = port;
    }

    public static void main(String[] args) throws InterruptedException {
        if(args.length != 2) {
            System.err.println("Useage:"+EchoClient.class.getSimpleName()+"<host>:<port>");
            return;
        }

        String host = args[0];
        int port = Integer.parseInt(args[1]);
        new EchoClient(host,port).start();
    }

    private void start() throws InterruptedException {
        EventLoopGroup group = new NioEventLoopGroup();
        try {
            Bootstrap bootstrap = new Bootstrap();
            bootstrap.group(group)
                    .channel(NioSocketChannel.class)
                    .remoteAddress(new InetSocketAddress(host,port))
                    .handler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) throws Exception {
                            ch.pipeline().addLast(new EchoClientHandler());
                        }
                    });
            ChannelFuture future = bootstrap.connect().sync();
            future.channel().closeFuture().sync();
        } catch (InterruptedException e) {
            group.shutdownGracefully().sync();
        }
    }
}


import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.util.CharsetUtil;

public class EchoClientHandler extends SimpleChannelInboundHandler<ByteBuf> {

    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        ctx.writeAndFlush(Unpooled.copiedBuffer("Netty rocks!!", CharsetUtil.UTF_8));
    }

    @Override
    protected void messageReceived(ChannelHandlerContext ctx, ByteBuf msg) throws Exception {
        System.out.println("Client received:"+msg.toString(CharsetUtil.UTF_8));
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        cause.printStackTrace();
        ctx.close();
    }
}
```
