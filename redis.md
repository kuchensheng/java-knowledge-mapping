# 1. 缓存
用缓存，主要有两个用途：高性能、高并发

**高性能**

假设这么个场景，你有个操作，一个请求过来，吭哧吭哧你各种乱七八糟操作mysql，半天查出来一个结果，耗时600ms。但是这个结果可能接下来几个小时都不会变了，或者变了也可以不用立即反馈给用户。那么此时咋办？**缓存啊**，折腾600ms查出来的结果，扔缓存里，一个key对应一个value，下次再有人查，别走mysql折腾600ms了，直接从缓存里，通过一个key查出来一个value，2ms搞定。性能提升300倍。

就是说对于一些需要复杂操作耗时查出来的结果，且确定后面不怎么变化，但是有很多读请求，那么直接将查询出来的结果放在缓存中，后面直接读缓存就好。

**高并发**

mysql这么重的数据库，压根儿设计不是让你玩儿高并发的，虽然也可以玩儿，但是天然支持不好。mysql单机支撑到**2000QPS**也开始容易报警了。

所以要是你有个系统，高峰期一秒钟过来的请求有1万，那一个mysql单机绝对会死掉。你这个时候再不进行数据库集群的情况下，上缓存，把很多数据放缓存，别访问mysql。缓存功能简单，说白了就是key-value式操作，单机支撑的并发量轻松一秒几万十几万，支撑高并发so easy。单机承载并发量是mysql单机的几十倍。

```
缓存是走内存的，内存天然就支撑高并发。
```

## 1.1 缓存选型
目前一般用的缓存是redis和memcached。各大BBS上都有这两项比对。这里只简单说明一下：

+ Redis支持复杂的数据结构

redis 相比 memcached 来说，拥有更多的数据结构，能支持更丰富的数据操作。如果需要缓存能够支持更复杂的结构和操作， redis 会是不错的选择。

+ redis 原生支持集群模式

redis3.x版本以后，支持cluster模式，而 memcached 没有原生的集群模式，需要依靠客户端来实现往集群中分片写入数据。redis开发难度低

+ 性能比对

Redis性能极高：Redis能读的速度是110000次/s,写的速度是81000次/s 。

由于redis只使用单核，而 memcached 可以使用多核，所以平均每一个核上redis在存储小数据时比 memcached 性能更高。而在100k以上的数据中，memcached性能要高于redis，虽然redis最近也在存储大数据的性能上进行优化，但是比起memcached，还是稍有逊色。

![Redis线程模型](imgs/redis-single-thread-model.png)

# 2. 什么是Redis
Redis是完全开源的、基于内存的、高性能键值对数据库。它具备以下特性：
+ 丰富的存储结构

到目前为止Redis提供了5种不同的数据结构：
- 字符串String
- 列表 List
- 集合 Set
- 散列 Hash
- 有序集合 Zset

Redis还支持 publish/subscribe, 通知, key 过期等等特性。

+ 内存存储和持久化

Redis数据库中的所有数据都存储在内存中。由于内存的读写速度远快于硬盘，因此Redis在性能上对比基于硬盘的数据库有非常明显优势。除此之外，Redis支持复制和持久化以及客户端分片，用户很方便地就可以将Redis扩展。

# 3. [Redis安装](http://www.runoob.com/redis/redis-install.html)

# 4. Redis 基本命令

## 4.1.字符串String
在Redis里，字符串可以存储以下3种类型的值
* 字符串
* 整数
* 浮点数
用户可以通过给定一个任意的数值，对存储着整数或浮点数的字符串执行自增或者自减操作。

Redis中字符串操作命令

|命令|描述|
| ---- | ---- |
|GET key|获取存储在给定键中的值|
|SET key value|设置存储在给定键中的值|
|DEL key|删除给定键的值|
|INCR key|将键存储值+1|
|DECR key|将键存储值-1|
|APPNED key value|将值value追加到末尾|

![redis_string](imgs/redis_string.png)

## 4.2.列表List
redis列表允许用户从列表的两端推入或者弹出元素，以及执行各种常见的列表操作。除此之外，还可以作为阻塞队列使用。

|命令|用例和描述|
| ---- | ---- |
|RPUSH key item|将给定值推入列表右端|
|LPUSH key item|将给定值推入列表左端|
|RPOP key|从列表左端弹出元素|
|LPOP key|从列表右端弹出元素|
|LRANGE key start end|获取列表在给定范围上的所有值，-1表示取出所有元素|
|LINDEX key index|获取列表在给定位置上的单个元素|
|BLPOP key-name [key-name ...] timeout|从第一个非空列表中弹出最左端元素，或者在timeout秒内阻塞并等待可弹出的元素出现|


![redis_list](imgs/redis_list.png)

## 4.3.集合Set
Redis集合和列表的不同之处在于，列表可以存储多个相同的字符串，而集合通过使用散列来保证自己存储的每个字符串都是不同的。

|命令|用例和描述|
| ---- | ---- |
|SADD key item|将给定元素添加到集合|
|SMEMBERS key|返回集合包含的所有元素|
|SISMEMBER key item|检查给定元素是否存在与集合中|
|SREM key item|删除给定元素|
|SPOP key|随机地移除集合中一个元素，并返回|
|SDIFF key-name [key-name ...]|差集运算|
|SINTER key-name[key-name ...]|交集运算|
|SUNION key-name[key-name ...]|并集运算|

![redis_set](imgs/redis_set.png)

## 4.4.散列Hash
Redis的散列可以存储多个键值对之间的映射关系。存储结构类似于Map<hashKey,Map<subKey,item>>

|命令|用例和描述|
| ---- | ---- |
|HSET key subKey item|在散列里面关联给给定的键值对(新增)|
|HGET key subKey|获取指定散列键的值|
|HGETDETAIL key|获取散列包含的所有键值对|
|HDEL key subKey|删除元素|
|HMSET key-name key value [key value ...]|为散列里添加一个或多个键值对|
|HMGET key-name key [key ...]|从散列中获取一个或多个键的值|
|HKEYS key-name |获取散列中包含的所有的键|
|HVALS key-name |获取散列中包含的所有的值|

![redis_hash](imgs/redis_hash.png)

## 4.5.有序集合

|命令|用例和描述|
| ---- | ---- |
|ZADD key-name score member [score memeber ...]|将带有给定分值的成员添加到有序集合|
|ZREM key-name member|移除给定的成员|
|ZCARD key-name|返回有序集合包含的成员数量|
|ZRANGE key start stop [withscores]|返回有序集合中排名介于start和stop之间的成员。|

![redis_zset](imgs/redis_zset.png)

## 4.6.发布/订阅
订阅者（listener）负责订阅频道（channel），发送者（publisher）负责向频道发送二进制字符串消息。每当有消息被发送到给定频道，频道的所有订阅者都会受到消息。

|命令|用例和描述|
| ---- | ---- |
|SUBSCRIBE channel [channel ...]|订阅给定的一个或多个频道|
|UNSUBSCRIBE [channel [channel ...]]|取消订阅给定的一个或多个频道，如果不指定channel，将取消订阅所有的频道|
|PSUBSCRIBE pattern [pattern ...]|订阅与正则匹配的所有频道|
|PUNSUBSCRIBE [pattern [pattern ...]]|取消订阅与正则匹配的所有频道，如果不指定pattern，将取消订阅所有的频道|
|PUBLISH channel message|向给定频道发送消息|

**注意**：不建议使用redis的发布订阅模式：

* 1. redis系统稳定性。如果发生消息堆积，可能会导致redis的速度变慢，甚至直接崩溃。
* 2. 数据传输可靠性。如果客户端在执行订阅操作过程中短线，那么客户端将丢失在短线期间发送的所有消息。

## 4.7.redis对事务的支持
事务：一组相关的操作是原子性的，要么都执行，要么都不执行；一组事务，要么成功，要么撤回。redis通过multi、exec等命令实现事务功能。

![redis_multi](imgs/redis_multi.png)

## 4.8. redis键的过期时间
redis的过期时间（expiration）特性让一个键在给定的时限之后自动删除。

|命令|用例和描述|
| ---- | ---- |
|EXPIRE key-name seconds|让给定键在指定的秒数之后过期|
|PEXPIRE key-name millionseconds|让给定键在指定的毫秒数之后过期|
|EXPIREAT key-name timestamp|将给定键的过期时间设置为给到给定的UNIX时间戳|
|TTL key-name|查看给定键距离过期还有多少秒|
|PTTL key-name|查看给定键距离过期还有多少毫秒|

# 5.数据安全与性能保障
## 5.1 Redis持久化
Redis提供了两种不同的持久化方法来将数据存储到硬盘。一种方法叫快照（snapshoting），它可以将存在于某一时刻的所有数据都写入硬盘。另一种方法叫只追加文件（Append-only-file,AOF）,它会在执行写命令时，将被执行的写命令复制到硬盘里面。

```
## Redis持久化选项

# 60秒内有1000次写入，触发bgsave
save 60 1000
# 快照将被写入dbfilename选项指定的文件里面
dbfilename dump.rdb

# AOF开关 yes/no
appendonly no
# 同步频率，每秒一次
appendfsync everysec
#当AOF的体积大于64MB，且比上一次重写之后的体积大了至少1倍（100%），触发BGREWRITEAOF
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

#这个选项决定了快照文件和AOF文件的保存文职
dir ./
```
### 5.1.1 快照持久化
Redis可以通过快照来获得存储在内存里面的数据在某个时间点上的副本。
创建快照的方法：

- 客户端可以通过向Redis发送**BGSAVE**命令来创建一个快照。Redis会**调用fork**命令来创建一个子进程，然后子进程负责将快照写入硬盘，而父进程则继续处理命令请求。
- 客户端向Redis发送**SAVE**命令来创建一个快照。接到SAVE命令的Redis服务器在创建快照完毕之前将**不再响应其他任何命令**。
- 如果用户设置了save选项，比如：save 60 1000，那么从Redis最近一次创建快照开始之后算起，当“60秒内有1000次写入”这个条件被满足时，Redis会自动触发BGSAVE命令。如果设置了多个save配置选项，那么任意一个save配置选项被满足时，Redis就会触发一次BGSAVE。
- 当Redis通过SHUTDOWN命令接收到关闭服务器请求时，或者接收到标准TERM信号时，会执行一次SAVE命令，阻塞所有客户端，不再执行客户端发送的任何命令，并在SAVE命令执行完毕之后关闭服务器。
- 当Redis服务器连接另一个Redis服务器，并向对方发起SYNC命令来开始一次复制操作的时候，如果主服务器目前没有执行BGSAVE操作，或者主服务器并非刚刚执行完BGSAVE操作，那么主服务器就会执行一次BGSAVE命令。

**注意**：如果系统发生崩溃，用户将丢失最近一次生成快照之后的所有数据。并且当Redis存储量越大，BGSAVE在创建子进程时耗费的时间就越长。SAVE命令比BGSAVE命令执行快照时间要快。

### 5.1.2 AOF持久化
AOF持久化会将被执行的写命令写到AOF文件的末尾，以此来记录数据发生的变化。为了兼顾数据安全和写入性能，建议使用appendfsync everysec选项，让Redis以每秒一次的频率对AOF文件进行同步。Redis每秒同步一次AOF文件时的性能和不使用任何持久化时的性能相差无几。

随着Redis的不断运行，AOF的体积会不断增长。为了解决AOF文件体积不断增大的问题，用户可以向Redis发送**BGWRITEAOF**命令，这个命令会通过移除AOF文件中冗余命令来重写AOF文件，使AOF文件的体积变得尽可能小。

BGREWRITEAOF命令会创建一个子进程，然后子进程负责对AOF文件进行重写。AOF的持久化也可以通过设置auto-aof-rewrite-percentage选项和auto-aof-rewrite-min-size选项来自动执行BGREWRITEAOF

## 5.2 复制
复制可以让其他服务器拥有一个不断更新的数据副本，从而使得用户数据副本的服务器可以用于处理客户端发送的请求。

## 5.3 Redis的高可用模式
[Redis:详解三种集群策略](https://blog.csdn.net/q649381130/article/details/79931791)

# 6 分布式锁
SETNX只能对单个节点加锁，对集群式的redis要采用redission来获得锁和释放锁

# 7 为什么Redis这么快
Redis采用的是基于内存的、采用单进程、单线程模型的KV数据库，官方提供的数据是可以达到100000+的QPS。

Redis这么快的原因如下：
+ 完全基于内存，绝大部分请求是纯粹的内存操作，非常快速
+ 数据结构简单，对数据操作简单，Redis中的数据结构是专门进行设计的
+ 采用单线程，避免了不必要的上下文切换和竞争条件，也不存在多进程或者多进程导致的切换而消耗CPU，不用去考虑各种锁问题，不存在加锁和释放锁操作，没有因为可能出现死锁而导致的性能消耗。
+ 使用多路IO复用模型，非阻塞IO。多路I/O复用模型是利用select、poll、epoll可以同时监察多个流的I/O事件的能力，在空闲的时候，会把当前线程阻塞掉，当有一个或多个流有I/O事件时，就从阻塞态中唤醒，于是程序就会轮询一遍所有的流（epoll 是只轮询那些真正发出了事件的流），并且只依次顺序的处理就绪的流，这种做法就避免了大量的无用操作。
+ 使用底层模型不同，Redis直接自己构建了VM机制。

# 8 为什么redis是单线程的
官方FAQ表示，因为Redis是基于内存的操作，CPU不是Redis的瓶颈，Redis的瓶颈最有可能是机器内存的大小或者网络带宽。既然单线程容易实现，而且CPU不会成为瓶颈，那就顺理成章地采用单线程的方案了

但是，我们使用单线程的方式是无法发挥多核CPU 性能，不过我们可以通过在单机开多个Redis 实例来完善！

