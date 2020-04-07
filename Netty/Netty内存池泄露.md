# Netty内存池泄露
Netty针对ByteBuf的申请和释放采用池化技术，通过PooledByteBufAllocator可以创建基于内存池分配的ByteBuf对象，这样就避免了每次消息读写都申请和释放ByteBuf。
## Netty内存池泄露问题
业务路由分发模块使用Netty作为通信框架，负责协议消息的接入和路由转发，在功能测试时没有发现问题，转性能测试之后，运行一段时间就发现内存分配异常，服务端无法接收请求消息，系统吞吐量为0.
## Netty内存池工作机制
通过Pooled和Unpooled方式创建了ByteBuf，模拟请求消息的创建和释放，采用非内存池方式创建的ByteBuf
```java
static void unPoolTest() {
	//非内存池模式
	LocalDateTime beginTime = LocalDateTime.now();
	ByteBuf buf = null;
	int maxTimes = 10000000;
	for (int i = 0 ; i < maxTimes ; i ++ ) {
		buf = Unpooled.buffer(10 * 1024);
		buf.release();
	}
	System.out.println("EXecute" + maxTimes +" times cost time : " + (LocalDateTime.now.getNano() - beginTime.getNano());
}

static void poolTest() {
	//内存池模式
	PooledByteBufAllocator allocator = new PooledByteAllocator(false);
	LocalDateTime beginTime = LocalDateTime.now();
	int maxTimes = 10000000;
	for (int i = 0 ; i < maxTimes ; i ++ ) {
		buf = allocator.heapBuffer(10 * 1024);
		buf.release();
	}
	System.out.println("EXecute" + maxTimes +" times cost time : " + (LocalDateTime.now.getNano() - beginTime.getNano());
}

//性能差异较大
```
## 内存池工作原理分析
Netty的内存池整体上参照jemalloc实现，主要数据结构如下：
1. PooledArena：代表内存中一大块连续的区域，PoolArena由多个Chunk组成，每个Chunk由多个Page组成。为了提高并发性能，内存池中包含一组PooledArena。
2. PoolChunk：用来组织和管理多个Page的内存分配和释放，默认为16MB。
3. PoolSubpage：对于小于一个Page的内存，Netty在Page中完成分配。每个Page被切分为大小相等的多个存储块，存储块的大小由第一次申请的内存大小决定

内存的分配从PooledArena开始，一个PooledArena包含多个Chunk，Chunk具体负责内存的分配和回收