# Java集合框架
- [ArrayList](#ArrayList)
- [HashMap的底层实现](#HashMap的底层实现)
## ArrayList
  * ArrayList的底层是数组队列，相当于动态数组。与Java中的数组相比，它的容量动态增长。在大量添加元素前，应用程序可以使用ensureCapacity操作来增加ArrayList的容量。这可以减少递增式再分配的数量。
  * ArrayList继承于AbstractList，实现了List，Cloneable，RandomAccess和Serializable接口。
  * ArrayList核心源码
```java
  public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
{
    private static final long serialVersionUID = 8683452581122892189L;

    /**
     * 默认初始容量大小
     */
    private static final int DEFAULT_CAPACITY = 10;

    /**
     * 空数组（用于空实例）。
     */
    private static final Object[] EMPTY_ELEMENTDATA = {};

     //用于默认大小空实例的共享空数组实例。
      //我们把它从EMPTY_ELEMENTDATA数组中区分出来，以知道在添加第一个元素时容量需要增加多少。
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

    /**
     * 保存ArrayList数据的数组
     */
    transient Object[] elementData; // non-private to simplify nested class access

    /**
     * ArrayList 所包含的元素个数
     */
    private int size;

    //...
  }

```
### 主要方法
+ add 方法
```java
    /**
     * 将指定的元素追加到此列表的末尾。 
     */
    public boolean add(E e) {
   //添加元素之前，先调用ensureCapacityInternal方法
        ensureCapacityInternal(size + 1);  // Increments modCount!!这里如果size +1 需要扩容，则动态扩容
        //这里看到ArrayList添加元素的实质就相当于为数组赋值
        elementData[size++] = e;
        return true;
    }
```
+ ensureCapacity 方法
```java
    //得到最小扩容量
    private void ensureCapacityInternal(int minCapacity) {
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
              // 获取默认的容量和传入参数的较大值
            minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
        }

        ensureExplicitCapacity(minCapacity);
    }
```
+ ensureExplicitCapacity 方法
```java
//判断是否需要扩容
    private void ensureExplicitCapacity(int minCapacity) {
        modCount++;
        // overflow-conscious code
        if (minCapacity - elementData.length > 0)
            //调用grow方法进行扩容，调用此方法代表已经开始扩容了
            grow(minCapacity);
    }
```
+ grow 方法
```java
    /**
     * ArrayList扩容的核心方法。
     */
    private void grow(int minCapacity) {
        // oldCapacity为旧容量，newCapacity为新容量
        int oldCapacity = elementData.length;
        //将oldCapacity 右移一位，其效果相当于oldCapacity /2，
        //我们知道位运算的速度远远快于整除运算，整句运算式的结果就是将新容量更新为旧容量的1.5倍，
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        //然后检查新容量是否大于最小需要容量，若还是小于最小需要容量，那么就把最小需要容量当作数组的新容量，
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        //再检查新容量是否超出了ArrayList所定义的最大容量，
        //若超出了，则调用hugeCapacity()来比较minCapacity和 MAX_ARRAY_SIZE，
        //如果minCapacity大于最大容量，则新容量则为ArrayList定义的最大容量，否则，新容量大小则为 minCapacity。 
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity);
    }
    //比较minCapacity和 MAX_ARRAY_SIZE
    private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :
            MAX_ARRAY_SIZE;
    }
```

分析如下：
+ 当我们要add第1个元素到ArrayList的时候，elementData.length为0，因为执行了ensureCapacityInternal()方法，所以minCapacity此时为10.
+ 然后添加第2~10个元素的时候，不会执行grow方法进行扩容
+ 直到添加第11个元素，minCapacity比elementData.length要大，进入grow方法进行扩容，扩容后的容量为原来的1.5倍

## ArrayList与LinkedList异同
+ 是否保证线程安全：ArrayList和LinkedList都是不同步的，也就是不保证线程安全
+ 底层数据结构：ArrayList底层使用的是Object数组；LinkedList底层使用的是双向链表（JDK6之前是循环链表，JDK7取消了循环）
+ 插入和删除是否受元素位置的影响
  * ArrayList采用数组存储，所以插入和删除元素的时间复杂度受元素位置的影响。如果执行add(E e)方法的时候，ArrayList会默认在将指定的元素追加到此列表的末尾，这种情况下时间复杂度就是O(1)。但是如果要在指定位置i插入和删除元素(add(index,E  element))时间复杂度为O（n-i）。因为在进行上述操作的时候集合中第i以及其后面的所有元素都要执行向后/向前移一位的操作。
  
  LinkedList采用链表存储，所以插入，删除元素时间复杂度不受元素位置的影响，都是近似O(1),而数组为近似O(n)
+ 是否支持快速随机访问：LinkedList不支持高效的随机元素访问，访问的时间复杂度是O(n)，而ArrayList支持,访问的时间复杂度近似O(1)。快速随机访问就是通过元素的序号快速获取元素对象
+ 内存空间占用：ArrayList的空间浪费主要体现在list列表的结尾会预留一定的容量空间，而LinkedList的空间花费则体现在它的每一个元素都需要消耗比ArrayList更多的空间（因为要存放直接后继和直接前驱以及数据）

## ArrayList和Vector的区别
Vector类的所有方法都是同步的。可以由多个线程安全地访问同一个Vector对象。但是一个线程访问Vector的话代码要在同步操作上耗费大量的时间。
ArrayList不是同步的，所以不需要在保证线程安全时建议使用ArrayList

## HashMap的底层实现
JDK1.8之前，HashMap底层是**数组和链表**结合在一起使用的也就是链表散列。hashMap**通过Key的hashCode经过扰动函数处理过后得到哈希值，然后通过（n-1） & hash判断当前元素存放的位置（这里的n指的是数组的长度），如果当前位置存在元素的话，就判断该元素与要存入的元素的hash值以及key是否相同，如果相同，则直接覆盖，不相同，则通过拉链法解决冲突。**。JDK1.8之后，HashMap底层采用的是**数组+链表/红黑树**，当链表长度大于阈值（默认为8）时，将链表转化为红黑树，以减少搜索时间。
所谓扰动函数指的就是HashMap的hash方法。使用hash方法是为了防止一些实现比较差的hashCode()方法，减少发生碰撞的概率。
所谓**拉链法**：就是将链表和数组相结合。也就是说创建一个链表数组，数组中每一格就是一个链表。若遇到哈希冲突，则将冲突的值加到链表中.
JDK1.8之后的版本可以查看文件《[JDK 1.8 重新认识HashMap](https://github.com/kuchensheng/java-knowledge-mapping/blob/master/JDK%201.8%20%E9%87%8D%E6%96%B0%E8%AE%A4%E8%AF%86HashMap.md)》
## HashMap和HashTable的区别
1.线程是否安全：HashMap是非线程安全的，HashTable是线程安全的；HashTable内部的方法基本基本都经过synchronized修饰。

2.效率：因为线程安全问题，HashMap比HashTable的效率更高一点，另外说明，HashTable基本被淘汰，不要在代码中使用它，如果要保证线程安全，还是使用ConcurrentHashMap。

3.对Null key和Null value的支持。HashMap中，最多一个key为null，可以多个value=null。HashTable中不能有键或值为null。

4.初始容量的大小和每次扩容大小的不同：创建时如果不指定容量初始值，Hashtable 默认的初始大小为11，之后每次扩充，容量变为原来的2n+1。HashMap 默认的初始化大小为16。之后每次扩充，容量变为原来的2倍。

5.底层数据结构：JDK1.8 以后的 HashMap 在解决哈希冲突时有了较大的变化，当链表长度大于阈值（默认为8）时，将链表转化为红黑树，以减少搜索时间。Hashtable 没有这样的机制。

## ConcurrentHashMap和HashTable的区别
ConcurrentHashMap 和 Hashtable 的区别主要体现在实现线程安全的方式上不同。
+ 底层数据结构：JDK1.7的 ConcurrentHashMap 底层采用 **分段的数组+链表**实现，JDK1.8 采用的数据结构跟HashMap1.8的结构一样，**数组+链表/红黑二叉树**。Hashtable和JDK1.8之前的HashMap 的底层数据结构类似都是采用数组+链表 的形式，数组是HashMap的主体,链表则是主要为了解决哈希冲突而存在的；
+ 实现线程安全的方式
  * 在JDK1.7的时候，ConcurrentHashMap（分段锁）对整个桶数组进行了分割分段（Segment），每一把锁只锁容器中的一部分数据，多线程访问容器里不同数据段的数据，就不会存在锁竞争，提高并发访问率。到了JDK1.8的时候已经摒弃了Segment的概念，而是直接使用Node数组+链表+红黑树的数据结构来实现，并发控制使用了synchronized和CAS来操作。整个看起来就像是优化过且线程安全的HashMap，虽然在JDK1.8中还能看到Segment的数据结构，但是已经简化了属性，只是为了兼容旧版本。HashTable使用了synchronized（同一把锁）来保证线程安全，效率非常低下。当一个线程访问同步方法时，其他线程也访问同步方法，可能会进入阻塞或轮询状态，如果使用put添加元素，另一个线程不能使用put添加元素，也不能使用get，竞争会越来越激烈，效率也会越来越低下。二者的比较图。
![HashTable](https://camo.githubusercontent.com/b8e66016373bb109e923205857aeee9689baac9e/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32322f35303635363638312e6a7067)

![JDK1.7的ConcurrentHashMap](https://camo.githubusercontent.com/443af05b6be6ed09e50c78a1dca39bf75acb106d/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32322f33333132303438382e6a7067)

![JDK1.8的ConcurrentHashMap](https://camo.githubusercontent.com/2d779bf515db75b5bf364c4f23c31268330a865e/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32322f39373733393232302e6a7067)
ConcurrentHashMap取消了Segment分段锁，采用CAS和synchronized来保证并发安全。数据结构跟HashMap1.8的结构类似，数组+链表/红黑二叉树。
synchronized只锁定当前链表或红黑二叉树的首节点，这样只要hash不冲突，就不会产生并发，效率又提升N倍。