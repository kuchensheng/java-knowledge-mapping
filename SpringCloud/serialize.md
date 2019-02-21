# 分布式服务框架序列化和反序列化
## 序列化原理
+ 序列化是将对象的状态信息转换为存储或传输的形式过程。简言之，把对象转换为字节序列化的过程称为对象序列化
+ 反序列化是序列化的逆过程。将字节数组发序列化为对象，把字节序列恢复为对象的过程称为反序列化。

序列化能帮助我们解决如下问题：
- 通过将对象序列化为字节数组，使得不共享内存通过网络连接的系统之间能够进行对象传输
- 通过将队形序列化为字节数组，能够将对象永久存储到存储设备
- 解决远程调用JVM之间内存无法共享的问题

# 集中常用的序列化实现

## 2.Java默认序列化
被序列化的类需要实现java.io.Serializable接口。

**优点**

* Java自带，无需引入三方包
* 与Java语言最为亲和与易用

**缺点**

* 只支持Java语言，不能跨语言
* 序列化后产生的码流过大，对于引用过深的对象序列化后易发生OOM异常

## 3.XML序列化
XML序列化的优势在于可读性好，利于调试。因为使用标签来表示数据，导致序列化后码流大，而且效率不高。适用于对性能要求不高，且QPS较低的企业级内部系统之间的数据交换场景。代码如下：

**引入jar包**

```xml
<dependency>
    <groupId>com.thoughtworks.xstream</groupId>
    <artifactId>xstream</artifactId>
    <version>1.4.10</version>
</dependency>
```
**代码实例**

```java
public class XmlSerializer implements ISerializer {
    private static volatile XStream xStream = null;

    @Override
    public <T> byte[] serialize(T obj) {
        return getxStream().toXML(obj).getBytes();
    }

    @Override
    public <T> T desrialize(byte[] data, Class<T> clazz) {
        return (T) getxStream().fromXML(new String(data));
    }

    private XStream getxStream() {
        if(null == xStream) {
            synchronized (XmlSerializer.class) {
                if(null == xStream) {
                    xStream = new XStream(new DomDriver());
                }
            }
        }
        return xStream;
    }
}

```

## 4.JSON序列化
JSON是一种轻量级的数据交换格式。相对于XML，JSON码流更小，且保留了XML可读性好的优势。

**引入jar包**

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.41</version>
</dependency>
```

**java 实例**

```java
public class JsonSerializer implements ISerializer {
    @Override
    public <T> byte[] serialize(T obj) {
        return JSON.toJSONString(obj).getBytes();
    }

    @Override
    public <T> T desrialize(byte[] data, Class<T> clazz) {
        return JSON.parseObject(new String(data),clazz);
    }
}
```

## 5.Hessian序列化
Hessian是一个支持跨语言传输的二进制序列化协议。Hessian具有更好的性能与易用性，而且支持多种不同的语言。
```xml
<dependency>
    <groupId>com.caucho</groupId>
    <artifactId>hessian</artifactId>
    <version>4.0.51</version>
</dependency>
```
```java
public class HessianSeializer implements ISerializer {
    @Override
    public <T> byte[] serialize(T obj) {
        if(null == obj) {
            throw new NullPointerException();
        }
        try {
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            HessianOutput hessianOutput = new HessianOutput(byteArrayOutputStream);
            hessianOutput.writeObject(obj);
            return byteArrayOutputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public <T> T desrialize(byte[] data, Class<T> clazz) {
        if(null == data) {
            throw new NullPointerException();
        }
        try {
            ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
            HessianInput hessianInput = new HessianInput(byteArrayInputStream);
            return (T) hessianInput.readObject();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
```
## 6.protostuff序列化
独立于语言，独立于平台，是一个展示层协议，可以和各种传输层协议一起使用。空间开销小、解析性能高，非常适合于公司内部对性能要求高的RPC调用。
```xml
<dependency>
    <groupId>com.dyuproject.protostuff</groupId>
    <artifactId>protostuff-core</artifactId>
    <version>1.1.3</version>
</dependency>
<dependency>
    <groupId>com.dyuproject.protostuff</groupId>
    <artifactId>protostuff-runtime</artifactId>
    <version>1.1.3</version>
</dependency>
<dependency>
    <groupId>org.objenesis</groupId>
    <artifactId>objenesis</artifactId>
    <version>2.6</version>
</dependency>
```
```java
public class ProtoStuffSerializer implements ISerializer {
    private static Map<Class<?>,Schema<?>> cachedSchema = new ConcurrentHashMap<>();

    private static Objenesis objenesis = new ObjenesisStd(true);
    @Override
    public <T> byte[] serialize(T obj) {
        Class<T> cls = (Class<T>) obj.getClass();
        LinkedBuffer buffer = LinkedBuffer.allocate(LinkedBuffer.DEFAULT_BUFFER_SIZE);
        try {
            Schema<T> schema = getSchema(cls);
            return ProtostuffIOUtil.toByteArray(obj,schema,buffer);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            buffer.clear();
        }
    }

    private <T> Schema<T> getSchema(Class<T> cls) {
        Schema<T> schema = (Schema<T>) cachedSchema.get(cls);
        if(null ==  schema) {
            schema = RuntimeSchema.createFrom(cls);
            cachedSchema.put(cls,schema);
        }
        return schema;
    }

    @Override
    public <T> T desrialize(byte[] data, Class<T> clazz) {
        try {
            T messsage = (T) objenesis.newInstance(clazz);
            Schema<T> schema = getSchema(clazz);
            ProtostuffIOUtil.mergeFrom(data,messsage,schema);
            return messsage;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
```




