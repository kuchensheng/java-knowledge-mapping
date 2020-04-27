# Java内存模型
Java线程之间的通信机制有两种：共享内存和消息传递。

在共享内存的并发模型里，线程之间共享程序的公共状态，通过写-读内存中的公共状态进行隐式通信。

在消息传递的并发模型里，线程之间没有公共状态，线程之间必须通过发送消息来显示进行通信。

**Java采用的是共享内存模型**，Java线程之间的通信总是隐式进行，整个通信过程对程序员完全透明。

## Java内存模型的抽象
在Java中，所有实例域、静态域和数组元素都存储在堆内存中，堆内存在线程之间共享。局部变量，方法定义参数和异常处理器参数（不会在线程之间共享，它们不会有内存可见性问题，也不受内存模型的影响。Java内存模型的抽象示意图：
![avatar](../imgs/JMM.png)

## 重排序
在执行程序时，为了提供性能，编译器和处理器常常会对指令做重排序。重排序分为3种：
1. 编译器优化的重排序
2. 指令级并行的重排序。现代处理器采用了指令级并行技术来讲多条指令重叠执行。如果不存在数据依赖性，处理器可以改变语句对应机器指令的执行顺序
3. 内存系统的重排序。由于处理器使用缓存的读/写缓冲区，这使得加载和存储操作看上去可能是在乱序执行。

![avatar](../imgs/serial.png).
对于处理器重排序，JMM的处理器重排序规则会要求Java编译器在生成指令序列时，插入特定类型的内存屏障指令，通过内存屏障指令来禁止特定类型的处理器重排序

**常见的处理器不允许对存在数据依赖的操作做重排序。**

为了保证内存可见性，Java编译器在生成指令序列的适当位置插入内存屏障指令来禁止特定类型的处理器重排序。

 内存屏障分类

 | 屏障类型 | 指令示例 | 说明 |
 | LoadLoad Barries| Load1;LoadLoad;Load2;|确保Load1数据的装载先于Load2及所有后续装载指定的装载|
 |StoreStore Barries | Store1；StoreStore；Store2|确保Store1数据对其他处理器可见（刷新到内存）先于Store2及所有后续存储指定的存储|
 |LoadStore Barries | Load1;LoadStore;Store2|确保Load1的数据装载先于Store2及其所有后续的存储指令刷新到内存|
 |StoreLoad Barries | Store1;StoreLoad;Load2|确保Store1数据对其他处理器变的可见（刷新道内存）先于Load2及其后续所有装载指令的装载。|

 StoreLoad Barries是一个全能型的屏障，它同时具有其他3个屏障的效果。现代的多处理器大多支持该屏障。执行该屏障的开下会很昂贵，因为当前处理器通常要把写缓冲区中的数据全部刷新到内存。
 ## happens-before简介
 JSR-133使用happens-before的概念来阐述操作之间的可见性。JMM中，如果一个操作执行的结果需要对另一个操作可见，那么这两个操作之间必须存在happens-before关系。happens-before规则如下：

 - 程序顺序规则：一个线程中的每个操作，happens-b于该线程中的任意后续操作
 - 监视器锁规则：对一个锁的解锁，happens-before于随后对这个锁的加锁
 - volatile变量规则：对一个volatile域的填写，happens-before于任意后续对这个volatile域的读写
 - 传递性：如果A happens-before B，且Bhappens-before C，那么A happens-before C。

### as-if-serial语义
 as-if-serial：不管怎么重排序，程序的执行结果不能给改变。编译器、处理器和runtime都必须遵守as-if-serial语义。

## 锁的内存语义
### 锁的释放-获取简历的happens-before关系
锁是Java并发编程中最重要的同步机制。锁除了让临界区互斥执行外，还可以让释放锁的线程向获取同一个锁的线程发送消息。借助ReentrantLock来解析锁的内存语义和具体实现
在ReentrantLock中，调用lock()方法获得锁，unlock方法释放锁
ReentrantLock的实现依赖于Java同步器AbstractQueueSynchronizer（AQS）。AQS使用一个整形的volatile变量来维护同步状态，
加锁时的代码
```java
protected final boolean tryAcquire(int acquires) {
	final Thread current = Thread.currentThread();
	//获得锁的开始，首先读取volatile变量state
	int c = getState();
	if (c == 0) {
		if (isFirst(current) && compareAndSetState(0,acquires)) {
			setExclusiveOwnerThread(current);
			return true;
		}
	}else if(current == getExclusiveOwnerThread) {
		int nextc = c + acquires;
		if (nextc < 0) {
			throw new Error("Maximum lock count exceeded");
		}
		setState(nextc);
		return true;
	}
	return false;
}

protected final boolean tryRelease(int releases) {
	int c = getState() - releases;
	if (Thread.currentThread() != getExclusiveOwnerThread())
		throw new IllegalMonitorStateException();
	boolean free = false;
	if (c == 0) {
		free = true;
		setExclusiveOwnerThread(null);
	}
	setState(c);　　　　　// 释放锁的最后，写volatile变量state
	return free;
}
```
根据volatile的happens-before规则，释放锁的线程在写volatile变量之前可见的共享变量，在获取锁的线程读取同一个volatile变量后将立即变得对获取锁的线程可见。

## happens-before
happens-before关系的定义如下：
+ 如果一个操作happens-before另一个操作，那么第一个操作的执行结果将对第二个操作可见，而且第一个操作的执行顺序排在第二个操作之前。
+ 两个操作之间存在happens-before关系，并不意味着Java平台的具体实现必须要按照happens-before关系指定的顺序来执行。如果重排序之后的执行结果，与按happens-before关系来执行的结果一致，那么这种重排序并不非法

JMM其实是在遵循一个基本原则：只要不改变程序的执行结果（指的是单线程程序和正确同步的多线程程序），编译器和处理器怎么优化都行
