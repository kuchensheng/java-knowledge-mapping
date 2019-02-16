# Java中的锁
![Java中的锁](imgs/Java-Lock.png)

## Lock 接口
锁是用来控制多个线程访问共享资源的方式，一般来说，一个锁能够防止多个线程同时访问共享资源（但是有些锁可以允许多个线程同时访问共享资源，比如读写锁）。在Lock接口出现之前，Java程序主要依靠synchronized关键字实现锁功能，Java SE 5之后，并发包中新增了Lock接口（以及其相关实现类）来实现锁功能，它提供了与synchronized关键字类似的同步功能，只是在使用时需要显示地获取和释放锁。
### Lock的简单使用
```
Lock lock=new ReentrantLock()；
	//不能将获取锁的过程写到try块中，因为如果在获得锁时发生异常，异常抛出的同时也会导致锁无故释放
  lock.lock();
   try{
   	//这里是业务逻辑
    }finally{
    	//这里保证获得锁之后，最终能得到释放
    lock.unlock();
    }
```
### Lock接口的特性和常见方法
- **Lock接口拥有的synchronized不具备的主要特性**
|特性|	描述|

|尝试非阻塞地获取锁|	当前线程尝试获取锁，如果这一时刻锁没有被其他线程获取到，则成功获取并持有锁|
|能被中断地获取锁|	获取到锁的线程能够响应中断，当获取到锁的线程被中断时，中断异常将会被抛出，同时锁会被释放|
|超时获取锁|	在指定的截止时间之前获取锁， 超过截止时间后仍旧无法获取则返回|
- **Lock的基本方法**
|方法名称|	描述|

|void lock()|	获得锁。如果锁不可用，则当前线程将被禁用以进行线程调度，并处于休眠状态，直到获取锁。|
|void lockInterruptibly()|	获取锁，如果可用并立即返回。如果锁不可用，那么当前线程将被禁用以进行线程调度，并且处于休眠状态，和lock()方法不同的是在锁的获取中可以中断当前线程（相应中断）。|
|Condition newCondition()|	获取等待通知组件，该组件和当前的锁绑定，当前线程只有获得了锁，才能调用该组件的wait()方法，而调用后，当前线程将释放锁。|
|boolean tryLock()|	只有在调用时才可以获得锁。如果可用，则获取锁定，并立即返回值为true；如果锁不可用，则此方法将立即返回值为false 。|
|boolean tryLock(long time, TimeUnit unit)|	超时获取锁，当前线程在一下三种情况下会返回： 1. 当前线程在超时时间内获得了锁；2.当前线程在超时时间内被中断；3.超时时间结束，返回false.|
|void unlock()|	释放锁。|

## 队列同步器（AQS）
队列同步器（AbstractQueueSynchronizer），用来构建锁或者其他同步器的的基础框架，它使用了一个int成员变量表示同步状态，
```
private volatile int state;//共享变量，使用volatile修饰保证线程可见性
```
通过内置的FIFO队列来完成资源获取线程的排队工作。这个类在JUC包下

![AQS](imgs/AQS.png)

AQS是一个用来构建锁和同步器的框架，使用AQS能简单且高效地构造出应用广泛的大量的同步器，比如我们提到的ReentrantLock，Semaphore，其他的诸如ReentrantReadWriteLock，SynchronousQueue，FutureTask等等皆是基于AQS的。

### AQS原理
AQS的核心思想是，如果被请求的共享资源空闲，则将当前请求资源的线程置为有效的工作线程，并且将共享资源设置为锁定状态。如果被请求的共享资源被占用，那么就用CLH队列锁来将暂时获取不到锁的线程加入到队列中。

AQS的设计时基于模板方法模式的，使用者需要继承同步器并重写指定的方法，随后将同步器组合在自定义同步组件的实现中。重写同步器指定的方法时，需要使用同步器提供的3个方法来访问或者修改同步状态
	*	+ getState():获取当前同步状态
	*	+ setState(int newState):设置当前同步状态
	*	+ compareAndSetState(int expect,int update):使用CAS设置当前状态，该方法能保证状态设置的原子性
```
//返回同步状态的当前值
protected final int getState() {  
        return state;
}
 // 设置同步状态的值
protected final void setState(int newState) { 
        state = newState;
}
//原子地（CAS操作）将同步状态值设置为给定值update如果当前同步状态的值等于expect（期望值）
protected final boolean compareAndSetState(int expect, int update) {
        return unsafe.compareAndSwapInt(this, stateOffset, expect, update);
}
```

- AQS的接口和示例
|方法名称|描述|
|boolean tryAqured(int arg)|独占式获取同步状态|
|boolean tryRelease(int arg)|独占式释放同步状态|
|int tryAcquiredShared(int arg)|共享式获取同步状态|
|boolean tryReleaseShared(int arg)|共享式释放同步状态|
|boolan isHeldExclusively()|当前同步器是否在独占模式下被线程占用|
示例代码：

## 重入锁ReentrantLock
重入锁表示该锁能够支持一个线程对资源的重复加锁。除此之外，该锁还支持获取锁时的公平和非公平性选择
ReentrantLock虽然没能像synchronized关键字那样支持隐式的重进入，但是在调用lock()方法时，已经获取到锁的线程，能够再次调用lcok()方法获取锁而不是阻塞。
锁的公平性：如果在绝对公平的时间上，先对锁进行获取的请求一定先被满足，那么这个锁就是公平的，否则是不公平的。
### ReentrantLock类常见的方法
+ 构造器

|方法名称|	描述|

|ReentrantLock()|	创建一个 ReentrantLock的实例。|
|ReentrantLock(boolean fair)|	创建一个特定锁类型（公平锁/非公平锁）的ReentrantLock的实例|

## ReentrantReadWriteLock 读写锁
ReentrantLock（排他锁）具有完全互斥排他的效果，即同一时刻只允许一个线程访问，这样做虽然虽然保证了实例变量的线程安全性，但效率低下。ReadWriteLock接口的实现类-ReentrantReadWriteLock读写锁就是为了解决这个问题。
读写锁维护了两个锁，一个是读操作相关的锁为共享锁，一个是写操作相关的锁为排他锁。通过分离读锁和写锁，其并发性比一般排他锁有了很大提升。

### ReentrantReadWriteLock的特性与常见方法
ReentrantReadWriteLock的特性：

|特性|	说明|

|公平性选择|	支持非公平（默认）和公平的锁获取方式，吞吐量上来看还是非公平优于公平|
|重进入|	该锁支持重进入，以读写线程为例：读线程在获取了读锁之后，能够再次获取读锁。而写线程在获取了写锁之后能够再次获取写锁也能够同时获取读锁|
|锁降级|	遵循获取写锁、获取读锁再释放写锁的次序，写锁能够降级称为读锁|

### 读写锁的接口与示例
ReadWriteLock仅定义了获取读锁和写锁两个办法，readLock()和writeLock()。
- 读读共享
两个线程同时运行read方法，你会发现两个线程可以同时或者说是几乎同时运行lock()方法后面的代码，输出的两句话显示的时间一样。这样提高了程序的运行效率。
```
private ReentrantReadWriteLock lock = new ReentrantReadWriteLock();

    public void read() {
        try {
            try {
                lock.readLock().lock();
                System.out.println("获得读锁" + Thread.currentThread().getName()
                        + " " + System.currentTimeMillis());
                Thread.sleep(10000);
            } finally {
                lock.readLock().unlock();
            }
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
```

- 写写互斥
两个线程同时运行write方法，你会发现同一时间只允许一个线程执行lock()方法后面的代码
```
private ReentrantReadWriteLock lock = new ReentrantReadWriteLock();

    public void write() {
        try {
            try {
                lock.writeLock().lock();
                System.out.println("获得写锁" + Thread.currentThread().getName()
                        + " " + System.currentTimeMillis());
                Thread.sleep(10000);
            } finally {
                lock.writeLock().unlock();
            }
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
```
