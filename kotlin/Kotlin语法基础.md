# Kotlin语法基础

## 1 修饰符和变量

| 修饰符 | 说明 |
| ---- | ---- |
| abstract | 抽象类/方法|
| final | 不可被继承的类/函数不可被重写|
| enum | 枚举类 |
| open | 可被继承的类/函数可被重写 |
| annotation | 注解类 |
| sealed | 密封类 |
| data | 数据类| 
| override| 重写函数/字段|
| lateinit | 延迟初始化 |
| private |私有|
| protected | 保护 |
| public| 默认值，可对外开放|
| internal|整个模块可访问|
| in | ？ Super T，消费者类型|
| out | ？ extend T，生产者类型 |
| tailrec| 尾递归 |
| operator | 运算符重载函数 | 
| infix | 中缀函数 |
| inline | 内联函数 |
| external| 外部函数|
| suspend | 挂起协程函数 |
| const | 常量修饰符|
| vararg | 边长参数变量符|
| reifield| 具体化类型参数 |

|关键字 | 说明| 关键字| 说明|
| ---- | ---- | ---- | ---- |
| package | 包 |as | 类型转换|
| typealias| 类型别名| class| 类声明|
|this|当前类|super|父类引用|
|val|不可变量|var|可变变量|
|fun|声明函数|for|循环|
|null|特殊值null|is|类型分析|
|object|单例类声明|field|成员|
|property|属性|receiver|接收者|
|param|参数|setparam|设置参数|
|delegate|委托|by|委托类或属性|
|constructor|构造函数|dynamic|动态的|
|typeof|类型定义|

## 2 流程控制语句
### 2.1 if表达式
```java
package com.easy.kotlin

fun main(args:Array<String>) {
	println(max(1,2))
}

fun max(a: Int,b: Int):Int {
	//kotlin中没有类似true? 1:0的三元表达式
	val max = if (a > b) a else b
	return max
}
```
### 2.2 when表达式

when类似Java的Switch.. Case表达式，
```java
fun caseWhen(obj: Any?) {
	when (obj) {
		0,1,2,3,4,5 -> println("${obj} ===> 这是一个0-5的数字")
		"lilei" -> println("I am ${obj},这是一个字符串")
		is Char -> println("${obj} ===>这是一个Char类型")
		else -> println("${obj} ===> default")
	}
}
fun main(args:Array<String>) {
	caseWhen(3)
	caseWhen("aha")
	caseWhen('A')
	caseWhen(null)
}
```

### 2.3 for循环
for循环可以对任何提供迭代器（iterator）的对象进行遍历
```java
for (item in collection) {
	println(item)
}
```

如果想要通过索引遍历一个数组或者一个list，可以这么做：
```java
for (i in array.indices) {
	println(array[i])
}

for ((index,value) in array.withIndex()) {
	//带下标index来访问数据
	println("the element at $index is $value")
}

```

范围（Ranges）表达式也可以用于循环
```java
for (i in 1..10) {
	println(i)
}

(1..10).forEach{println(it)}
```

### 2.4 while、break、continue
用法和Java一样

### 2.5 throw表达式
在Kotlin中 throw是表达式，它的类型是特殊类型Nothing。该类型没有值，与Java语言中的void意思一样

### 2.6 操作符

++、--、.、?.、?  => 后缀操作符
-、+、++、--、!、labelDefinition@ =>前缀操作符
:、as、as? => 右手操作符
\*、/、% =>乘除取余
\+、-
.. => 区间范围
?: => Elvis操作符  y= X?:0 相当于 val y = if(x !== null) x else 0
==、!=、===、!== 相等性判断
 
**PS：** ===表示引用相等判断，==内容相等判断 

# 类型系统与可空类型
Kotlin中去掉了原始类型，只有包装类型

Kotlin系统类型分为可空类型和不可空类型。Kotlin中引入了可空类型，把有可能为null的值单独用可空类型来表示

| Kotlin | java | 是否可空|
| ---- | ---- | ---- |
| Int | int| 否 |
| Long | long| 否|
|Float | float | 否|
| Double | double| 否|
| Int? | Integer | 是|
| Long? | Long| 是|
| Float? | Float |是 |
| Double?| Double |是|

Kotlin直接使用了8个新的类型来表示数组类型：
BooleanArray
ByteArray
CharArray
DoubleArray
FloatArray
IntArray
LongArray
ShortArray

Unit类型 类似于Java中的void，Unit?表示可空类型。Unit的父类是Any，Unit?的父类是Any?
Nothing?类型类似于Java中的Void
Any?死活可空类型的根，Any?是Any的超集
