# Java虚拟机实战
+ [概述](#概述)
+ [运行时数据区域](#运行时数据区域)
	- [Java虚拟机的内存结构](#Java虚拟机的内存结构)
	- [直接内存](#直接内存)
+ [对象分配的方式](#对象分配的方式)
+ [对象的访问](#对象的访问)
+ [垃圾收集器和内存分配策略](#垃圾收集器和内存分配策略)
	- [内存分配策略](#内存分配策略)
	- [垃圾收集算法](#垃圾收集算法)
+ [垃圾收集器](#垃圾收集器)
+ [理解GC日志](#理解GC日志)

## 概述
对于Java程序员来说，在虚拟机自动内存管理机制下，不再需要像C/C++程序开发程序员这样为内一个 new 操作去写对应的 delete/free 操作，不容易出现内存泄漏和内存溢出问题。正是因为 Java 程序员把内存控制权利交给 Java 虚拟机，一旦出现内存泄漏和溢出方面的问题，如果不了解虚拟机是怎样使用内存的，那么排查错误将会是一个非常艰巨的任务。
## 运行时数据区域
Java虚拟机在执行Java程序的过程中会把它管理的内存分为若干区域，这些区域有各自的用途，以及创建和销毁时间。
### Java虚拟机的内存结构

![Java虚拟机内存结构](https://oscimg.oschina.net/oscnet/22ed19bd1d5b59492f2e5c74202701668f5.jpg)
1.堆（Heap）是Java虚拟机所管理的内存中最大的一块。

Java堆是被所有线程共享的一块内存区域。几乎所有的对象实例都在这里分配内存。Java堆是垃圾收集器管理的主要区域。

Java堆还被细分为：新生代和老年代；再细一点还将新生代分为Eden空间、from survivor和To survivor。通常配置**Eden:S0:S1区域的内存比例是8:1:1**，新生代和老年代比例是**1:3**。

JDK1.8之前的堆内存示意图

![堆内存](imgs/JVM_Heap.jpg)

值得注意的是，在 JDK 1.8中移除整个永久代，取而代之的是一个叫元空间（Metaspace）的区域（永久代使用的是JVM的堆内存空间，而元空间使用的是物理内存，直接受到本机的物理内存限制）。

从内存分配角度来看，线程共享的Java堆可能分出多个线程私有的分配缓存区（Thread Local Allocation Buffer，TLAB）。

2.方法区

也是各个线程共享的内存区域，它用于存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据。

方法区也叫“永久区”，方法区在物理上也是不需要连续的，可以选择固定大小或者扩展的大小，还可以选择不实现垃圾收集，方法区的垃圾回收是比较少的，这就是方法区为什么被称为永久区的原因

方法区也是可以执行回收的，该区域主要是针对常量池和类型的卸载

方法区也规定当方法区无法满足内存分布的时候，将会抛出OutOfMemoryError异常

运行时常量池（Runtime Constant Pool）是方法区的一部分，常量池存放编译器生成的各种字面量和符号引用。当常量池无法再申请到内存时会抛出OutOfMemoryError异常。

**3.虚拟机栈是线程私有的**。

它的生命周期和线程相同。虚拟机栈描述的是**Java方法**执行的内存模型
在Java虚拟机规范中，对这个区域规定了两种异常状况：如果线程请求的栈深度（-Xss可调整栈大小）大于虚拟机所允许的深度，这个时候将会抛出StackOverFlowError异常，如果当Java虚拟机允许动态扩展虚拟机栈的时候，当扩展的时候没办法分配到内存的时候就会报OutOfMemoryError异常。

**4.本地方法栈**，与虚拟机栈基本相同，唯一的区别是虚拟机栈是执行Java方法的，本地方法栈则为虚拟机使用到的Native方法服务。与虚拟机一样会抛出Stack OverflowError和OutOfMemoryError异常。

**5.程序计数器**，是一块较小的内存空间，可以看作是当前线程所执行的字节码的行号指示器
此内存区域是Java虚拟机唯一没有规定任何OutOfMemoryError的区域。

#### 直接内存
直接内存并不是虚拟机运行时数据区的一部分，也不是虚拟机规范中定义的内存区域，但是这部分内存也被频繁地使用。而且也可能导致OutOfMemoryError异常出现。

JDK1.4中新加入的*NIO(New Input/Output)*类，引入了一种基于通道（Channel）与缓存区（Buffer）的 I/O 方式，它可以直接*使用Native函数库*直接分配堆外内存，然后通过一个存储在*Java堆中的DirectByteBuffer*对象作为这块内存的引用进行操作。这样就能在一些场景中显著提高性能，因为避免了在Java堆和Native堆之间来回复制数据。

直接内存的分配不会收到 Java 堆的限制，但是，既然是内存就会受到本机总内存大小以及处理器寻址空间的限制。

### 对象分配的方式
*	**new**一个对象，如果该对象很大（大数组对象），就直接分配到老年区，如果不是很大就分配带新生代的Eden区域。
当Eden区没有足够空间进行分配时，虚拟机将发起一次Minor GC（或者叫Yong GC）。
第一次GC的时候，会把Eden区域没有被回收的对象拷贝到**S0区域**

第二次内存回收的时候会把Eden区域没有被回收的对象和S0区域的对象拷贝到S1区域，并且清空S0区域。

再次内存回收的时候，会把Eden区域没有被回收的对象和S1区域的对象拷贝到S0区域，并且清空S1区域。

如果经过多次GC（默认15次），仍没有被回收的对象，将被移动到**老年代**

![对象创建](https://oscimg.oschina.net/oscnet/60e02d763275ab5aac0cafb52fdad4e8930.jpg)

### 对象的访问
我们的Java程序通过栈上的 reference 数据来操作堆上的具体对象。对象的访问方式有虚拟机实现而定，目前主流的访问方式有①使用句柄和②直接指针两种：
+ 句柄
如果使用句柄访问的话，那么Java堆中将会划分出一块内存来作为句柄池，reference中存储的就是对象的句柄地址，而句柄中包含了对象实例数据与类型数据各自的具体地址信息。

**好处**：reference中存储的是稳定的句柄地址，在对象被移动（垃圾收集时移动对象是非常普通的行为）时只会改变句柄中的实例数据指针而reference本身不需要修改。

![句柄访问对象的方式](https://oscimg.oschina.net/oscnet/eec23d92aee42f6ea5959374c31e5b53bd9.jpg)

+ 直接指针

如果使用直接指针访问，那么Java堆对象的布局中必须考虑如何放置类型数据的相关信息，而reference中存储的直接地址就是对象地址。

**好处**：速度更快，节省了一次指针定位的时间开销。**sun hotspot**虚拟机就是通过这种方式进行对象访问的。

![直接指针方式访问对象](imgs/point.jpg)

## 垃圾收集器和内存分配策略
### 内存分配策略
Java的自动内存管理主要是针对对象内存的回收和对象内存的分配。同时，Java自动内存管理最核心的功能是**堆内存**中对象的分配与回收.
JDK1.8之前的堆内存示意图
![堆内存](imgs/JVM_Heap.jpg)
#### 对象优先在Eden区分配
目前主流的垃圾收集器都会采用分代回收算法，因此需要将堆内存分为新生代和老年代，这样我们就可以根据各个年代的特点选择合适的垃圾收集算法。

大多数情况下，对象在新生代中 eden 区分配。当 eden 区没有足够空间进行分配时，虚拟机将发起一次Minor GC.

#### 大对象直接进入老年代
大对象就是需要大量连续内存空间的对象（比如：字符串、数组）。

为了避免为大对象分配内存时由于分配担保机制带来的复制而降低效率。
#### 长期存活的对象将进入老年代
如果对象在Eden出生并经过第一次 Minor GC后仍然能够存活，并且能被Survivor容纳的话，将被移动到Survivor空间中，并将对象年龄设为1。对象在Survivor中每熬过一次MinorGC,年龄就增加1岁，当它的年龄增加到一定程度（默认为15岁），就会被晋升到老年代中。对象晋升到老年代的年龄阈值，可以通过参数 -XX:MaxTenuringThreshold 来设置。
#### 空间分配担保
在发生Minor GC之前，虚拟机会先检查老年代最大可用的连续空间是否大于新生代所有对象总空间，如果这个条件成立，那么Minor GC可以确保是安全的。如果不成立，则虚拟机会查看HandlerPromotionFailure设置值是否允许担保失败，如果允许，那么会继续检查老年代最大可用的连续空间是否大于历次晋升到老年代对象的平均大小，如果大于，则尝试着进行一次Minor GC。如果小于，这时就要改为进行一次Full GC。

#### 如何判断对象是否已经死亡
堆中几乎放着所有的对象实例，对堆垃圾回收前的第一步就是要判断那些对象已经死亡（即不能再被任何途径使用的对象）。
**1.引用计数法**
给对象中添加一个引用计数器，每当有一个地方引用它，计数器就加1；当引用失效，计数器就减1；任何时候计数器为0的对象就是不可能再被使用的。

**这个方法实现简单，效率高，但是目前主流的虚拟机中并没有选择这个算法来管理内存，其最主要的原因是它很难解决对象之间相互循环引用的问题**.
```
public class ReferenceCountingGC {

    public Object instance = null;

    private static final int _1MB = 1024 * 1024;

    private byte[] bigSize = new byte[2 * _1MB];

    public static void testGC(){
        ReferenceCountingGC objA = new ReferenceCountingGC();
        ReferenceCountingGC objB = new ReferenceCountingGC();
        objA.instance = objB;
        objB.instance = objA;

        objA = null;
        objB = null;
        System.gc();
    }

    public static void main(String[] args) {
        testGC();
    }
}
```
执行结果
```
[GC (System.gc()) [PSYoungGen: 10859K->1784K(38400K)] 10859K->1792K(125952K), 0.0028838 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[Full GC (System.gc()) [PSYoungGen: 1784K->0K(38400K)] [ParOldGen: 8K->1693K(87552K)] 1792K->1693K(125952K), [Metaspace: 3498K->3498K(1056768K)], 0.0195677 secs] [Times: user=0.09 sys=0.01, real=0.02 secs] 
Heap
 PSYoungGen      total 38400K, used 333K [0x00000000d5d80000, 0x00000000d8800000, 0x0000000100000000)
  eden space 33280K, 1% used [0x00000000d5d80000,0x00000000d5dd34a8,0x00000000d7e00000)
  from space 5120K, 0% used [0x00000000d7e00000,0x00000000d7e00000,0x00000000d8300000)
  to   space 5120K, 0% used [0x00000000d8300000,0x00000000d8300000,0x00000000d8800000)
 ParOldGen       total 87552K, used 1693K [0x0000000081800000, 0x0000000086d80000, 0x00000000d5d80000)
  object space 87552K, 1% used [0x0000000081800000,0x00000000819a7698,0x0000000086d80000)
 Metaspace       used 3504K, capacity 4496K, committed 4864K, reserved 1056768K
  class space    used 378K, capacity 388K, committed 512K, reserved 1048576K
```
从运行结果中可以看到，GC日志中包含“1792K->1693K(125952K)”意味着虚拟机并没有因为这两个对象相互引用就不回收他们，这也从侧面说明虚拟机并不是通过引用计数算法来判断对象是否存活的。

**2.可达性分析算法**

这个算法的基本思想就是通过一系列的称为 “GC Roots” 的对象作为起点，从这些节点开始向下搜索，节点所走过的路径称为引用链，当一个对象到 GC Roots 没有任何引用链相连的话，则证明此对象是不可用的。
![可达性分析算法](imgs/Groot.jpg)

在Java语言中，可作为GC Roots的对象包括以下几种：
- 虚拟机栈中引用的对象
- 方法区中类静态属性引用的对象
- 方法区中常量引用的对象
- 本地方法栈中JNI引用的对象

**无论是通过引用计数算法还是可达性分析，判断对象是否存活都与“引用”有关。**

+ 强引用，在程序代码中普遍存在，例如Object o = new Object(),只要强引用还在，垃圾收集器则不会回收掉被引用的对象
+ 软引用，用来描述一些还有用但非必需的对象。对于软引用关联的对象，在系统将要发生内存溢出异常之前，将会把这些对象进行回收，如果这次回收后后还没有足够的内存，则会抛出内存溢出异常。SoftReference来实现软引用
+ 弱引用也是用来描述非必需的对象，但是它的强度比软引用更弱一些，被弱引用关联的对象只能生存到下一次垃圾收集发生之前。WeakReference来实现弱引用。
+ 虚引用，是最弱的一种引用关系。一个对象是否有虚引用的存在，完全不会对其生存时间构成影响。为一个对象设置虚引用的唯一目的是能在这个对象被收集器回收的时收到一个系统通知。PhantomReference来实现虚引用。

**3.不可达的对象并非“非死不可”**
即使在可达性分析法中不可达的对象，也并非是“非死不可”的，这时候它们暂时处于“缓刑阶段”，要真正宣告一个对象死亡，至少要经历两次标记过程；可达性分析法中不可达的对象被第一次标记并且进行一次筛选，筛选的条件是此对象是否有必要执行finalize方法。当对象没有覆盖finalize方法，或finalize方法已经被虚拟机调用过时，虚拟机将这两种情况视为没有必要执行。

被判定为需要执行的对象将会被放在一个队列中进行第二次标记，除非这个对象与引用链上的任何一个对象建立关联，否则就会被真的回收。

### 垃圾收集算法
常见的垃圾收集算法
+ 标记-清除法（mark-sweep）
+ 复制算法
+ 标记-整理算法
+ 分带收集算法

#### 标记-清除算法
最基础的收集算法是“标记-清除”算法，首先标记处所需要回收的对象，在标记完成后统一回收所有被标记的对象。
它的不足有两个：

效率问题，标记和清除两个过程的效率都不高

空间问题，标记和清除后会产生大量不连续的内存碎片，空间碎片太多可能会导致以后再程序运行过程中需要分配较大对象时，无法找到足够的连续内存而不得不提前触发一次垃圾收集动作。

![标记清除算法](https://oscimg.oschina.net/oscnet/98f7426402fc2f00270fafac2a1de4d7372.jpg)

#### 复制算法
为了解决效率问题，复制算法应运而生。它将**可用内存容量划分为大小相等的两块**，每次只使用其中的一块。当这一块的内存用完了，就将还存活着的对象复制到另外一块上面，然后再把已使用过的内存空间一次清理掉。这样就是对整个半区进行内存回收，内存分配时也不用考虑内存碎片等复杂情况。

它的不足：

内存使用率问题，这种算法的代价是将内存缩小为原来的一半。

![复制算法](https://oscimg.oschina.net/oscnet/0b160e526d661baa8534c4f196adf25415e.jpg)

现在的商业虚拟机都采用这种收集算法来回收新生代，IBM研究得出新生代将内存划分为为一块较大的Eden空间和两个较小的Survivor空间。当回收时，将Eden和survivor中还存活的对象一次性地复制到另外一个survivor空间上，最后清理掉Eden和刚才的额survivor空间。Hotspot虚拟机默认Eden和survivor的大小比例是8:1:1。当survivor空间不够用时，需要依赖年老代进行分配担保。也就是这些对象将通过分配担保机制进入年老代。

#### 标记-整理算法
根据老年代的特点特出的一种标记算法，标记过程仍然与“标记-清除”算法一样，但后续步骤不是直接对可回收对象回收，而是让所有存活的对象向一端移动，然后直接清理掉端边界以外的内存。
![标记整理算法](https://oscimg.oschina.net/oscnet/b93f031c096ea5386f3b260a49b839308c4.jpg)

#### 分代收集算法
当前虚拟机的垃圾收集都采用分代收集算法，这种算法没有什么新的思想，只是根据对象存活周期的不同将内存分为几块。一般将java堆分为新生代和老年代，这样我们就可以根据各个年代的特点选择合适的垃圾收集算法。

比如在新生代中，每次收集都会有大量对象死去，所以可以选择复制算法，只需要付出少量对象的复制成本就可以完成每次垃圾收集。而老年代的对象存活几率是比较高的，而且没有额外的空间对它进行分配担保，所以我们必须选择“标记-清除”或“标记-整理”算法进行垃圾收集。

### 垃圾收集器
+ Serial收集器
+ ParNew收集器
+ Parallel Scavenge收集器
+ GMS收集器
+ G1收集器

#### Serial收集器
Serial（串行）收集器收集器是最基本、历史最悠久的垃圾收集器了。大家看名字就知道这个收集器是一个单线程收集器了。它的 “单线程” 的意义不仅仅意味着它只会使用一条垃圾收集线程去完成垃圾收集工作，更重要的是它在进行垃圾收集工作的时候必须暂停其他所有的工作线程（ "Stop The World" ），直到它收集结束。

Serial收集器是虚拟机在Client模式下默认新生代收集。**新生代采用复制算法，老年代采用标记-整理算法**

![](https://camo.githubusercontent.com/aba41c5c08ea9884554b9a69ea69c7ceeebc83ff/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32372f34363837333032362e6a7067)

好处：简单而高效，对于限定的单个CPU的环境来说，Serial收集器由于没有线程交互的开销，效率更高。

#### ParNew收集器
ParNew收集器其实就是Serial收集器的多线程版本，除了使用多线程进行垃圾收集外，其余行为（控制参数、收集算法、回收策略等等）和Serial收集器完全一样。
![](https://camo.githubusercontent.com/f298ba56ec4667487fdf4acc987f2ef9e6df254e/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32372f32323031383336382e6a7067)

#### Parallel Scavenge收集器
Parallel Scavenge收集器是一个**新生代收集器**，它是使用**复制算法的收集器**，又是**并行的多线程收集器**。

**特别之处**：它的目标是达到一个可控制的吞吐量（Throughput）。所谓吞吐量就是CPU用于运行用户代码的时间与CPU总消耗时间的比值，即**吞吐量 = 运行用户代码时间/（运行用户代码时间 + 垃圾收集时间）**，虚拟机总共运行了100分钟，其中垃圾收集时间花掉1分钟，那么吞吐量就是99%。

#### Serial Old收集器
Serial Old是Serial收集器的老年代版本，它同样是一个单线程收集器，使用“标记-整理算法那”。这个收集器的主要意义也是在于给Client模式下的虚拟机使用。

如果在Server模式下，那么它的主要用途有两个：

+ 在JDK1.5之前的版本中与Parallel Scavenge收集器搭配使用
+ 作为CMS收集器的后预备方案。在并发收集发生Concurrent Mode Failure时使用。

#### Parallel Old收集器
Parallel Scavenge收集器的老年代版本。使用多线程和“标记-整理”算法。在注重吞吐量以及CPU资源的场合，都可以优先考虑 Parallel Scavenge收集器和Parallel Old收集器。

#### CMS收集器
CMS（Concurrent Mark Sweep）收集器是一种以获取最短回收停顿时间为目标的收集器。它是基于“标记-清除”算法实现的。

它的运作过程比前面几种收集器来说更复杂，整个过程可分为4步：

* 初始标记（CMS initial mark）：仅仅是标记一下GC Roots能直接关联到的对象，速度快
* 并发标记（CMS concurrent mark）：GC Roots Tracing过程
* 重新标记（CMS remark）：修正并发标记期间因用户程序继续运作而导致标记发生变动的那一部分对象的标记记录。停顿时间比初始标记时间长，但是比并发标记时间短
* 并发清除（CMS concurrent sweep）：开启用户线程，同时GC线程开始对为标记的区域做清扫。

从它的名字就可以看出它是一款优秀的垃圾收集器，主要优点：并发收集、低停顿。但是它有下面三个明显的缺点：
+ 对CPU资源敏感；
+ 无法处理浮动垃圾；
+ 它使用的回收算法-“标记-清除”算法会导致收集结束时会有大量空间碎片产生。

#### G1收集器
G1 (Garbage-First)是一款面向服务器的垃圾收集器,主要针对配备多颗处理器及大容量内存的机器.以极高概率满足GC停顿时间要求的同时,还具备高吞吐量性能特征.它具备以下特点
+ 并发和并行：G1能充分利用多CPU、多核环境下的硬件优势，使用多个CPU来缩短Stop-The-World停顿的时间。
+ 分代收集：虽然G1可以不需要其他收集器配合就能独立管理整个GC堆，但是还是保留了分代的概念。
+ 空间整合：与CMS的“标记--清理”算法不同，G1从整体来看是基于“标记整理”算法实现的收集器；从局部上来看是基于“复制”算法实现的。
+ 可预测的停顿：这是G1相对于CMS的另一个大优势，降低停顿时间是G1 和 CMS 共同的关注点，但G1 除了追求低停顿外，还能建立可预测的停顿时间模型，能让使用者明确指定在一个长度为M毫秒的时间片段内。

## 理解GC日志
理解GC日志是处理Java虚拟机内存问题的基础技能。每一种收集器的日志形式都是由它们自身的实现所决定的。但也有一定的共性。
```
import java.util.ArrayList;
import java.util.List;

/**
 * @author Chensheng.Ku
 * @version 创建时间：2019/2/12 9:27
 */
public class ReferenceCountingGC {

    public Object instance = null;

    private static final int _1MB = 1024 * 1024;

    private byte[] bigSize = new byte[2 * _1MB];

    public static void testGC(){
        ReferenceCountingGC objA = new ReferenceCountingGC();
        ReferenceCountingGC objB = new ReferenceCountingGC();
        objA.instance = objB;
        objB.instance = objA;

        objA = null;
        objB = null;
        System.gc();
    }
    public static void testHeapGC(){
        List<ReferenceCountingGC> list = new ArrayList<>();
        while(true){
            list.add(new ReferenceCountingGC());
        }
    }

    public static void main(String[] args) {
        testHeapGC();
    }
}
```
运行结果
```
[GC (Allocation Failure) [PSYoungGen: 31343K->5094K(38400K)] 31343K->26345K(125952K), 0.0612702 secs] [Times: user=0.06 sys=0.00, real=0.06 secs] 
[GC (Allocation Failure) [PSYoungGen: 36458K->5110K(71680K)] 57709K->57089K(159232K), 0.0136663 secs] [Times: user=0.02 sys=0.03, real=0.02 secs] 
[GC (Allocation Failure) [PSYoungGen: 69867K->5110K(71680K)] 121847K->120586K(187392K), 0.0293396 secs] [Times: user=0.02 sys=0.03, real=0.03 secs] 
[Full GC (Ergonomics) [PSYoungGen: 5110K->4564K(71680K)] [ParOldGen: 115476K->115475K(220160K)] 120586K->120040K(291840K), [Metaspace: 3505K->3505K(1056768K)], 0.0441425 secs] [Times: user=0.11 sys=0.00, real=0.05 secs] 
[GC (Allocation Failure) [PSYoungGen: 69283K->4646K(132096K)] 184759K->181562K(352256K), 0.0258431 secs] [Times: user=0.03 sys=0.02, real=0.02 secs] 
[Full GC (Ergonomics) [PSYoungGen: 4646K->0K(132096K)] [ParOldGen: 176916K->181476K(311808K)] 181562K->181476K(443904K), [Metaspace: 3509K->3509K(1056768K)], 0.0404066 secs] [Times: user=0.08 sys=0.00, real=0.05 secs] 
[GC (Allocation Failure) [PSYoungGen: 125286K->4224K(138240K)] 306762K->306533K(450048K), 0.0466533 secs] [Times: user=0.02 sys=0.08, real=0.05 secs] 
[Full GC (Ergonomics) [PSYoungGen: 4224K->0K(138240K)] [ParOldGen: 302309K->306407K(495104K)] 306533K->306407K(633344K), [Metaspace: 3509K->3509K(1056768K)], 0.0612860 secs] [Times: user=0.09 sys=0.00, real=0.06 secs] 
[GC (Allocation Failure) [PSYoungGen: 131562K->75872K(262144K)] 437970K->437576K(757248K), 0.0935759 secs] [Times: user=0.03 sys=0.11, real=0.09 secs] 
[GC (Allocation Failure) [PSYoungGen: 259636K->96384K(281600K)] 621340K->619881K(807424K), 0.0690443 secs] [Times: user=0.11 sys=0.17, real=0.08 secs] 
[Full GC (Ergonomics) [PSYoungGen: 96384K->94211K(281600K)] [ParOldGen: 523497K->525546K(763392K)] 619881K->619758K(1044992K), [Metaspace: 3509K->3509K(1056768K)], 0.0680246 secs] [Times: user=0.14 sys=0.00, real=0.06 secs] 
[GC (Allocation Failure) [PSYoungGen: 278020K->116864K(392192K)] 803567K->802156K(1155584K), 0.0772084 secs] [Times: user=0.11 sys=0.19, real=0.08 secs] 
[Full GC (Ergonomics) [PSYoungGen: 116864K->38912K(392192K)] [ParOldGen: 685291K->763121K(1041408K)] 802156K->802034K(1433600K), [Metaspace: 3509K->3509K(1056768K)], 0.0618044 secs] [Times: user=0.13 sys=0.06, real=0.06 secs] 
[GC (Allocation Failure) [PSYoungGen: 310476K->139393K(414720K)] 1073598K->1072500K(1456128K), 0.0966146 secs] [Times: user=0.11 sys=0.11, real=0.09 secs] 
[Full GC (Ergonomics) [PSYoungGen: 139393K->32768K(414720K)] [ParOldGen: 933107K->1039607K(1356288K)] 1072500K->1072375K(1771008K), [Metaspace: 3509K->3509K(1056768K)], 0.0625357 secs] [Times: user=0.05 sys=0.03, real=0.06 secs] 
[GC (Allocation Failure) [PSYoungGen: 304346K->166017K(468480K)] 1343953K->1342841K(1824768K), 0.1447390 secs] [Times: user=0.16 sys=0.28, real=0.14 secs] 
[Full GC (Ergonomics) [PSYoungGen: 166017K->0K(468480K)] [ParOldGen: 1176824K->1342717K(1381888K)] 1342841K->1342717K(1850368K), [Metaspace: 3509K->3509K(1056768K)], 0.2634404 secs] [Times: user=0.26 sys=0.08, real=0.27 secs] 
[Full GC (Ergonomics) [PSYoungGen: 300809K->260097K(468480K)] [ParOldGen: 1342717K->1381633K(1381888K)] 1643527K->1641731K(1850368K), [Metaspace: 3509K->3509K(1056768K)], 0.1784625 secs] [Times: user=0.20 sys=0.08, real=0.17 secs] 
[Full GC (Ergonomics) [PSYoungGen: 300815K->299010K(468480K)] [ParOldGen: 1381633K->1381633K(1381888K)] 1682449K->1680644K(1850368K), [Metaspace: 3509K->3509K(1056768K)], 0.0413022 secs] [Times: user=0.01 sys=0.00, real=0.04 secs] 
[Full GC (Ergonomics) [PSYoungGen: 301058K->301058K(468480K)] [ParOldGen: 1381633K->1381633K(1381888K)] 1682692K->1682692K(1850368K), [Metaspace: 3509K->3509K(1056768K)], 0.0353384 secs] [Times: user=0.02 sys=0.00, real=0.03 secs] 
[Full GC (Allocation Failure) [PSYoungGen: 301058K->301058K(468480K)] [ParOldGen: 1381633K->1381615K(1381888K)] 1682692K->1682673K(1850368K), [Metaspace: 3509K->3509K(1056768K)], 0.4115150 secs] [Times: user=0.64 sys=0.01, real=0.42 secs]
GC日志的开头"[GC"和"[Full GC"说明了这次垃圾回收的停顿类型。如果有Full，说明这次GC是发生了Stop-Th
```
* GC日志的开头"[GC"和"[Full GC"说明了这次垃圾回收的停顿类型。如果有Full，说明这次GC是发生了Stop-The-World的，如果是调用System.gc()方法所触发的收集，那么这里将显示"[Full GC（System）"。
* 接下来的"[PSYoungGen"、"[ParOldGen"、"[Metaspace"表示GC发生的区域，这里显示的区域名称与使用的GC收集器是密切相关的，这里显示的PSYoungGen，所以JDK采用的是Parallel Scavenge收集器。老年代和永久代同理，名称也是又收集器决定的。
* 后面方括号内部的，例如"PSYoungGen: 310476K->139393K(414720K)"含义是“GC前该内存区域已使用容量 -> GC后该内存区域已使用容量（该内存区域总容量）”。
* 后面方括号外部的，例如"1343953K->1342841K(1824768K)"表示“GC前Java堆已使用容量 -> GC后Java堆已使用容量（Java堆总容量）”
* 再往后“0.1447390 secs”表示该内存区域GC所占用的时间，单位是秒（sec），[Times: user=0.16 sys=0.28, real=0.14 secs] 表示用户态消耗的时间、内核态消耗的CPU时间和操作从开始到结束所经过的墙钟时间。PS：CPU时间和墙钟时间的区别是：墙钟时间包括各种非运算的等待消耗时间，而CPU不包括这些时间。