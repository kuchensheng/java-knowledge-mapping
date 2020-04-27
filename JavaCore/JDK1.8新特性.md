# Java 8 新特性
Java 8 （又称为jdk1.8）是Java语言开发的一个主要版本。它支持函数式编程，新的JavaScript引擎，新的日期API，新的Stream API等。
# 1. 新特性
Java 8 新增了非常多的特性，主要有：
* Lambda表达式：Lambda允许把函数作为一个方法的参数（函数作为参数传递进方法中）。
* 方法引用：方法引用提供了非常有用的语法，可以直接引用已有Java类或对象的方法或构造器。与Lambda联合使用，方法引用可以使语言的构造更紧凑简洁，减少冗余代码。
* 默认方法：一个接口里面有一个实现的方法。
* 新工具：Nashorn引擎jjs、类依赖分析器jdeps。
* Stream API：把真正的函数式编程风格引入Java中
* Date Time API：加强对日期与时间的处理
* Optional类：Optional类用来解决空指针异常
* Nashorn，JavaScript引擎：它允许我们在JVM上运行特定的JavaScript应用。

# 2. 编程风格
```java
//使用Java 7 排序
Collections.sort(names,new Comparator<String>() {
    @Override
    public int compare(String s1,String s2) {
        return s1.compareTo(s2);
        }
    });

//使用Java 8排序
Collections.sort(names,(s1,s2) -> s1.compareTo(s2));
```

# 3. Lambda表达式
## 3.1 Lambda表达式简洁
也称闭包，它是推动Java 8 发布的最重要的新特性。它允许把函数作为一个方法的参数。使用Lambda表达式可以使代码变的更加简洁紧凑。它有以下几个特征：
+ 可选类型声明：不需要声明参数类型，编译器可以统一识别参数值
+ 可选的参数圆括号：一个参数无需定义圆括号，但多个参数需要定义圆括号
+ 可选大括号：如果主体句包含一个语句，就不要使用大括号
+ 可选的返回关键字：如果主体只有一个表达式返回值则编译器会自动返回值，大括号需要指明表达式返回了一个数值。

## 3.2 Lambda表达式实例
```java
//1. 不需要参数，返回值为5
() -> 5
//2.接收一个参数（数字类型），返回其2倍的值
x -> 2*x
//3.接收2个参数（数字），返回他们的差值
(x,y) -> x-y
// 4. 接收2个int型整数,返回他们的和  
(int x, int y) -> x + y
// 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)  
(String s) -> System.out.print(s)
```

# 4. 方法引用
方法引用通过方法的名字来指向一个方法。方法引用使用一对冒号::

+ 构造器引用。他的语法是Class::new,或者更一般的Class<T>::new。实例如下：
```java
@FunctionalInterface
public interface Supplier<T> {
    T get();
}
 
class Car {
    //Supplier是jdk1.8的接口，这里和lamda一起使用了
    public static Car create(final Supplier<Car> supplier) {
        return supplier.get();
    }
 
    public static void collide(final Car car) {
        System.out.println("Collided " + car.toString());
    }
 
    public void follow(final Car another) {
        System.out.println("Following the " + another.toString());
    }
 
    public void repair() {
        System.out.println("Repaired " + this.toString());
    }
}
final Car car = Car.create(Car::new);
final List<Car> cars = Arrays.asList(car);
```
+ 静态方法引用。语法是Class::static_method
```java
cars.forEach(Car::collide);
```
+ 特定类的任意对象的引用，它的语法是Class::method
```java
cars.forEach(Car::repair);
```
+ 特定对象的方法引用，语法是instance::method
```java
final Car police = Car.create(Car::new);
cars.forEach(police::follow);
```
