# 目录
+ Java
  - [Java基础知识](#java基础知识)
  - [Java集合框架](#java集合框架)
  
  
## Java基础知识 
### String StringBuilder和StringBuffer的区别
+ 可变性

  简单来说：String类中使用final关键字修饰的字符组char[]来保存字符串，private final char value[]，所以String对象是不可变的。而StringBuffer和StringBuilder都是继承自AbstractStringBuilder类，在AbstractStringBuilder中也是使用字符数组保存字符串，只不过没有使用final修饰，所以这两个对象是可变的

+ 线程安全

  1.String中的对象是不可变的，可以理解为它是一个常量，线程安全
  
  2.AbstractStringBuilder定义了一些字符串的操作，如append、insert、indexOf等公共方法。
  
  3.StringBuffer对方法加了同步锁或者对调用方法加了同步锁，所以是线程安全的
  
  4.StringBuilder并没有对方法发进行加同步锁，所以是非线程安全的
  
+ 性能

  1.每次对String类型进行改变的时候，都会生成一个新的String对象，然后将指针指向新的String对象
  
  2.StringBuffer每次都会对StringBuffer本身进行操作，而不是生成新的对象并改变对象引用。相同情况下使用StringBuilder相比使用StringBuffer相差并不大，仅能获取10% ~ 15%左右性能的提升。多线程下不建议使用StringBuilder。

+ 总结

  1.操作少量的数据 使用String
  
  2.单线程操作字符串缓冲区下操作大量数据 使用StringBuilder
  
  3.多线程操作字符串缓冲区下操作大量数据 使用StringBuffer
  
### 在Java中定义一个无参构造器的作用
  Java程序在执行子类的构造方法之前，如果没有用super()来调用父类特定的构造方法，则会调用父类的无参构造器。因此如果父类中只定义了有参构造器，而子类有没有使用super()来调用父类的有参构造器，则编译时会发生错误。

### 接口和抽象类的区别是什么
  1.接口的方法默认是public，所有方法在接口中不能有实现（JDK8开始几口方法可以有默认实现），抽象类可以有非抽象的方法
  
  2.接口中的是变量默认是final类型的，而抽象类中不一定
  
  3.一个类可以实现的讴歌接口，但最多只能继承一个抽象类
  
  4.一个类实现接口的话，要实现接口的所有方法，而抽象类则不一定
  
  5.接口不能用new实例化，但是可以声明，但是必须引用一个实现该接口的对象。
  
  6.从设计层面来说，抽象是对类的抽象，是一种模板设计，接口是行为的抽象，是一种行为规范

### 成员变量和局部变量的区别
  1.从语法形式上，成员变量属于类，而局部变量是在方法中定义的变量或者是方法的参数
  
  2.成员变量可以被public、private和static等修饰符修饰，局部变量不能被访问修饰符修饰，但是这两者都可以被final修饰
  
  3.从变量在内存中的存储方式来看，成员变量是对象的一部分，对象存在堆内存，局部变量存在于栈内存中
  
  4.从变量在内存中的生存时间来看，成员变量是对象的一部分，它随对象的创建而存在，而局部变量随着方法的调用结束而自动消失
  
  5.成员变量如果没有被赋值，则自动以类型的默认值负责，局部变量不会自动赋值
  
### 创建对象的方式
  1.使用new 运算符
  
  2.使用反射 Class.forName("").newInstance
  
  3.使用动态代理生成对象
  
  4.使用工厂模式生产对象
  
### ==与equals的区别
  + ==
  * 它的作用是**判断两个对象的地址**是不是相等，即判断两个对象是不是同一个对象。基本数据类型比较的是值，引用数据类型比较的是内存地址
  + equals
  它的作用也是判断两个对象是否是相等，但它一般有两种使用情况：
  1.情况1：类没有覆盖equals方法。则通过equals方法比较该类的两个对象时，等价于通过“==”比较这个对象
  
  2.情况2：类覆盖了equals方法。一般，我们都覆盖了equals方法来比较两个对象是否相等；如果他们的内容相等，则两个对象相等。
  举个栗子：
  ```
  public class test1 {
    public static void main(String[] args) {
        String a = new String("ab"); // a 为一个引用
        String b = new String("ab"); // b为另一个引用,对象的内容一样
        String aa = "ab"; // 放在常量池中
        String bb = "ab"; // 从常量池中查找
        if (aa == bb) // true
            System.out.println("aa==bb");
        if (a == b) // false，非同一对象
            System.out.println("a==b");
        if (a.equals(b)) // true
            System.out.println("aEQb");
        if (42 == 42.0) { // true
            System.out.println("true");
        }
    }
}
  ```
  
### hashCode与equals
+ hashCode() 介绍
  * hashCode()的作用是获取哈希码，也称散列码；它实际上是返回一个int整数。这个哈希码的作用是确定该对象在哈希表中的索引位置。hashCode() 定义在JDK的Object.java中，这就意味着Java中的任何类都包含有hashCode() 函数。
  散列表存储的是键值对(key-value)，它的特点是：能根据“键”快速的检索出对应的“值”。这其中就利用到了散列码！（可以快速找到所需要的对象）d
+ 为什么要有hashCode
  * 以“HashSet如何检查重复”为例来说明为什么要有hashCode
  当你把对象加入HashSet时，HashSet会先计算对象的hashCode来判断对象加入的位置，同事也会与其他已经加入的对象的hashCode值作比较，如果没有相符的hashCode，HashSet就认为没有对象重复。如果有相同的hashCode值的对象，这时会调用equals()方法来检查hashCode的对象是否真的相同。如果两者相同，HashSet就不会让其加入操作成功。如果不同的话，就会重新三列到其他位置。这样我们就大大减少了equals的次数，提供了执行速度
+ hashCode()和equals()的相关规定
  1. 如果两个对象相等，则hashCode一定相等，调用equals方法比较返回true
  
  2. 如果两个对象的hashCode相等，它们也不一定相等。因此equals()方法被覆盖的，则hashCode一定也必须被覆盖
  
  3.hashCode()的默认行为是对堆上的对象产生独特值，如果没有重写hashCode()，则该class的两个对象无论如何都不会相等的
  
## Java集合框架
### ArrayList与LinkedList异同
+ 是否保证线程安全：ArrayList和LinkedList都是不同步的，也就是不保证线程安全
+ 底层数据结构：ArrayList底层使用的是Object数组；LinkedList底层使用的是双向链表（JDK6之前是循环链表，JDK7取消了循环）
+ 插入和删除是否受元素位置的影响
  * ArrayList采用数组存储，所以掺入和删除元素的时间复杂度受元素位置的影响。入股执行add（E e）方法的时候，ArrayList会默认在将指定的元素追加到此列表的末尾，这种情况下时间复杂度就是O(1)。但是如果要在指定位置i插入和删除元素（add（index,E  element））时间复杂度为O（n-i）。因为在进行上述操作的时候集合中第i以及其后面的所有元素都要执行向后/向前移一位的操作。
  LinkedList采用链表存储，所以掺入，删除元素时间复杂度不收元素位置的影响，都是近似O(1),而数组为近似O(n)
+ 是否支持快速随机访问：LinkedList不支持高效的随机元素访问，访问的时间复杂度是O(n)，而ArrayList支持,访问的时间复杂度近似O(1)。快速随机访问就是通过元素的序号快速获取元素对象
+ 内存空间占用：ArrayList的空间浪费主要体现在list列表的结尾会预留一定的容量空间，而LinkedList的空间花费则体现在它的每一个元素都需要消耗给ArrayList更多的空间（因为要存放直接后继和直接前驱以及数据）

### ArrayList和Vector的区别
Vector类的所有方法都是同步的。可以由多个线程安全地访问同一个Vector对象。但是一个线程访问Vector的话代码要在同步操作上耗费大量的时间。
ArrayList不是同步的，所以不需要在保证线程安全时建议使用ArrayList

### HashMap的底层实现
JDK1.8之前，HashMap底层是**数组和链表**结合在一起使用的也就是链表散列。hashMap**通过Key的hashCode经过扰动函数处理过后得到哈希值，然后通过（n-1） & hash判断当前元素存放的位置（这里的n指的是数组的长度），如果当前位置存在元素的话，就判断该元素与要存入的元素的hash值以及key是否相同，如果相同，则直接覆盖，不相同，则通过拉链法解决冲突。**。JDK1.8之后，HashMap底层采用的是**数组+链表/红黑树**，当链表长度大于阈值（默认为8）时，将链表转化为红黑树，以减少搜索时间。
所谓扰动函数指的就是HashMap的hash方法。使用hash方法是为了防止一些实现比较差的hashCode()方法，减少发生碰撞的概率。
所谓**拉链法**：就是将链表和数组相结合。也就是说创建一个链表数组，数组中每一格就是一个链表。若遇到哈希冲突，则将冲突的值加到链表中.
JDK1.8之后的版本可以查看文件《[JDK 1.8 重新认识HashMap](JDK 1.8 重新认识HashMap.md)》
### HashMap和HashTable的区别
1.线程是否安全：HashMap是非线程安全的，HashTable是线程安全的；HashTable内部的方法基本基本都经过synchronized修饰。
2.效率：因为线程安全问题，HashMap比HashTable的效率更高一点，另外说明，HashTable基本被淘汰，不要在代码中使用它，如果要保证线程安全，还是使用ConcurrentHashMap。
3.对Null key和Null value的支持。HashMap中，最多一个key为null，可以多个value=null。HashTable中不能有键或值为null。
4.初始容量的大小和每次扩容大小的不同：创建时如果不指定容量初始值，Hashtable 默认的初始大小为11，之后每次扩充，容量变为原来的2n+1。HashMap 默认的初始化大小为16。之后每次扩充，容量变为原来的2倍。
5.底层数据结构：JDK1.8 以后的 HashMap 在解决哈希冲突时有了较大的变化，当链表长度大于阈值（默认为8）时，将链表转化为红黑树，以减少搜索时间。Hashtable 没有这样的机制。

### ConcurrentHashMap和HashTable的区别
ConcurrentHashMap 和 Hashtable 的区别主要体现在实现线程安全的方式上不同。
+ 底层数据结构：JDK1.7的 ConcurrentHashMap 底层采用 **分段的数组+链表**实现，JDK1.8 采用的数据结构跟HashMap1.8的结构一样，**数组+链表/红黑二叉树**。Hashtable和JDK1.8之前的HashMap 的底层数据结构类似都是采用数组+链表 的形式，数组是HashMap的主体,链表则是主要为了解决哈希冲突而存在的；
+ 实现线程安全的方式
  * 在JDK1.7的时候，ConcurrentHashMap（分段锁）对整个桶数组进行了分割分段（Segment），每一把锁只锁容器中的一部分数据，多线程访问容器里不同数据段的数据，就不会存在锁竞争，提高并发访问率。到了JDK1.8的时候已经摒弃了Segment的概念，而是直接使用Node数组+链表+红黑树的数据结构来实现，并发控制使用了synchronized和CAS来操作。整个看起来就像是优化过且线程安全的HashMap，最燃在JDK1.8中还能看到Segment的数据结构，但是已经简化了属性，只是为了兼容旧版本。HashTable使用了synchronized（同一把锁）来保证线程安全，效率非常低下。当一个线程访问同步方法时，其他线程也访问同步方法，可能会进入阻塞或轮询状态，如果使用put添加元素，另一个线程不能使用put添加元素，也不能使用get，竞争会越来越激烈，效率也会越来越低下。二者的比较图。
![HashTable](https://camo.githubusercontent.com/b8e66016373bb109e923205857aeee9689baac9e/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32322f35303635363638312e6a7067)

![JDK1.7的ConcurrentHashMap](https://camo.githubusercontent.com/443af05b6be6ed09e50c78a1dca39bf75acb106d/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32322f33333132303438382e6a7067)

![JDK1.8的ConcurrentHashMap](https://camo.githubusercontent.com/2d779bf515db75b5bf364c4f23c31268330a865e/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32322f39373733393232302e6a7067)
ConcurrentHashMap取消了Segment分段锁，采用CAS和synchronized来保证并发安全。数据结构跟HashMap1.8的结构类似，数组+链表/红黑二叉树。
synchronized只锁定当前链表或红黑二叉树的首节点，这样只要hash不冲突，就不会产生并发，效率又提升N倍。



