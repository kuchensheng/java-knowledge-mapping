# 我为什么学习Kotlin
言而总之，**在不牺牲性能或安全的前提下，许多Kotlin功能使代码更简洁**，是Kotlin最吸引我的地方

## Kotlin是什么
Kotlin是一种非研究性并且非常务实的工业级编程语言，它的使命就是帮助程序员解决实际工程实践中的问题。使用Kotlin语言让Java程序员的工作变得更轻松，Java语言中的那些空指针错误、浪费时间的冗长的样板代码、啰嗦的语法限制等，在Kotlin语言中统统消失。
Kotlin语言简单、务实，语法简洁而强大，安全且表达力强，极富生产力。

Kotlin是一种基于JVM的静态类型编程语言。Kotlin编译为字节码，因此其性能与Java 一样好。它具有与Java 相同的编译时检查。最重要的是Kotlin的语言功能和标准库功能可实现简洁高效的代码。

简洁，因为这是提高程序员工作效率的一种工具

## 为什么喜欢Kotlin
Kotlin的优势：Kotlin的优势是既有Java的完整生态（Kotlin完全无缝使用各类JavaAPI框架库），又有现代语言的高级特（语法糖）。
- 与Java 和JVM 完全互操作性
- 多平台，适合Android、浏览器（JavaScript）和本地系统编程（native）
- 语法简洁，不罗嗦（重要）
- 支持类型判断，我们可以只写val number=23,编译器会自动推断这个类型为Int
- 提供了实用强大的函数式编程支持：一等函数支持，Lambda表达式、高阶函数等；
- 集成扩展了简单实用的文件I/O、正则匹配、线程等工具类；
- Kotlin含有功能丰富的集合类Stream API；
- 区分可空类型和不可空类型。直接在编译期语法层面检查可空类型，提供空安全保障；有效避免诸如Java的非空判断等防御性代码
- 快速、方便地扩展内置类、自定义类的函数与属性
- IntelliJIDEA开发工具的一等支持

Kotlin语言特性：
- 实用主义：Kotlin是一门偏重工程实践、编程上有极简风格的语言
- 极简主义：Kotlin语法简洁优雅不啰嗦，类型系统中一切皆是引用（reference）
- 空安全：Kotlin中有一个简单完备的类型系统来支持空安全
- 多范式：Kotlin同时支持OOP与FP编程范式。各种编程风格的组合可以让我们更加直接地表达算法思想和解决问题的方案，可以赋予我们在思考上有更大的自由度和灵活性
- 可扩展：Kotlin可直接扩展类的函数与属性（extension functions &properties）。这与我们在Java中经常写的util类是完全不一样的体验！Kotlin是一种非常注重用户体验的语言
- 高阶函数与闭包：otlin的类型中，函数类型（function type）也是一等类型（first class type）。在Kotlin中可以把函数当成值进行传递，这直接赋予了Kotlin函数式编程的特性，使用Kotlin可以写出一些非常“优雅”的代码。
- 没有分号！！！！

## 举个栗子
### 告诉世界，我来了
```
package com.easy.kotlin 
fun main(args: Array<String>) { 
    val name = "World"
    println("Hello,$name!") 
}
```
说明如下：
（1）：Kotlin中包package的使用与Java基本相同。有一点不同的是Kotlin的package命名可以与包路径不同(可以是相对路径)
（2）：Kotlin变量声明args:Array类似于Pascal，先写变量名args，冒号隔开，再在后面写变量的类型Array。与Scala和Groovy一样，代码行末尾的分号是可选的，在大多数情况下，编译器根据换行符就能够推断语句已经结束。Kotlin中使用fun关键字声明函数（方法），充满乐趣的fun。
（3）：Kotlin中的打印函数是println()（虽然背后封装的仍然是Java的System.out.println()方法）。Kotlin中支持字符串模板$name，如果是表达式，则使用${expression}语法。

### 告诉Java，我来了
```
fun getArrayList(): List<String> { 
    val arrayList = ArrayList<String>() 
    arrayList.add("A")
    arrayList.add("B")
    arrayList.add("C")
    return arrayList
}
## 或者可以这样
fun getArrayList() = arrayListOf("A","B","C")

## 甚至可以这样
fun getArrayList() = listOf("A","B","C")
```
说明如下。
（1）：声明了一个返回List<String>的函数，我们看到在Kotlin中使用fun关键字来声明函数。
（2）：创建了一个ArrayList<String>对象，我们可以看到，在Kotlin中创建对象不再使用new关键字了，尖括号里面的String是泛型信息。该语法与Java语言基本类似。

### 告诉测试JUnit，我可以的
```
pacakage com.easy.kotlin

import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class FullJavaIntercepteroperabilityTest {
    @Test
    fun test() 
        val list = getArrayList()
        Assert.assertTrue(list.size ==3 )    
    }
}
```
说明如下：
- 是包声明，使用package关键字。
- 使用import导入JUnit4类。
- Kotlin中使用@RunWith注解，方式与Java语法类似。注解中的参数是JUnit4::class，是JUnit4类的引用。我们将在第12章中介绍注解与反射。
- 使用JUnit的@Test注解来标注这是一个测试方法。
- 调用被测试函数getArrayList()。
- 使用JUnit的Assert类的API进行断言操作。
