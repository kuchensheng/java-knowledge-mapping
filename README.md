# 目录
+ Java
  - [Java/J2EE基础知识](#javaj2ee基础知识)
  
  
## Java/J2EE基础知识 
### String StringBuilder和StringBuffer的区别
+ 可变性
  * 简单来说：String类中使用final关键字修饰的字符组char[]来保存字符串，private final char value[]，所以String对象是不可变的。而StringBuffer和StringBuilder都是继承自AbstractStringBuilder类，在AbstractStringBuilder中也是使用字符数组保存字符串，只不过没有使用final修饰，所以这两个对象是可变的.源码如下：

+ 线程安全
  * String中的对象是不可变的，可以理解为它是一个常量，线程安全
  * AbstractStringBuilder定义了一些字符串的操作，如append、insert、indexOf等公共方法。
  * StringBuffer对方法加了同步锁或者对调用方法加了同步锁，所以是线程安全的
  * StringBuilder并没有对方法发进行加同步锁，所以是非线程安全的
+ 性能
  * 每次对String类型进行改变的时候，都会生成一个新的String对象，然后将指针指向新的String对象
  * StringBuffer每次都会对StringBuffer本身进行操作，而不是生成新的对象并改变对象引用。相同情况下使用StringBuilder相比使用StringBuffer相差并不大，仅能获取10% ~ 15%左右性能的提升。多线程下不建议使用StringBuilder。

+ 总结
  1.操作少量的数据 使用String
  2.单线程操作字符串缓冲区下操作大量数据 使用StringBuilder
  3.多线程操作字符串缓冲区下操作大量数据 使用StringBuffer
### 在Java中定义一个无参构造器的作用
  * Java程序在执行子类的构造方法之前，如果没有用super()来调用父类特定的构造方法，则会调用父类的无参构造器。因此如果父类中只定义了有参构造器，而子类有没有使用super()来调用父类的有参构造器，则编译时会发生错误。
