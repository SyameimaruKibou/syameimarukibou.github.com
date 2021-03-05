---
title: 《Java编程思想 中文第4版》读书笔记
date: 2020-11-18 13:36:20
categories:
- Java
tags:
- Java
- 读书笔记
---

# 泛型

### 擦除的限制

- 不能使用**基本类型**作为<T>（实例化类型参数）
- 不能**运行时类型查询**（instanceof(), getClass()）
- 不能创建参数化类型的数组（Pair<String>[] list = new Pair<String>[10]）
- 不能实例化类型变量（new T()，T.class等），（在Java 8之后可以使用构造器表达式解决）
- 不能在静态上下文中引用类型变量
- 不能抛出或捕获泛型类实例

### 边界（< T extends SomeClass >）与通配符（<? extends T>）的区别

- **<T extends SomeClass>** 规定了泛型类的**边界**（这里的T也可以是接口），主要是为了处理**擦除**带来的问题，也就是“**规定该泛型类持有的类型至少应该是一个**SomeClass**类型或者其子类**”，这样，可以**对泛型类持有的类型做一个子集限制**（比如保证在使用T时至少具有SomeClass的方法）
- **<? extends T>** 是一种**通配符**，通配符的出现主要是为了解决**泛型容器的协变类型问题**。也就是说，在原本情况下，**不能将一个像将Son向上转型为Father一样，将**`**SampleClass<Son>**`**转型为**`**SampleClass<Father>**`**，**但是使用？通配符后就能解决这个容器类型转型的问题：`**SampleClass<? extends Father> s = new SampleClass<Son>**`。同时，如果再将该具体的继承类改为**自行指定的泛型类型**，就得到了**<? extends T>**修饰符
- 不同于泛型边界清楚直观的概念与理解，**通配符泛型具有很多限制**：

- - 对于上界 `SomeClass``**<? extends T>**`**，**可以将其读作“**持有****某种****从T类型继承的类型的容器”，**也就是说通配符？代表一种**未知的具体类型**而不是任意从T继承的类型，所以上界`**<? extends T>**`不能使用容器添加元素的**add/set**等方法（**因为add方法的签名变为：add(<? extends T> obj)而无法确定具体包含了哪种继承于T的类型**）。相对应的，由于保证容器内元素至少是一个T或继承于T的类型，所以获取容器元素的**get**等方法（向上转型赋给一个T或T的基类）是合法的：`**SomeClass<Father> obj = new SomeClass<? extends Father>**`；
  - 同理，逆变**`<? super T>`**代表“**持有是T的****某种****基类的容器**”，由于保证容器内类型是T的基类，可以保证容器添加元素（**add/set**）的合法性（只要保证该元素是**T或者T的子类型**），同样的，**get**等方法对于这种类型是非法的。

# Java I/O系统

## File类

代表一个特定文件的名称，或者代表一个目录下的一组文件的名称。

File类包含许多获取文件属性，以及重命名与删除文件和目录的方法，但是不能读写文件内容

#### 实用工具（Directory类）

`Directory.local(dir,regex)`：返回代表指定目录下的文件集合的**File对象数组**。

`Directory.walk(dir,regex)`：返回指定目录下的整个目录树（包括所有文件和子目录）

#### 目录的检查和创建

File类可以获取文件或目录的各种信息，并且可以执行重命名与删除等操作。

通过`getAbsolutePath()`,`getPath()`可以得到该File类文件的目录信息

通过`delete()`删除该File类所指向的文件

通过`mkdir()`创建以该File类结构为标准的目录



## 输入与输出

![image](https://cdn.nlark.com/yuque/0/2020/png/2481276/1599790674358-02d7347c-498f-4ae5-8020-d9b3d3bb1dec.png?x-oss-process=image%2Fresize%2Cw_1500)

**Java I/O类的结构层次**

任何自InputStream或Reader派生而来的类都含有名为**`read()`**的基本方法，同理，自OutputStream或Writer的派生类都含有名为**`write()`**的基本方法。

但是，这两个方法**一般不会直接使用**，而是提供给其他类使用以提供更有用的接口。

以输入流（`InputStream`）为例，输入流类的各个**子类的区分在于输入数据源的不同**，如从字节数组（`ByteArrayInputStream`），String对象（`StringBufferInputStream`），文件（`FileInputStream`），“管道”（`PipedInputStream`），其他数据源（Internet连接等），输出类同理

### FilterInputStream、FilterOutputStream（抽象装饰）

以上两种类是分别包装`InputStream`以及`OutputStream`的**抽象装饰类。**

其子继承类可是实现两类完全不同的行为：

1.允许**以不同基本类型**（以int，char等）（从`InputStream`或向`OutputStream`）进行读或写（如**`DataInputStream`**/**`DataOutputStream`**）；2.修改`InputStream`或`OutputStream`的**行为方式**：是否提供缓冲（如`BufferedInputStream`/`BufferedOutputStream`），是否支持回退，格式化输出（`PrintStream`）等。

### 面向字符流的Reader、Writer

Java 1.1对基本的I/O流类库进行了重大修改。虽然一些原始的“流”库不再被使用（可能收到编译器的警告信息），但是InputStream和OutputStream服务面向**字节流**的I/O，而相对的，Reader和Writer服务于面向**字符流与兼容Unicode**的I/O。

从字节流到字符流需要转换，这时候也存在两者间的**适配器类**：`**InputStreamReader**`可以将`InputStream`转化为`Reader`，同理，`**OutputStreamWriter**`将`OututStream`转化为`Writer`。

#### 两类类库间的对应关系

Java 1.1几乎对所有原本的字节流类都有对应的新的字符流类。

![QQ图片20200911110605.jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/2481276/1599793685675-6a275671-f1cf-4172-aa1f-e4e7c8ea55e2.jpeg?x-oss-process=image%2Fauto-orient%2C1%2Fresize%2Cw_1500)

#### 更改流的行为的Reader或Writer

与在字节流中提到的装饰类相同，字符流也继承的同样的思想，但是相比上表，下标的对应关系更加粗略。

![QQ图片20200911112532.jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/2481276/1599794745595-08c984a0-6f49-4703-9d3b-23136126ac35.jpeg?x-oss-process=image%2Fresize%2Cw_1500)

如果需要使用readLine()，一定不能使用DataInputStream（而是BufferReader），但是DataInputStream仍然是I/O类库的首选成员。

#### 独立的类：RandomAccessFile

`RandomAccessFile`适用于大小已知的记录组成的文件，可以使用seek()将记录从一处转移到另一处，然后读取或修改记录。

`RandomAccessFile`类似于把DataInputStream和DataOutStream组合起来使用，还添加了一些方法

JDK 1.4中，`RandomAccessFile`的大部分功能被nio存储映射文件所取代。

### 基本的读写操作

#### 缓冲输入文件

```
BufferedReader in = new BufferedReader(new FileReader(filename));
```

#### 从内存输入

```
StringReader in = new StringReader(Xxx.read("Xxx.txt"));
```

(“从内存输入”的意思：输入类除了接受文件输入之外，也可以从具有恰当返回值的类/对象方法中得到输入）

#### 基本文件输出

```
PrintWriter out = new PrintWriter( new BufferedWriter(new FileWriter(filename)));
```

在BufferedWriter基础上再包装了一层PrintWriter提供格式化输出

PrintWriter具有辅助构造器，可以不用每次都进行多次装饰，如：

```
PrintWriter out = new PrintWriter(filename);
```

### 标准I/O

Java提供**System.in**，**System.out**，**System.err**三个标准输入

System.out是一个`PrintStream`，但是System.in是一个没有被包装过的`InputStream`

#### 标准I/O重定向

通过`System.setIn(InputStream in)，System.setOut(PrintStream`` out)`` System.setErr(PrintStream err)`

可以将标准I/O重定向，将标准输入附接到文件上或者是将标准输出重定向到另一个文件。

## NIO

JDK 1.4的java.nio.*包引入了新的JAVA I/O类库，目的在于提高速度。

即使不显式使用Nio编写代码，旧的I/O也已经基于nio重新实现。

# 流库（Java SE 8）

流提供了一种让我们可以在比集合更高的概念级别上指定计算的**数据视图**。通过使用流，我们可以说明想要完成什么任务，而不是说明如何去实现他。将操作的调度留给具体实现解决。

例如，假设我们想要计算某个属性的平均值，那么我们就可以指定数据源和该属性，然后，流库就可以对计算进行优化，例如，使用多线程来计算总和与个数，并将结果合并。

## 从迭代到流的操作

在处理集合时，我们通常迭代遍历它的元素，并在每个元素上执行某项操作。例如，假设我们想要对某本书中的所有长单词进行计数，首先我们将所有单词放到一个列表中：

```
String contents = new String(Files.readAllBytes(
    paths.get("alice.txt")),StandardCharsets.UTF_8);
List<String> words = Arrays.asList(contents.split("\\PL+"));
```

现在我们可以迭代了：

```
long count = 0;
for (String w : words)
{
    if (w.length() > 12) count++;
}
```

在使用流时，相同的操作看起来像是这样：

```
long count = words.stream()
    .filter(w -> w.length() > 12)   //lambda表达式，代表一个接受参数为 (String) w，返回值为 w.length() > 12 的函数
    .count();
```

流版本的代码显然比循环版本容易理解，我们通过方法名直接就能理解代码意欲何为。

仅将stream 修改 parallelStream就可以让流库以并行方式来执行过滤和计数：

```
long count = words.parallelStream().filter(w -> w.length() > 12).count()
```

流表面上看起来和集合类似，都可以让我们转换和获取数据。但是它们之前存在显著的差异：

- 流并不**存储**其元素
- 流的操作并不修改其**数据源**
- 流的操作尽可能**惰性执行**

再分析以上的示例：

stream/parallelStream方法会产生一个用于words列表的**stream**。

filter方法返回**另一个流**，其中只包含长度大于12的单词。

count方法将这个流化简为一个结果。

这代表了操作流的典型流程：

1. 创建一个流  （对应stream()和parallelStream()）
2. 指定将初始流转换为其他流的中间操作，可能包含多个步骤  （对应filter()）
3. 应用**终止操作**，从而产生结果。这个操作会强制执行之前的惰性操作，使流失效化。（对应count()）

## 流的创建

可以用任意Collection接口的stream方法将任何集合转换为一个流。

对于数组，可以使用静态的 Stream.of 方法

```
Stream<String> words = Stream.of(contets.split("\\PL+"));
```

使用`Array.stream(array, from, to)`可以从数组中位于from（包括）和to（不包括）的元素中创建一个流。

使用`Stream.empty()`创建不包含任何元素的流

**无限流**：Stream接口有两个创建无限流的静态方法：generate方法会接受一个不包含任何引元的函数（Supplier<T>接口的对象）。任何时候需要一个流类型的值时，**该函数就会被调用以产生一个这样的值**。比如可以像这样获得一个常量值的流：

```
Stream<String> echo = Stream.generate(() -> "Echo")
```

或者这样获得一个随机数流：

```
Stream<Double> randoms = Stream.generate(Math::random)
```

为了产生类似于0 1 2 3...的无线序列，可以使用**i****terate方法**，接受一个种子值，以及一个函数（一个UnaryOperation<T>接口对象），并且**反复将该函数应用到之前的结果上。**

**`Stream<BigInteger> integers = Stream.iterate(BigInteger.ZERO, n -> n.add(BigInteger.ONE)`**

序列中的第一个元素是种子BigInteger.ZERO

## 流的转换

流的转换会产生一个新的流，它的元素派生自另一个流的元素。

### filter、map和flatMap方法

**filter**转换产生一个流，保证它的元素和某种条件相匹配，比如之前提到的使字符串流转换为只包含长单词的另一个流：

```
Stream<String> longWords = wordList.stream().filter(w -> w.length() > 12);
```

**filter**仅仅达到了筛选的效果，通常我们需要按照某种方法转换流中的值，此时，可以使用**map**方法并传递执行该转换函数。比如像这样将所有单词转换为小写：

```
Stream<String> lowercaseWords = words.stream().map(`**`String::toLowerCase`**`);
```

这里使用了带有方法应用的map，但通常我们可以使用lambda表达式代替：

```
Stream<String> lowercaseWords = words.stream().map(`**`s -> s.substring(0,1)`**`);
```

上述语句产生了包含所有字母首字母的流。

map存在的问题是，函数会应用到每个函数上，也就是说，对于**每个输入元素都会产生等量个输出**，假设我们有一个函数`letters(String s)`将一个值产生为包含多值的流（letter("boat")的返回值为流["b","o","a","t"]），那么`word.stream().map(w -> letters(w))`将会返回一个**包含流的流（[...["y""o""u""r"],["b""o""a""t"]...]）**

为了将其摊平为字母流，可以使用**flatMap**方法而不是map方法。

```
Stream<String> flatResult = words.stream().flatMap(w -> letter(w));
```

### 抽取子流与连接流

`**stream.limit(n)**`：将返回一个新的流，它在n个元素之后结束。这个方法对于裁剪无限流的尺寸时会显得非常有用。

**`stream.skip(n)`**：和limit相反。丢弃前n个元素。

`**stream.concat**`**：**连接两个流

### 其他的流转换

`**distinct()**` **:**将原来的元素剔除重复元素产生新的流

**排序**：对于流的排序有多种sorted()方法的变体可用。其中一种可以接受一个**Comparator**。下面的例子将最长的字符串排在最前面：

```
Stream<String> longestFirst = words.stream().sorted(Comparator.comparing(String::length).reversed());
```

`**peek()**`**：**peek方法会产生一个元素与原流中元素相同的流，但是在每次获取一个元素时，**都会调用一个函数**。这对于调试来说很方便：

```
Object[] powers = Stream.iterate(1.0, p -> p*2)
.peek(e -> System.out.println("Fetching " + e).limit(20).toArray();
```

上述语句每次实际访问一个元素的时候就会打印出来一条消息。（可以用来验证iterate返回的无限流的惰性处理性）

### 流的约简

约简是一种流的**终结操作（terminal operation）**

**简单约简：**

**count**()是我们已经见过的一种简单约简，该方法返回流中元素的数量

**max**和**min**也是一种简单约简，接受一个Comparator，返回流的最大最小值。

这些约简方法会返回一种 **Optional<T>** 类型的值，它要么在其中包装了答案，要么没有任何值（流为空）。

下面展示了如何获得流中的最大值：

```
Option<String> largest = words.max(String::compareToIgnoreCase);
System.out.println("largest:" + largest.orElse(""));
```

**findFirst** 返回非空集合中的第一个值，一般和 filter 组合使用。以下语句展示如何找到第一个以 Q 开头的词：

```
Optional<String> startsWithQ =  words.filter(s -> s.startWith("Q").findFirst();
```

**findAny** 不限制值一定是第一个匹配，对于并行流处理很有效：

```
Optional<String> startsWithQ = words.parallel().filter(s -> s.startsWith("Q")).findAny();
```

**anyMatch** 只关注是否存在匹配。这个方法接受一个断言（**Predicate<? super T>**）引元而不需要使用 filter ：

```
boolean aWordStartsWithQ = words.parallel().anyMatch(s -> s.startsWith("Q");
```

还有对应的 **allMatch** 和 **noneMatch** 方法，分别在所有元素和没有任何元素匹配断言的情况下返回true。

### Optional 类型

Optional<T>对象是一种包装器对象，要么包装了类型T的对象，要么没有包装任何对象。

Optional<T>类型被当作一种更安全的方式代替类型T的引用。

#### 正确的使用

正确使用Optional的关键是使用这样的方法：在**值不存在的时候产生一个可替代物，或者在值存在时才会使用该值。**

第一种策略（在值不存在的时候产生一个可替代物）可以有这些实现：

```
//没有匹配时产生空字符串
String result = optionalString.orElse(""); 
//没有匹配时调用代码计算默认值
String result = optionalString.orElseGet(() -> Locale.getDefault().getDisplayName());
//没有任何值时抛出异常
String result = optionalString.orElseThrow(IllegalStateException::new);
```

另一种策略（仅当值存在才使用该值）：

**ifPresent** 方法会接受一个函数：如果可选值存在，那么它会被传递给该函数。否则，不会发生任何事：

```
optionalValue.isPresent(v - > obj.foo(v));
```

调用 ifPresent 时，该函数不会返回任何值。如果需要处理函数结果，应该使用map:

```
OptionalValue.ifPresent(result::add);
```



# 反射与类型信息

**Java的反射机制可以说是RTTI（****Run-Time Type Identification）运行时类型识别的一种实现方式，我们可以将RTTI分成传统RTTI和反射两种，其中：**

- **传统RTTI：在编译时打开和检查.class文件，即编译时已经知道了所使用类相关的所有类型信息**
- **反射：运行时打开和检查.class文件**

## Class对象

类是程序的一部分，每个类都有一个Class对象，**每当编写并且编译了一个新类，就会产生一个Class对象**

- **Class.forName(String className)**

该静态方法接受一个【用全限定名】表示的类名字符串，返回所查找的Class对象，如果没找到，返回ClassNotFoundException。

- **(Class)someClass.newInstance()**

对一个Class对象使用，达到类似“虚拟构造器”的效果，返回一个Object引用，引用指向该someClass的具体对象。

该方法要求 someClass 必须具有默认构造器。

- **SomeClass.Class**

**类自变常量**。可以比forName()更方便的地获得Class对象，也可以用于接口，数组以及基本数据类型。

### 泛型化的Class<T>SomeClass

由于一般的 Class 引用指向 Class 对象没有任何限制，比如以下的场景：

```
Class intClass = int.Class;
intClass = double.Class;
```

这种使用方法既不会报错也不会警告，如果想要进行一定限制，可以使用泛型语法

```
Class<Integer> intClass = int.Class
```

以上语句保证 intClass 只能被指向 int 的Class对象，但是和泛型语法类似，不能被指向其继承类的类对象

为此引入通配符：在没有限定情况下`Class<?>`起的作用与一般的 Class 等价，不过这种写法可以减少误解，表明原本就是要创建一个非具体的 Class 。而如果为? 添加限定可以起到与泛型类容器类似的作用：

```
Class<? extends Number> bounded = int.class
```

当然，所有的泛型语法知识为了为 Class 提供**编译器类型检查**

### instance of

**利用instance of ，使用提问的方式（在进行类型转换前）判断某个对象是否属于某个类型的示例，如：**

```
**if(x instance of SomeClass) ((SomeClass)x.foo())**
```

instance of 的使用有一定限制，即比较的对象必须是命名类型，而不能使用 Class 对象

### 动态instanceof：Class.isInstance()

由于instance of 不支持动态的Class对象比较，可以使用 Class.isInstance() 

```
classObj.isInstance(someObj)
```

### 使用Class引用比较与使用instanceof类方法的区别

- instanceof()和isIntance()在比较结果上一致，当被**比较类是目标类或者目标类的派生类时即合法**
- 使用Class引用直接比较（equals，==）时，仅当**两个类是同一类时合法**