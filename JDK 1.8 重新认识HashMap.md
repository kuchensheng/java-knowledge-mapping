# JDK 1.8 重新认识HashMap
## 简介
Map中常用的4个实现类：HashMap、LinkedHashMap、TreeMap和hashTable.继承关系如下：

![](https://pic2.zhimg.com/80/26341ef9fe5caf66ba0b7c40bba264a5_hd.png)

+ HashMap:它根据键的hashCode值存储数据，大多数情况下可以直接定位到它的值，因为具有很快的访问速度，单遍历顺序却是不确定的。HashMap最多允许一条记录的键为null，允许多条记录的值为null。HashMap是非线程安全的。多线程同时写HashMap可能会导致数据的不一致。如果需要满足线程安全，可以使用Collections的synchronizedMap方法使HashMap具有线程安全能力，或者使用ConcurrentHashMap。
+ HashTable，很多映射的常用功能与HashMap类似，不同的是它继承自Dictionary类，并且是线程安全的，任一时间只有一个线程能写HashTable，并发性不好。不如ConcurrentHashMap，因为ConcurrentHashMap采用了锁分段技术。现在已经很少使用HashTable了，不需要线程安全的场合可以使用HashMap，需要线程安全的场合使用ConcurrentHashMap。
+ LinkedHashMap：是HashMap的子类，保存了记录的插入顺序，在用Iterator遍历LinkedHashMap时，先得到的记录肯定是先插入的。
+ TreeMap：实现了SortedMap接口，能够把它保存的记录根据键排序，默认是升序排序，也可以指定排序的比较器，当用Iterator遍历TreeMap时，得到的记录是排过序的。

这里将从存储结构、常用方法分析和扩容以及安全性方面探讨hashMap的工作原理

## 存储结构 - 字段
从结构上来讲，hashMap是数组+链表/红黑树（JDK1.8增加了红黑树部分）实现的，如下图所示：

！[](https://pic1.zhimg.com/80/8db4a3bdfb238da1a1c4431d2b6e075c_hd.png)

1.从源码可知，HashMap类中有一个非常重要的字段Node[],即Hash桶数组，明显它是一个Node的数组。
```
static class Node<K,V> implements Map.Entry<K,V> {
        final int hash;    //用来定位数组索引位置
        final K key;
        V value;
        Node<K,V> next;   //链表的下一个node

        Node(int hash, K key, V value, Node<K,V> next) { ... }
        public final K getKey(){ ... }
        public final V getValue() { ... }
        public final String toString() { ... }
        public final int hashCode() { ... }
        public final V setValue(V newValue) { ... }
        public final boolean equals(Object o) { ... }
}
```
Node是HashMap的一个内部类，实现了Map.Entry接口，本质是就是一个映射(键值对)。上图中的每个黑色圆点就是一个Node对象。
2.HashMap就是使用哈希表来存储的。哈希表为解决冲突，采用了**"拉链法"**,也就是**数组加链表**的结合。在每个数组元素上都一个链表结构，当数据被Hash后，得到数组下标，把数据放在对应下标元素的链表上。HashMap执行put方法时，系统将调用Key的hashCode()方法得到hashCode值，然后再通过hash算法来定位该键值对的存储位置，有时，两个key会定位到相同的位置，表示发生了Hash碰撞。这时采用拉链法解决hash碰撞，将冲突的值加到链表中。当然Hash算法计算结果越分散均匀，Hash碰撞的概率就越小，map的存取效率就会越高。如果哈希桶数组很大，即使较差的Hash算法也会比较分散，如果哈希桶数组数组很小，即使好的Hash算法也会出现较多碰撞，所以就需要在空间成本和时间成本之间权衡，其实就是在根据实际情况确定哈希桶数组的大小，并在此基础上设计好的hash算法减少Hash碰撞。
3.那么通过什么方式来控制map使得Hash碰撞的概率又小，哈希桶数组（Node[] table）占用空间又少呢？答案就是好的Hash算法和扩容机制。
在理解Hash和扩容流程之前，我们得先了解下HashMap的几个字段。从HashMap的默认构造函数源码可知，构造函数就是对下面几个字段进行初始化，源码如下：
```
    int threshold;             // 所能容纳的key-value对极限 
    final float loadFactor;    // 负载因子
    int modCount;  
    int size;
```
- 首先，Node[] table的初始化长度length(默认值是**16**)，LoadFactor为负载因子(默认值是0.75)，threshold是HashMap所能容纳的最大数据量的Node(键值对)个数。**threshold = length * LoadFactor**。也就是说，在数组定义好长度之后，负载因子越大，所能容纳的键值对个数越多。
- 结合负载因子的定义公式可知，threshold就是在此Load factor和length(数组长度)对应下允许的最大元素数目，超过这个数目就重新resize(扩容)，**扩容后的HashMap容量是之前容量的两倍**。
- size这个字段其实很好理解，就是HashMap中实际存在的键值对数量。
- modCount字段主要用来记录HashMap内部结构发生变化的次数，主要用于迭代的快速失败。

