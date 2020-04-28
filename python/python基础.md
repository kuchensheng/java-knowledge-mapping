# 变量
python变量就是个名字。
例如。
```
>>> devloper="库陈胜"
>>> print(teacher)
库陈胜

>>> wife="宝贝"
>>> childeren = devloper + wife
库陈胜宝贝
```
**注意：**
- 使用变量前，需要对其先赋值
- 变量名可以包括字母、数字、下划线，单变量名不能以数字开头。
- 字母可以是大小写，但是大小写含义不同。

# 字符串
- 特殊字符，使用转义，例如>>>print('Let\'s go');
- 使用原始字符串，例如>>>print('C:\now'),由于\n属于换行符，，**若使用原始字符串，需要在字符串前加一个字母'r'**
```
>>>string = r'C:\now'
>>>string
'C:\\now'
>>>print(string)
C:\now
```
- 字符串不能以反斜杠\结尾
- 长字符串，使用三重引号("""这里是长内容""")

# 分支条件
```
if 条件 :
	条件为真，执行的操作
else :
	条件为假，执行的操作
```
# while循环
while 条件:
	条件为真执行的操作

# 引入其他类
```
#test.py
import random
/*引入random类*/
secret = random.randint(1,10)
temp = input("输入一个数字：")
guess = int(temp)
while guess != secret:
	temp = input("猜错了，再来一次：")
	guess = int(temp)

	if guess == secret:
		print("猜对了，宝贝儿")
	else:
		if guess > secret:
			print("大了")
		else
			print("小了")
print("游戏结束")
```

# 数据类型
+ 整型，长度不受限制，只限于计算机的虚拟机内存数，所以Python很容易进行大数计算
+ 浮点型，Python区分整型和浮点型的唯一方式，就是看有没有小数点。可以用E表示特大或特小的数。 例如 2.5e-21=0.000 000 000 000 000 000 002 5,E是指数，底数为10，E后边就是10的幂。
+ 布尔类型，可以将布尔类型当做特殊整型来看待，例如：True+True = 2；True * False = 0；True/False 异常，0不能作为除数。**尽量不要这样去用**
+ 类型转换
- int()将字符串或浮点型转换为整数
- float()将字符串或整数转换成一个浮点数
- str()将一个数或任何其他类型转换成一个字符串
+ 类型信息
- type()获取类型信息。例如：type('520') <class 'str'>
- isinstance()来确定类型，例如：isinstance('520',str) 返回结果为true则表示类型匹配

# 常用操作
`+ - * / % ** //`
python真正的用除法代替了floor方式，比如 
```
>>> 3 // 2
1
>>> 3.0 // 2.0
1.0
>>> 10 / 8
1.25
>>> 5 % 2
1
```
**python特殊乘法，（\*\*）**也称为幂运算操作符，例如 3 \*\* 2表示，3的2次幂 为 9

# 逻辑操作符
```and not or```
python 允许 3 < 4 < 5成立，这相当远 3 < 4 and 4 < 5

# 条件表达式
a = x if 条件 else y
例如：small = x if x < y else y

# 断言
当关键字assert后面的关键字为假时，程序自动崩溃并抛出AssertionError异常
assert 3 > 4 异常

# 循环语句
## for循环
python的for循环自动调用迭代器的next()方法，会自动捕获StopIteration异常并结束循环
```
favourite = "库陈胜"
for each in favourite :
    print(each,end='')
执行结果 库陈胜
```
## range()
语法：range([start],stop[,step=1])
示例：
```
for i in range(5):
    print(i)
for j in range(2,9):
    print(j)
for k in range(1,10,3):
    print(k)
```
## break/continue语句
break语句的作用是终止当前循环体，
continue跳过这次循环

# 列表、元组合字符串
## 列表
Python的变量没有数据类型，所以Python是没有数组的。但是可以创建一个鱼龙混杂的列表。
- **append()**:添加元素
- **extend()**:使用一个列表来扩展另一个列表
- **insert(index,val)**:往列表中插入元素，两个参数表示位置和值
- 通过索引值获取元素
```

```