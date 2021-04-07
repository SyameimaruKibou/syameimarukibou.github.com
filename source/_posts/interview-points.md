---
title: Java/后端方向 面试常见知识点整理（未完成）
date: 2021-03-14 00:09:42
categories: 面试经验
tags:
- Java
- 编程思想
- Linux
- MySQL
- Redis
---

> 前言：
>
> 由个人整理而得，内容来自于参考书籍+各大网络博客+牛客面经等并加上一些个人的简化与理解，仅作为个人知识收集与学习用，如果涉及知识权问题会及时删除（联系email: zhangkibou283@foxmail.com）
>
> 对于有参考的内容，尽可能地在理解后使用个人语言进行了简化，以知识点的理解为主，缺乏准确性
>
> 推荐活用右侧【目录大纲】功能方便快速查阅（移动版的位置在悬浮按钮上）
>
> 👇参考了这些大牛的个人博客和内容：
>
> https://crossoverjie.top/JCSprout
>
> https://github.com/yuanguangxin/LeetCode/blob/master/Rocket.md
>
> 👇参考较多的一些书籍：
>
> 《深入理解 Java 虚拟机 ——JVM 高级特性与最佳实践》
>
> 《MySQL 技术内幕 ——InnoDB存储引擎》
>
> 《Redis 设计与实现》

~~来背点八股文~~

## 多线程

### 线程

#### 与进程的区别

- **调度粒度：**进程是OS资源分配的最小单位，线程是 CPU 任务调度的最小单位
- **数据共享：**不同进程之间数据难以共享，同一进程下不同线程数据容易共享
- **创建开销：**创建和切换线程的消耗更小（切换只需要保存和设置少量寄存器）
- **资源分配：**系统不会额外为线程再分配内存
- **依存关系：**一个线程挂掉且不正确捕捉错误会导致整个进程挂掉

#### 线程安全的定义

**不用考虑这些线程在运行时环境下的调度和交替执行，也不需要进行额外的同步，使用这个资源的行为都可以获得正确的结果**，则线程安全

#### 线程同步措施

- 非语言的通用措施：互斥对象，临界区，信号量，事件
- Java的实现：互斥对象（ReenTrantLock，synchronized对象），临界区（synchronized块），事件（wait,notify,join），信号量（阻塞队列）

### 进程

#### 线程通讯

较多数据：

- **共享存储**：开辟一块内存空间，将这个空间映射到进程虚拟地址上。速度快和承载量较大但是需要额外同步措施，并且只能单机间操作
- **消息队列**：点对点或者以信箱为媒介，通过消息队列的方式读取数据，支持随机查询并且适用性高，独立进程存在，缺点是速度较慢
- **管道通讯**：分为有名和无名两种。单向通讯，通过FIFO的信息流缓冲进行通讯。速度比消息队列更快，缺点是无法随机读写

少量数据：信号量

#### 调度

- 按提交顺序，按作业时间，按优先级
- 按响应比（等待时间/作业时间）
- 时间片、多级反馈（综合时间片和优先级附带年龄机制）
- Linux：动态优先级，不同优先级获得不同时间片，抢占，就绪态队列通过红黑树维护。达到的效果基本上就是高优先级获得较多运行时间，低优先级获得较低时间，同时权重可以动态变化使各个线程调度，并且支持抢占

### 1. 死锁四个必要条件

互斥条件：资源独占排他

不可剥夺条件：其他进程无权剥夺进程获得的资源

请求和保持条件：进程在申请它所需的一部分资源的时候，继续占用已分配的资源

循环等待条件：存在等待环路

### 2. synchronized 关键字原理

和锁类不同，synchronized 是 JVM 层级的指令。

**目标：**

synchronized 普通方法：锁住当前对象

synchronized 静态方法：锁住当前 Class 对象

synchronized 块：锁住 （）中的对象

![image-20210323102722355](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210323102722355.png)

重量锁的情况下，JVM 通过进入，退出对象监视器（Monitor）来实现对方法、同步块的同步。类似于获取互斥量，如果获取不到则会阻塞在方法入口处，等待其他线程 exit 后才能继续尝试获取锁

在 JDK 1.6 之前称为重量锁，之后引入了 偏向锁 和 轻量锁

#### 偏向锁

特征是一个线程在没有损耗的情况下多次获得该锁，**偏向锁**的获取优先于**轻量锁**进行

当线程访问同步块时，会使用 CAS **直接将线程 ID 更新到锁对象的 MW 中**，如果更新成功则获得**偏向锁**，并且之后每次进入这个对象锁相关的同步块时都不需要再次获取锁了。

如果线程在执行期间有另外线程 CAS 失败，则升级到轻量锁

释放锁的时机：当有另外一个线程获取这个锁时，持有偏向锁的线程就会释放锁，释放时会等待全局安全点(这一时刻没有字节码运行)，接着会暂停拥有偏向锁的线程，根据锁对象目前是否被锁来判定将对象头中的 `Mark Word` 设置为无锁或者是轻量锁状态。

可以提高竞争少的同步程序性能

#### 轻量锁

当代码进入同步块时，如果同步对象为无锁状态时，当前线程会在栈帧中创建一个**线程私有的锁记录(`Lock Record`)区域**，同时将锁对象的对象头中 **`Mark Word` 拷贝到锁记录**中，再尝试使用 `CAS` 将 `Mark Word` 更新为指向锁记录的指针。（栈帧锁记录：MW。MW：指向锁记录）

如果更新成功，当前线程就获得了锁。

如果更新失败 `JVM` 会先检查锁对象的 `Mark Word` 是否指向当前线程的锁记录。

如果是则说明当前线程拥有锁对象的锁，可以直接进入同步块。

不是则说明有其他线程抢占了锁，如果存在多个线程同时竞争一把锁（多次CAS失败），**轻量锁就会膨胀为重量锁**。

解锁时也**利用 CAS ，尝试用锁记录替换回对象的 MW** ，如果不成功说明有其他线程在尝试获取锁，那么就唤醒挂起的线程。（此时已经是重量锁）

### 3. volatile 作用

用于保证可见性和顺序性。

**可见性：**volatile 修饰的变量被更新时，将立刻**刷新到主线程，同时将 cache 内该变量其他值清空**，导致其余线程仅能去内存中读取值

**顺序性：**volatile 可以保证对修饰对象的操作顺序性，不会被JVM重排，防止多线程时出现可能的问题

### 4. ReentrantLock 实现原理

一个 **重入锁** 类，基于 AQS(AbstractQueuedSynchronizer) 实现

有**公平锁**和**非公平锁**两种，默认为非公平锁

通常的使用结构：

```java
private ReentrantLock lock = new ReentrantLock();
    public void run() {
        lock.lock();
        try {
            //do bussiness
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
    }
```

基本过程（简略版的）：

1. 根据 **state 判断**该锁是否未占用，如果未占用，用 **CAS 尝试修改state**（state用 volatile 修饰）
2. 如果获取锁失败，进入队列（通过自旋和CAS保证一定进入队列），然后将自身线程挂起
3. 在队列中时，如果被唤醒后尝试获取锁
4. 由于是重入锁，释放时会保证 state 减到 0 才认为锁被完全释放了

公平锁和非公平锁在 1. 和 3. 

非公平锁（**抢占**）：在 1. 步不管队列情况，直接尝试获取锁。在 3. 步也是只要唤醒就尝试获取锁

公平锁（**排队**）：在 1. 步检查队列情况，如果队列有人则不会尝试获取锁（排队）。在 3. 步唤醒后，先检查自己队列前面是否还有人，如果有则不尝试获取，直接阻塞

公平锁的队列顺序获取锁会造成大量的线程上下文切换。

### 5. HashMap 实现

**基本要素：**

数组+链表/红黑树。**容量**（默认16），**负载因子**（0.75），**扩容倍数**：2（原因：保持map的2^n大小；减少元素移动）

put方法：

将传入的 Key 哈希后再对数组长度位运算，计算数组中的 index 下标

位运算比取模效率高得多，所以 HashMap 规定数组长度 2^n ，这样和取模结果一致。

如果出现 Hash 碰撞，那么会在该位置头插法插入链表

get方法：

传入 key 计算 index，如果位置上是链表则遍历，通过 equals 得出对应元素

#### JDK1.8 变动

从头插改为了尾插，避免死链（但是本身它仍然是一个非线程安全的容器）

当 hash碰撞之后写入链表的长度超过了阈值(默认为8)并且 table 的长度不小于64(否则扩容一次)时，链表将会转换为**红黑树**。

#### 哈希冲突措施

- 开放定址：即根据本次哈希结果p1基础再按某种规则生成下一个新结果p2，然后再重复哈希
  - 线性探测：放到下一个单位
  - 伪随机：随机数
- 再哈希：构建一个备用哈希函数（HSn）专门给第n次hash使用，特点是每次哈希的计算方式不同
- 链地址：使用较多的方法，将所有哈希位置更改为链表或其他存储结构，然后将重复的元素组织在同一位置
- 溢出表：另外专门分开一个溢出表部分

### 6. ConcurrentHashMap 实现

#### JDK1.7实现：
结构：

**Segment** 数组，HashEntry 数组，与 HashMap 一样的【数组加链表设计】

ConcurrentHashMap 采用分段锁，Segment部分是继承于 【ReentrantLock】，这使得Segment不会像 HashTable 一样不管是put 还是 get 都需要同步，理论上CHMap支持Segment数量级别的线程并发，**一个Segment的锁占用不影响其他Segment**

get 方法：不需要加锁，只需要hash定位Segment，且再hash定位到具体元素即可（两次Hash）

put 方法：对应Segment加锁，再更新

size 方法：

缺点：段较多时会【浪费空间】；在竞争同分段概率较小的情境下put操作【加锁浪费时间】；段较大时会使性能下降

#### JDK1.8实现：

取消了 Sagment 以及其分段锁，用**Node数组+链表/红黑树**的数据结构来实现，类似于原本的HashSet，存放数据的 HashEntry 改为 Node ，作用差不多

get 方法：用计算的 hashcode 寻址，如果在 Node 上直接返回，如果没有根据 Node 所指向数据结构的差别寻址（链表或红黑树）

put 方法：val 本身使用 volatile修饰，计算出 hashcode 并定位后，如果可以写入（为空），**先通过 CAS 尝试写入**，失败则会自旋。否则（不为空），**改为 synchronized 锁写入**。

### 7. 线程 / 线程池

#### Java中的线程

##### 实现

Java 中的线程（在JDK1.2之后）基于操作系统原生线程模型实现

对于 SUN JDK 的 Windows，Linux 版，使用 **一对一** 的线程模型

在 Solaris 平台上则是同时支持**一对一**以及**多对多**的线程模型

##### 状态

创建（创建Thread对象），可运行（运行和待运行），【阻塞（拿不到Monitor锁），等待（其他阻塞），计时等待（其他计时阻塞）】，终止

##### 创建方式与区别

创建方式：

- 创建一个实现 Runnable 接口的运行类，然后将该类实例传给 Thread 类创建 Thread 对象，并start（也可通过 lambda 表达式进行）
- 继承 Thread 类并实现 run() 方法，创建这个继承类的对象对象并start
- 通过线程池创建（最终通过 new Thread() 创建）
- 其他（Callable，Timer）

实际上都是**通过创建一个 Thread 类对象来创建线程**，对于 Runnable 接口和 Thread 类来说只是线程内容运行的不同（Runnable 方式可以视为一种函数式接口去定义 Thread 运行内容）

最好是通过实现 Runnable 方式来创建，这样可以将线程本身的设置与运行业务代码分隔开

##### 各个方法

**run()**：每个 Thread 类都要实现的方法，如果直接调用效果和单线程一致

**start()：**新起一个线程执行run()，主线程不阻塞继续运行

**yield()：**告知JVM愿意让出处理器，但是不一定会被真的占用。只会将一个线程的状态从 Running 变为 Runnable 而不是 wait/blocked

**join()：**使得调用 join() 的环境线程的开始被关联到另一个线程的结束上。如果对一个线程调用了 join，那么当前 running 的线程会被 block 到直到那个线程执行结束

**sleep()：** 强制需要时间作为参数，阻塞调用的线程直到倒计时结束（不会释放锁）

**wait()**：释放锁并且并 sleep()，和 join 的区别是需要被显式 notify 来退出阻塞状态

**notify()**：释放当前锁定对象上使用了 wait() 的一个线程，注意这个线程还必须等到 notify() 的调用者退出 synchronized 释放锁才能运行

#### 线程池的参数，种类和使用的好处

**好处：**

- 线程可**复用**，减少线程建立与销毁的开销
- 控制线程**数量**，随情况调整
- 实现线程的**统一管理**（统一开始与结束，数据统计）

**参数：**

corePoolSize				能够同时工作的核心线程数（再提交任务会放入 workQueue）
maxPoolSize					线程池最大线程数（超过该线程数后会拒绝任务）
keepAliveTime+时间			线程数多余 corePoolSize 时，这些线程的保活时间
ThreadFactory				线程工厂的种类
workQueue					阻塞队列的种类
Handler						任务拒绝策略

**种类：**

线程数固定值，Queue容量无限制

- FixedThreadPool
- SingleThreadExecutor

Queue容量0，线程数无限制

- CachedThreadPool

加上定时运行（Queue容量仍无限制）

- ScheduledThreadPool
- SingleThreadScheduledExecutor

包含子任务

- ForkJoinPool

阿里的开发规范要求我们尽量自行创建提供全参数的 **ThreadPoolExecutor** 而不是 Executors.newPool() 预定义的线程构造方法，避免（Queue和线程数无限制引起的）OOM

如果**使用 Springboot ，可以通过 Bean 的方式**让 Spring 帮我们管理线程池

#### 关闭线程池

 `shutdown()/shutdownNow()`，区别在于停止接受新任务后是否继续执行或中断队列中的任务

如果通过 shotdown() 关闭：

```java
// ..
pool.shutdown();
while (!pool.awaitTermination(1, TimeUnit.SECONDS)) {
    LOGGER.info("线程池正在退出中，继续执行剩余内容");
}
LOGGER.info("线程池退出完毕");
// ..
```

### 8. ThreadLocal 和 Inherittable

#### ThreadLocal 的简单大致理解

- 是什么？

一个线程间隔离的共享变量，每个线程存取 Threadlocal 拿到的是自己的私有对象，可以当作私有成员一样使用

- ThreadLocal 实现副本的机制？

ThreadLocal 本身并不存储数值，每个线程的值存放在自己线程的 ThreadLocalMap （一个HashMap）中。每个线程通过访问唯一的**共享静态变量 ThreadLocal T>** ，将其作为键值来访问自己的 Map ，从而提取自己所维护的值（这样做的原因是也是为了支持使用泛型）

![img](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/H772_~O8TYY$[HO36VDAWM4.hc)

- 和 线程局部变量 的区别？为什么不直接用局部变量？

都具有隔离性，但是 ThreadLocal 可以在线程内各个方法间共享，相当于**线程内的全局私有变量**

相较于局部变量，1. ThreadLocal 具有**线程内全局性**，可以在方法之间直接共享使用，使用更方便而不需要传参。2. ThreadLocal 一定程度上可以**控制对象创建的开销**，因为副本对象的创建是跟线程走的，如果线程可以得到复用（考虑线程池），那么 ThreadLocal 创建的对象也可以复用

- 内存泄漏？

Map 中的 key 为弱引用，在任一次 GC 之后会被回收，使得 key 为null。Map 提供一个 expungeStaleEntry 方法，可以将 null key 的 value 置为空，这个方法一般会在每次访问 ThreadLocal 时（set,remove,rehash 等）都被检查一次。

但是如果 ThreadLocal 本身在这些操作之前就已经不再使用，而线程又不终止，那么 value 仍然不会被回收，导致 value 的内存泄漏。所以尽可能在完全不使用 ThreadLocal 之后显式调用它的 remove 方法。

- 使用案例

典型的一个使用场景的案例（同时使用了线程池）：每个线程根据自己所给参数的秒数打印一个格式化时间，实现按格式顺序打印1000秒：

```java
public class ThreadLocalDemo06 {

    public static ExecutorService threadPool = Executors.newFixedThreadPool(16);

    public static void main(String[] args) throws InterruptedException {
        for (int i = 0; i < 1000; i++) {
            int finalI = i;
            threadPool.submit(new Runnable() {
                @Override
                public void run() {
                    // 每个线程的 SimpleDateFormat 对象可以被重复利用，构造的SimpleDateFormat 的最大次数仅有16个
                    String date = new ThreadLocalDemo06().date(finalI);
                    System.out.println(date);
                }
            });
        }
        threadPool.shutdown();
    }

    public String date(int seconds) {
        Date date = new Date(1000 * seconds);
        SimpleDateFormat dateFormat = ThreadSafeFormatter.dateFormatThreadLocal.get();
        return dateFormat.format(date);
    }
}

class ThreadSafeFormatter {
    public static ThreadLocal<SimpleDateFormat> dateFormatThreadLocal = new ThreadLocal<SimpleDateFormat>() {
        @Override
        protected SimpleDateFormat initialValue() {
            return new SimpleDateFormat("mm:ss");
        }
    };
}

// 输出：
// 00:00
// 00:01
// 00:02
// ...
```

## JVM

### 1. 运行时内存结构

![](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/5d31384c568c531115.jpg)

#### 虚拟机栈

为**Java方法的调用**服务

**每一个方法从调用直至执行完成的过程，就对应着一个栈帧在虚拟机栈中入栈到出栈的过程。**

#### 本地方法栈

与 VM Stack 类似，区别只在VMStack只为虚拟机执行Java方法服务，而 Native Method Stack 则为虚拟机使用到的 **Native 方法**服务。

#### 程序计数器

当前线程所执行的字节码的行号指示器，用于**获取下一条执行的字节码**。分支、循环、跳转、异常处理、线程恢复等基础功能都需要依赖这个计数器来完成

#### 方法区/元空间（共享）

（JDK1.7）方法区主要用于存放已经被虚拟机加载的类信息，如**常量，静态变量**。 这块区域也被称为**永久代**。

（JDK1.8）该区域被废弃，作为代替引入元空间（MetaSpace），放在**本地内存**而不是虚拟机管理的内存。

#### 直接内存

和元空间同属本地内存，不由 JVM 虚拟机管理

NIO，以及调用 NIO 的 Netty 会使用这些部分

#### 堆（共享）

**Java虚拟机所管理的内存中最大的一块。几乎所有对象实例创建发生在这个区域**

可利用参数 `-Xms -Xmx` 进行堆内存大小控制。同时也是垃圾回收器的重点管理区域。由于大部分垃圾回收器采用 **分代回收算法** 所以堆内存一般也划分成新生代，老年代等，便于方便的回收

将 -Xms -Xmx 设置为同样大小可以减少 JVM 去向操作系统申请内存的次数

### 2. 对象创建与内存分配

#### 对象分配过程

1. 编译器通过逃逸分析（判断指标：**一、对象是否被赋值给堆中对象的字段和类的静态变量。（和堆中的对象产生联系）二、对象被传进了不确定的代码中去运行**），确定对象是在栈上分配还是在堆上分配。如果是在堆上分配，则进入2.
2. 如果tlab_top + size <= tlab_end，即当前TLAB空间可用，则在在**TLAB**上直接分配对象并增加tlab_top 的值，如果现有的TLAB不足以存放当前对象则3.
3. 重新申请一个TLAB，并再次尝试存放当前对象。如果放不下，则4。
4. 在Eden区加锁（这个区是多线程共享的），如果eden_top + size <= eden_end则将对象存放在Eden区，增加eden_top 的值，如果Eden区不足以存放，则5。
5. 执行一次Young GC（minor collection）
6. 经过Young GC之后，如果Eden区任然不足以存放当前对象，则直接分配到老年代。

可以看出优先级顺序为：**栈分配 -> 线程私有TLAB -> Eden加锁分配 -> (YoungGC后)Eden -> 老年代** 

#### 关于TLAB

在Java中，典型的对象不再堆上分配的情况有两种：TLAB和栈上分配（通过逃逸分析）。

TLAB（Thread-local allocation buffer）是：JVM在内存新生代**Eden Space**中开辟的一小块**线程私有**的区域。默认设定为占用Eden Space的1%。

在Java程序中很多对象都是小对象且用过即丢，它们不存在线程共享也适合被快速GC，所以对于小对象通常JVM会优先分配在TLAB上，并且**TLAB上的分配由于是线程私有所以没有锁开销**。因此在实践中分配多个小对象的效率通常比分配一个大对象的效率要高。

也就是说，Java中**每个线程都会有自己的缓冲区称作TLAB（Thread-local allocation buffer）**，每个TLAB都只有一个线程可以操作，TLAB结合bump-the-pointer技术可以实现快速的对象分配，而不需要任何的锁进行同步，也就是说，在对象分配的时候不用锁住整个堆，而只需要在自己的缓冲区分配即可。

#### 对象内存分配的两种方法

1. **指针碰撞**(Serial、ParNew等带Compact过程的收集器) ：假设Java堆中**内存是绝对规整的**，所有用过的内存都放在一边，空闲的内存放在另一边，中间放着一个指针作为分界点的指示器，那所分配内存就**仅仅是把那个指针向空闲空间那边挪动一段与对象大小相等的距离**，这种分配方式称为“指针碰撞”（Bump the Pointer）。
2. **空闲列表**(CMS这种基于Mark-Sweep算法的收集器) ：如果Java堆中的内存并不是规整的，已使用的内存和空闲的内存相互交错，那就没有办法简单地进行指针碰撞了，**虚拟机就必须维护一个列表，记录上哪些内存块是可用的，在分配的时候从列表中找到一块足够大的空间划分给对象实例**，并更新列表上的记录，这种分配方式称为“空闲列表”（Free List）。保证同一时间所有对象处于其中一块，Minor GC后，未进入老年的对象统一被复制到另一块对象。

### 3. 内存回收

#### 判断对象废弃的方法（垃圾回收机制）

**引用计数**：每个对象都含有一个引用计数器,当有引用连接至对象时,引用计数加1，当引用离开作用域或被置为null时,引用计数减1。垃圾回收器会在含有全部对象的列表上遍历,当发现某个对象引用计数为0时,就释放其占用的空间。

**可达性分析**：这个算法的基本思路就是通过一系列的称为“**GC Roots**”的对象作为起始点，从这些节点开始向下搜索，搜索所走过的路径称为引用链。当一个对象到GC Roots没有任何引用链相连，那么该对象不可用

#### 分代回收

如之前所述，HotSpot JVM中年轻代中使用带年龄的复制，在年老代使用标记-清除或标记-整理

#### 对象GC后的移动顺序

1. 新创建对象（如果不在栈上分配）分配在 Eden 区，如果较小可以放在线程私有的TLAB区（除非过大，再 Minor GC 之后仍然无法放入）
2. 对象经过第一次 Minor GC 后，如果存活，那么移动到 Survivor 区（每熬过一次 Minor GC，年龄+1，到一定值之后进入老年代）
3. 对于所有 Survivor 区的对象，内存被分为两块，

### 垃圾收集器种类

#### Serial

单线程，新生代采用复制，老年代采用标记-整理，一旦GC发生就需要STW（无论Minor/Full）

运行在 Client 模式时会偏向于使用该收集器

#### Serial Old

Serial 的老年代版本，使用标记整理，单线程

主要在 JDK1.5 与以前和 Parallel Scavenge 搭配使用，以及作为 CMS 的后备预案，在 CMS 发生 Concurrent Mode Failure 时使用

#### ParNew

新生代收集器，标记复制算法

Serial 的多线程版本，也就是说STW仍然存在，只是通过多线程提高速度；唯一可以和 CMS 配合工作的收集器（JDK1.5 如果使用 +UseConcMarkSweepGC 之后将默认指定ParNew作为新生代收集器）

#### Parallel Scavenge

新生代收集器，复制算法，并行多线程（和ParNew基本一致）

和 CMS 尽可能缩短 STW 的目标不同，Parallel Scavenge 的目标是达到一个**可控制的吞吐量**（即【运行用户代码时间 / 运行用户代码+垃圾回收时间】），通过 `-XX:MaxGCPauseMillis` 设置最大GC停顿时间和通过 `-XX:GCTimeRatio` 直接设置吞吐量

两种着重点不同适合的场景不同：前者适合**需要和用户交互的程序**，后者适合**需要尽快完成程序运算任务的程序**

除此之外，Parallel Scavenge 提供参数可以**动态修改**新生代大小和 Eden/Surivor 比例，在结合前面所提到两种参数作为优化目标，让虚拟机自行调节

#### ParOld

Parallel Scavenge 的新生代版本，JDK1.6 开始提供，多线程，标记整理算法

和 Parallel Scavenge 思想类似，以吞吐量优先

#### CMS

以最短停顿时间为目标，特点是清理阶段并发运行，只有初始标记和重新标记阶段会STW

##### CMS执行过程

- **初始标记(STW initial mark)**：从垃圾回收的"根对象"开始，只扫描到能够和"根对象"直接关联的对象，并作标记。所以这个过程虽然**暂停了整个JVM**，但是很快就完成了。
- **并发标记(Concurrent marking)**：紧随初始标记阶段，并发进行。在初始标记的基础上继续向下追溯标记。所以用户不会感受到停顿。
- **并发预清理(Concurrent precleaning)**：这个阶段会暂停虚拟机，查找在执行**并发标记阶段**新产生的进入老年代的一部分对象，减少下一个阶段STW时的工作
- **重新标记(STW remark)**：扫描CMS堆中剩余的对象
- **并发清理(Concurrent sweeping)**：并发。清理垃圾对象，这个阶段收集器线程和应用程序线程并发执行。
- **并发重置(Concurrent reset)**：这个阶段，重置CMS收集器的数据结构状态，等待下一次垃圾回收。

#### G1 

初次在 JDK 1.6 Update14 登场，在 JDK1.9 为默认回收器

相比 CMS 有两个改进：（1）基于标记整理实现（2）精确控制停顿时间，明确指定在 M 毫秒时间片内STW时间不超过 N 毫秒

G1 通过将整个 Java 堆划分为若干个 Region，通过跟踪 Region 内的垃圾堆积程度（称为活性），维护一个关于 Region 活性大小的优先列表，尽可能地回收垃圾最多的区域

##### G1执行过程

- **初始标记(STW)**：短暂STW，初始标记，顺带触发一次young GC
- **并发标记：**并发**。**在整个堆中进行，并且和应用程序并发运行，可能被 young GC 打断如果发现区域对象中的所有对象都是垃圾，那个这个区域会被立即回收(图中打X)。同时，并发标记过程中，每个**区域的对象活性**(区域中存活对象的比例)被计算。
- **再标记**：用来补充收集并发标记阶段产新的新垃圾。与之不同的是，G1中采用了更快的算法:SATB
- **清理阶段(STW)**：选择活性低的区域(同时考虑停顿时间)，等待下次young GC一起收集，这个过程也会有停顿(STW)。
- **回收/完成**：新的young GC清理被计算好的区域。但是有一些区域还是可能存在垃圾对象，可能是这些区域中对象活性较高，回收不划算，也肯能是为了迎合用户设置的时间，不得不舍弃一些区域的收集。

##### G1与CMS的比较

- CMS收集器是**获取最短回收停顿时间**为目标的收集器，因为CMS工作时，GC工作线程与用户线程可以并发执行，以此来达到降低停顿时间的目的（只有初始标记和重新标记会STW）。但是CMS收集器对CPU资源非常敏感。在并发阶段，虽然不会导致用户线程停顿，但是会占用CPU资源而导致引用程序变慢，总吞吐量下降。
- CMS仅作用于**老年代**，是基于【标记清除算法】，所以清理的过程中会有大量的**空间碎片**。
- CMS收集器**无法处理浮动垃圾**，由于CMS并发清理阶段用户线程还在运行，伴随程序的运行自热会有新的垃圾不断产生，这一部分垃圾出现在标记过程之后，CMS无法在本次收集中处理它们，只好留待下一次GC时将其清理掉。
- G1是一款面向服务端应用的垃圾收集器，**适用于多核处理器、大内存容量的服务端系统**。G1能充分利用CPU、多核环境下的硬件优势，使用多个CPU（CPU或者CPU核心）来缩短STW的停顿时间，它满足**短时间停顿的同时达到一个高的吞吐量**。
- 从JDK 9开始，G1成为默认的垃圾回收器。当应用有以下任何一种特性时非常适合用G1：**Full GC持续时间太长或者太频繁；对象的创建速率和存活率变动很大；应用不希望停顿时间长(长于0.5s甚至1s)**。
- G1将空间划分成很多**块（Region）**，然后他们各自进行回收。堆比较大的时候可以采用**复制算法**，碎片化问题不严重。**整体上看属于标记整理算法,局部(region之间)属于复制算法**。
- G1 **需要记忆集来记录新生代和老年代之间的引用关系，这种数据结构在 G1 中需要占用大量的内存**，可能达到整个堆内存容量的 20% 甚至更多。而且 G1 中维护记忆集的成本较高，带来了更高的执行负载，影响效率。所以 **CMS 在小内存应用上的表现要优于 G1，而大内存应用上 G1 更有优势**，大小内存的界限是6GB到8GB。（Card Table（CMS中）的结构是一个连续的byte[]数组，扫描Card Table的时间比扫描整个老年代的代价要小很多！G1也参照了这个思路，不过采用了一种新的数据结构 Remembered Set 简称Rset。RSet记录了其他Region中的对象引用本Region中对象的关系，属于points-into结构（谁引用了我的对象）。而Card Table则是一种points-out（我引用了谁的对象）的结构，每个Card 覆盖一定范围的Heap（一般为512Bytes）。G1的RSet是在Card Table的基础上实现的：每个Region会记录下别的Region有指向自己的指针，并标记这些指针分别在哪些Card的范围内。 这个RSet其实是一个Hash Table，Key是别的Region的起始地址，Value是一个集合，里面的元素是Card Table的Index。每个Region都有一个对应的Rset。）

#### ZGC

JDK 11 推出了 ZGC，面向低延迟和大内存堆适应设计。设计目标包括：

- 停顿时间不超过10ms；
- 停顿时间不会随着堆的大小，或者活跃对象的大小而增加；
- 支持8MB~4TB级别的堆（未来支持16TB）。

### 4. 类加载

### JVM常用参数

**内存大小配置：**

`-Xms2048M`  堆栈内存最小值

`-Xmx2048M` 堆栈内存最大值

`-XX:MaxPermSize=20M `  永久代大小初始化大小10M，永久代大小最大大小20M

`-XX:NewRatio=4`  年轻代：老年代 大小比值为 1:4

`-XX:SurvivorRatio=4`  设置年轻代内，两个 Survivor ：Eden 大小为 1:1:4，即 Survivor 区占整个年轻代 1/6

**GC相关设置：**

`-XX:ParallelGCThreads=4` 可以设置并发GC收集器的使用线程数，可以根据CPU配置设置为相应核心数大小

`-XX:+PrintHeapAtGC`  GC时打印内存布局

`-XX:+HeapDumpOnOutOfMemoryError` 发生内存溢出时 dump 内存

### JVM调优场景

#### major/minor GC 频繁

对于Minor GC频繁：可能原因是新生代空间较小，使得 Eden 区也较小，很快被填满，可以通过增大新生代空间（提高`-XX:SurvivorRatio` ）来解决

#### CMS请求高峰期发生GC导致服务可用性下降

对于CMS收集器，由于跨代引用的情况，如果没有其他措施，CMS在Remark阶段必须扫描全部堆

可以通过 `CMSScavengeBeforeRemark` 选项来强制 Remark 前进行一次 Minor GC，减少Remark扫描的范围

#### CMS长时间运行后效率降低碎片过大

可以通过 `CMSCompactAtFullCollection` 在 Full GC之后加上一次碎片整理，代价是STW时间变长

## Linux

### 1. Linux与查看资源相关的指令

**ps 进程**

静态查看**进程统计信息**（主要包括pid，CPU/MEM 占用百分比，状态，占用CPU时间等）（一般使用 ps -aux 或者 ps -elf）

常用手段：

获取第一个包含“java”信息的进程：

```shell
ps -elf |grep java|grep -v grep |head -n 1 |awk '{printf $4}'
```

**top 动态进程**

动态查看**进程活动状态**，比 ps 多了所有进程的统计总览以及总体资源情况

**pgrep 进程**

查询**指定进程信息**，默认输入进程名，输出进程Pid

**free 内存**

显示**系统内存**情况

**/proc/meminfo 内存**

存储了比 free 更丰富的内存状态的接口

**vmstat 基本状态**

显示**动态服务器状态值**（CPU,内存，硬盘IO读写）

**lsof -i 网络**

查看**所有连接**。一般用用 losf -i:port 来显示指定端口被占用的信息

**netstat 网络**

`netstat -tunlp`：查看所有【 (-t)tcp (-u)udp (-n)不显示别名 (-l)正在listen的 (-p)建立相关链接的程序名】 的**连接**。加上 | grep (port) 可以显示指定端口的情况

**df -h 磁盘**

查看**磁盘状态**

### 2 如何获取一个网络访问log中 访问记录最多的前10个ip？

```shell
cat test.log `# 获取log` \
> | awk -F" " '{print $2}' ` #假设Ip地址所在的列数已知为第2列，提取该列` \
> | sort `# 按默认排序` \
> | uniq -c `# 统计唯一项，并标出重复项` \
> | sort -nrk 1 -t' ' `# -n: 按照数值大小排序，-r 降序，-k 1 参照指定第1列进行排序` \
> | awk -F" " '{print $2}' `# 打印排序后结果的ip部分`\
> | head -10 `# 显示头10个`\
```

### 5种IO以及 多路复用函数实现

#### 5种IO

- **同步阻塞**：用户线程进行IO操作时，直到内核返回结果前阻塞。体现在在java io文件读取和写入
- **同步非阻塞**：用户线程发出请求后返回，但是无法读到任何数据，需要之后不断发起IO请求轮询
- **IO多路复用/异步阻塞IO：**

建立在内核提供的多路分离函数select，poll，epoll之上，目的是避免同步非阻塞IO模型中轮询等待的问题

添加一个 Reactor ,用户线程向 Reactor 注册事件处理器，把轮询IO操作交给Reactor处理，Reactor 轮询到某个数据准备完成后，通知对应的用户线程（调用用户的回调函数），让用户去进行读取内核准备好的数据

Reactor 可以注册多个用户线程，从而将轮询工作集中起来

- **信号驱动IO**

用户线程发出请求后返回，但是自己不再主动发起轮询请求，而是内核准备好后，向该线程发送一个信号（调用信号回调函数），线程开始去读数据

- **异步IO**

用户线程发出请求后返回，内核完成IO之后直接会将数据复制到用户空间，并发送一个完成通知，用户在自己空间内进行对数据的操作，内核就不需要再应对该用户的请求。

#### select poll epoll

|     \      |                            select                            |                       poll                       |                            epoll                             |
| :--------: | :----------------------------------------------------------: | :----------------------------------------------: | :----------------------------------------------------------: |
|  操作方式  |                             遍历                             |                       遍历                       |                             回调                             |
|  底层实现  |                             数组                             |                       数组                       |                            哈希表                            |
|   IO效率   |           每次调用都进行线性遍历，时间复杂度为O(n)           |     每次调用都进行线性遍历，时间复杂度为O(n)     | 事件通知方式，每当fd就绪，系统注册的回调函数就会被调用，将就绪fd放到rdllist里面。时间复杂度O(1) |
| 最大连接数 |                  1024（x86）或 2048（x64）                   |                      65535                       |                            65535                             |
|   fd拷贝   |      每次调用select，都需要把fd集合从用户态拷贝到内核态      | 每次调用poll，都需要把fd集合从用户态拷贝到内核态 |  调用epoll_ctl时拷贝进内核并保存，之后每次epoll_wait不拷贝   |
|  事件绑定  | 通过三个参数传入感兴趣的可读，可写或异常事件，每次调用函数前都需要重置事件集（因为文件描述符集合会被内核修改） |  统一处理所有事件类型，多次调用不需要重置事件集  | 通过事件表管理事件，提供一个独立的系统调用epoll_ctl进行事件的增删改 |

select：传入需要监听的文件描述符集合（数组），以可读，可写或异常事件分类，select 将轮询这些文件描述符集合，当发现可读写（或者异常）或者超时后返回，内核将修改这些集合来通知应用程序哪些 fd 就绪，然后直接对这些 fd 集合进行读写

poll：传入一个结构类型数组（fd，注册事件集，回填事件集），由于回填和fd分离，统一处理所有事件类型，多次调用不需要重置事件集

epoll：epoll 将用户关心的 fd 上的事件放入内核的一个事件表中，通过 epoll_ctl 函数操作内核，通过 epoll_wait 函数获得触发的事件集（不同于select和poll函数，通过 epoll_wait 获得的 fd 集只包含就绪事件的 fd 集）

### 3. Linux 常用文本处理操作 grep sed awk

#### awk

功能：逐**行**扫描文件，并且对于符合匹配内容的行，在该行上执行用户指定的操作。

操作单位：**行**

结构：

```shell
awk [-选项] '[匹配规则]{执行命令}' 文件名
```

| 选项(options) | 含义                                              |
| ------------- | ------------------------------------------------- |
| -F fs         | 指定以 fs 作为行分割符，默认为空格/制表符         |
| -f file       | 从脚本文件读取 awk 脚本指令代替直接输入指令       |
| -v var=val    | 执行处理过程前，设置一个变量 var 并赋予初始值 val |

最重要的部分在于 ` '[匹配规则]{执行命令}'` 所组成的脚本命令。如果**没有匹配规则则默认匹配所有行。

awk 可以自动给一行中的每个元素分配变量：

- $0 代表整个文本行；
- $1 代表文本行中的第 1 个数据字段；
- $2 代表文本行中的第 2 个数据字段；
- $n 代表文本行中的第 n 个数据字段。

可以执行多个命令，用 ; 隔开即可

使用举例：

```shell
awk -F" " '{print $2}' test.log
```

获取 test.log 中的数据，按空格为行分割符，并打印第二列内容

#### grep

功能：扫描文件内所有内容，找出符合匹配条件的所有行

操作单位：**行**

结构：

```shell
grep [选项] 模式 文件名
```

| 选项   | 含义                                             |
| ------ | ------------------------------------------------ |
| **-c** | 仅列出文件包含模式的行数                         |
| **-i** | 忽略模式中的字母大小写                           |
| -l     | 列出带有匹配行的文件名                           |
| -n     | 在每一行的最前面列出行号                         |
| -v     | 列出没有匹配模式的行                             |
| -w     | 把表达式当作一个完整单字符搜索，忽略部分匹配的行 |

如果包含多个文件，那么 grep 命令仅显示发现文件中匹配模式的那些文件名。

#### sed

功能：根据脚本命令对文本文件进行流式编辑

操作单位：**行或列（根据脚本指令决定）**

结构：

```shell
sed [选项] [脚本命令] 文件名
```

| 选项            | 含义                                                         |
| :-------------- | :----------------------------------------------------------- |
| -e 脚本命令     | 该选项会将其后跟的脚本命令添加到已有的命令中。               |
| -f 脚本命令文件 | 该选项会将其后文件中的脚本命令添加到已有的命令中。           |
| -n              | 该选项会屏蔽启动输出，需使用 print 命令来完成输出。（默认情况下，sed 会在所有的脚本指定执行完毕后自动输出处理后的所有内容） |
| -i              | 此选项会直接修改源文件，要慎用                               |

sed 的 [脚本命令] 要比前两种命令的匹配模式复杂一些。

**sed s 词组替换**

基本格式：

```
[address]s/pattern/replacement/flags
```

pattern: 需要替换的内容 replacement：替换的新内容 flags：不同的模式选择

| flags 标记 | 功能                                                         |
| ---------- | ------------------------------------------------------------ |
| n          | (1~512间的数字)表示字符串到出现第n次时才进行替换             |
| g          | 对匹配内容全部(否则仅对第一次匹配替换，相当于默认/1)         |
| p          | 当使用-n 禁用输出时，会打印匹配的行；否则默认会标记出现修改的行 |
| w file     | 将缓冲区内容写入指定 file 中                                 |
| &          | 用正则表达式匹配内容进行替换                                 |
| \n         | 匹配第 n 个字串                                              |
| \          | 转义（&，\，/）等                                            |

一些用法：

```shell
sed 's/raw/new/2' data.txt #表示只替换每行第2次出现的匹配模式
sed 's/raw/new/g' data.txt #替换所有匹配内容
sed -n 's/raw/new/p' data.txt #结束后仅输出发生替换的行
# 使用s替换命令时，对于包含类似文件路径的字符串会比较麻烦，需要对正斜线转义
sed 's/\/bin\/bash\/bash/\/bin\/csh' /etc/passwd #代表 /bin/bash -> /bin/csh 的替换
```

**sed d 行删除**

基本格式：

```
[addresss]d
```

删除文本中的特定行，通过adress指定

如果不指定具体行，那么所有内容都会被删除

一些用法：

```shell
sed '4d' data.txt #删除文件中第4行
sed '2,3d' data.txt #删除文件中2，3行
```

**sed a / i 行前后插入**

a 命令表示在指定行的后面附加一行，i 命令表示在指定行的前面插入一行，两种用法完全相同。

```
[address] [n]a(或i) \新文本内容
```

用法：

```shell
sed '2i\ This is new Line.\' #在第2行之后插入输入的内容
```

**sed c 替换脚本命令**

c 命令对指定行的全部内容替换为指定的字符串

```
[address] [n]c\用于替换的新文本
```

**sed y 字符替换**

和 sed s 类似，但是可以处理单个字符

唯一不以行为单位的命令

```
[address]y/inchars/outchars/
```

转换命令会对 inchars 和 outchars 值进行一对一的映射，即 inchars 中的第一个字符会被转换为 outchars 中的第一个字符，第二个字符会被转换成 outchars 中的第二个字符...。如 sed 'y/abc/ABC/' 会将 a b c 转换为对应的大写

## Java / Spring

### 运算符顺序

一元运算 >> 乘除模 >> 加减 >> 按位移动操作 >> 大小等于比较 >> 按位运算操作 >> 逻辑与或非

### final关键字

final 类：该类无法被继承，但不保证成员变量不变

final 方法：该方法不能在子类中被【重写】

final 变量：该变量不能改变【引用】，并且必须被【初始化】

### 安全单例模式实现

主要是为了一般的懒汉模式可能存在的安全性，防止被多个线程同时实例化

```java
public class Singleton {
    // 单例除了用 static 修饰外，还需要用 volatile 修饰
    // 防止 new uniqueInstance 过程被重排
    private volatile static Singleton uniqueInstance;
    
    private Singleton() {}
    
    public static Singleton getUniqueInstance() {
        // 如果已经实例化过
        if (uniqueInstance == null) {
            // 锁住单例类对象
            synchronized (Singleton.class) {
                // 进入后再判断一次（即双重校验）
                if (uniqueInstance == null) {
                    uniqueInstance = new Singleton();
                }
            }
        }
        return uniqueInstance;
    }
}
```

### 抽象类与接口的比较

同：

1. 都不能被【实例化】。

2. 其可以被实例化的实现类（或者子类）只有实现了接口或者抽象类中的【全部抽象方法】后才能被实例化

异：

1. 接口不能对普通方法进行实现（1.8的default除外），而抽象类可以有普通方法实现；
2. 接口成员变量自动是 static 和 final 的
3. 一个类可以实现【多个】接口。一个类只能继承一个抽象类；
4. 接口强调包含特定功能的【契约】作用，而抽象类决定其继承类的主体【结构】

### 基本类型包装类

Java的Integer包装类在进行自动装箱时，如果数值在-128~127之间，会让该Integer对象直接指向常量池中的缓存地址，而不是用new开辟新的空间。

### 三大特性

#### 封装

体现在类成员的权限控制和访问器（Getter，Setter）的使用

#### 继承

面向对象的最显著特征

java不同于C++，不允许多重继承，降低了对象定义的复杂性（但是可以多个接口）

#### 多态

Java 运行时动态编译效果的最好体现

使得上层应用可以编写通用的程序而不用关心具体的实现，减少了代码复杂性，具体决定调用哪个方法被推迟到运行时决定，避免了静态编译程序的复杂性

### Spring Data JPA 和 MyBatis 对比

面向对象 ：面向关系（或数据，过程）

实际对比：Spring Data JPA 和一般的 JAVA 代码编写更加贴合，Repository 的使用更加易于理解和方便，对于简单业务，方法名定义查询方法甚至可以完全避免SQL语句。而 MyBatis 的Mapper 编写相比之下较为繁琐。但是对于复杂查询（比如联表查询），JPA的使用就不如 MyBatis 灵活（必须显式地在实体类中指定对应关系）

### Spring Bean Context Core

#### Bean

管理了 Bean 的定义，Bean 的创建，Bean 的解析，

生命周期：

spring **仅管理单例模式 bean** 的生命周期

实例化过程：实例化 -> 填充属性 -> 根据实现的Aware接口设置相关依赖 -> 前置处理 -> 自定义init-method -> 后置处理 -> 投入使用 -> @preDestory -> 自定义destory 方法

#### Context

提供运行时环境，保存各个对象的状态，维护对象间关系

#### Core

定义了资源的加载和访问方式，将所有资源抽象为接口，将资源的定义和存取方式的职责分开

### Spring 三级缓存解决bean循环依赖

#### 定义

Spring Bean 循环依赖产生的方式有两种，一种是通过构造器注入形成的循环依赖，这种方式会抛出异常。另一种是通过 field 属性注入形成的循环依赖，这种依赖方式通过 Spring 的特殊 bean 生成机制得到了解决

> 此处讨论的 bean 均为单例，prototype的bean循环均会抛出异常。混合的情况，先创建单例成功，反之会抛出异常

总的来说，Spring 解决循环依赖问题时通过 bean实例化和属性装填分离，三级缓存机制，引用提前暴露机制实现的

#### 三级缓存

```java
// 一级缓存，保存singletonBean实例：bean name --> bean instance
private final Map<String, Object> singletonObjects new ConcurrentHashMap<String, Object>(256);
// 二级缓存，保存早期未完全创建的singleton实例：bean name --> bean instance
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<String, Object>(16);
// 三级缓存，保存singletonBean生产工厂：bean name --> ObjectFactory
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<String, ObjectFactory<?>(16);
```

当spring想要获取某个单例bean时，首先会在三级缓存中顺序查找，如果未找到的情况下，返回null，然后执行一系列逻辑开始创建这个新的 bean 对象

**引用提前暴露**：在初次创建一个 Bean 对象时，不会马上开始相关的属性装配，而是检查是否允许提前暴露，如果允许，那么将对象 SingletonFactory 加入第三级 Bean 缓存，使得外界能够提前获得该 Bean 的未完成引用

通过这种方式，当出现 A <-> B 的循环依赖场景时，假设创建顺序是 A -> B ，那么在对 B装填 A的过程中，B 可以获得 A 提早放在第三缓存的 bean 对象引用。由于是引用，也可以保证最后对 A 实例化完成后，B 可以持有已经创建完成的 A 对象，从而解决了循环依赖

同样根据这种步骤也就可以解释，对于构造器注入的场景，spring将无法获取这样的缓存，所以将抛出错误

### Spring AOP 实现

Spring AOP 基于 **动态代理** 实现，在深入了解之前可以先了解以下静态代理：

```java
// 静态代理演示
public interface InterfaceA {
    void exec();
}
public class Real implements InterfaceA {
    public void run() {
        System.out.println("real impl");
    }
}
public class Proxy implements InterfaceA {
    private InterfaceA inner;
    public Proxy() {
        inner = new Real();
    }
    public void run() {
        System.out.println("do something before");
        inner.run();
        System.out.println("do something after");
    }
}
public class Main(){
    public static void main(String[] args){
        InterfaceA interface = new ProxyImplement() ;
        interface.exec();
    }
}
```

通过这种方式，我们可以在不修改原 Real 类的情况下创建新类在执行原逻辑操作的基础上，执行其他 before after 操作，并且使用方式和原本基本无区别，调用者感知不到代理对象的存在，这就是 AOP 实现的核心，即可以理解为**对原类型的包装**

这种方式的问题是，一次只能代理一个具体的类，如果要代理**一个接口的多个实现**，需要不同的代理类

#### JDK动态代理实现

通过 **JDK 动态代理** 解决这个问题，包括两个核心类：`java.lang.reflect.Proxy`类。`java.lang.reflect.InvocationHandle`接口。

`Proxy` 类是用于创建代理对象，而 `InvocationHandler` 接口主要你是来处理执行逻辑。

```java
public class CustomizeHandle implements InvocationHandler {
    private final static Logger LOGGER = LoggerFactory.getLogger(CustomizeHandle.class);

    private Object target;

    public CustomizeHandle(Class clazz) {
        try {
            this.target = clazz.newInstance();
        } catch (InstantiationException e) {
            LOGGER.error("InstantiationException", e);
        } catch (IllegalAccessException e) {
            LOGGER.error("IllegalAccessException",e);
        }
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

        before();
        Object result = method.invoke(target, args);
        after();

        LOGGER.info("proxy class={}", proxy.getClass());
        return result;
    }


    private void before() {
        LOGGER.info("handle before");
    }

    private void after() {
        LOGGER.info("handle after");
    }
}

public class Main {
    public static void main(String[] args) {
    	CustomizeHandle handle = new CustomizeHandle(ISubjectImpl.class) ;
        ISubject subject = (ISubject) Proxy.newProxyInstance(JDKProxyTest.class.getClassLoader(), new Class[]{ISubject.class}, handle);
        subject.execute() ;
    }
}
```

首先定义一个实现 InvocationHandler 的实例类，实现 invoke 方法，这个实例类负责接口的方法调用，

另外，通过 Proxy.newProxyInstance() 创建被代理对象的实例，需要三个参数：

- 使用的 ClassLoader
- 需要实现的接口数组
- 用于处理接口方法调用的 InvocationHandler 实例

这样，我们就得到了一个代理对象（需要强制类型转换），调用这个代理对象的方法就可以实现 AOP 方法

实际上我们是在运行中创建了一个结构与静态代理结构类似的代理类的字节码

由于产生的代理类必须要继承 Proxy 类，所以 JDK代理**只能实现对接口类的代理**

#### CGLIB动态代理实现

cglib 是对一个小而快的字节码处理框架 `ASM` 的封装。 他的特点是直接继承于被代理类

代理类的创建通过 `Enhancer` 类实现，业务方法的拦截通过 `MethodInterceptor` 实现

```java
public class User {
	public void foo() {
        System.out.println("foo");
    }
}

public class UserMethodInterceptor implements MethodInterceptor {
    @Override
    public Object intercept(Object obj,Method method, Object[] args,
                           MethodProxy proxy) throws Throwable {
        // AOP操作
        System.out.println("before:"+method.getName());
		Object object = proxy.invokeSuper(obj, arg);
		System.out.println("after:"+method.getName());
		return object;
    }
}
public class Testcglib {
    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
		//继承被代理类
		enhancer.setSuperclass(User.class);
		//设置拦截器回调
		enhancer.setCallback(new UserMethodInterceptor());
		//生成代理类对象
		User user = (User)enhancer.create();
		//在调用代理类中方法时会被我们实现的方法拦截器进行拦截
    }
}
```

使用方法和 JDK 代理基本一致，不同的是JDK动态代理强制要求实现类必须最少实现一个接口，但是CGLIB则可以要求实现类不用实现任何接口

和 JDK 性能上的区别在于，JDK 代理对象调用被代理对象地方法时每次都要使用反射的方式，而 cglib 通过hash索引保存了方法信息，使得方法调用时的效率更高（但是对于接口形式的方法，实际上执行时没有“执行被代理方法”这一步骤，而jdk生成class速度比较快，随着jdk的版本变化对反射这一块进行了优化，jdk更加快捷）

### @Resource 和 @Autowired 区别

区别在于 @Resource 是JavaEE自带注解，默认 ByName 自动注入（如果强制提供了name，那么不会再按type搜索，name找不到直接报错）；而 @Autowired 是Spring框架提供的注解，默认 ByType 注入

## 网络 Web

### 1.TCP

#### 头部长度：

20字节~60字节

#### 超时重传：

发送一个报文段后开启一个计时器，如果没有得到发送的数据报的ACK报文，那么就自动重新发送数据

#### ARQ协议：

自动重传请求（Automatic Repeat reQuest），通过请求接受方重传出错的报文，从而用于在不可靠服务基础上实现可靠信息传输。

分为**停止等待（stop-and-wait）ARQ**协议和**连续ARQ**协议

停止等待ARQ协议可以理解为窗口为1的连续ARQ协议，

#### TCP**流量控制**

为了**协调双方的发送和接受效果**

通过**滑动窗口**

消息**接受方**回馈的确认报文段中除了包含已经确认了哪些数据之外，还会包含自己接受**窗口剩余容量大小**
那么发送方的发送窗口就不能大于这个数值，从而形成一种双方之间的流量控制效果。

#### TCP**拥塞控制**

为了适应**未知的环境**

发送方的发送窗口除了受接受方接受窗口大小的影响之外，还受拥塞窗口的大小的影响

而拥塞窗口则受网络状态变化根据一定拥塞算法变化，从而变化。

四个拥塞算法

- **慢开始**：TCP连接刚建立时，拥塞窗口从一个较低值开始，每经过一个传输轮次大小**倍数增长**，直到到达**慢开始门限**，然后开始拥塞避免
- **拥塞避免算法**：窗口到达门限值后从倍数增加变成**线性增加**。如果出现网络超时，**门限大小减半，窗口归初始值，重新慢开始**
- **快重传**：首先要求接受方在收到失序报文时立刻发送上个确认报文的重复确认报文。此外如果发送方连续收到三个相同重复ack，那么立刻发送丢失的那个报文，然后不等待超时重传直接进入**快恢复**
- **快恢复**：**门限改为窗口大小减半，窗口大小改为门限大小**，直接开始**拥塞避免**

#### TCP 可靠运输的实现

- 保证内容正确：**校验和**
- 保证内容抵达：**超时重传**
- 保证内容有序：**连续ARQ**协议下，接受方只会发送【**按序收到的数据当中中最大的序号**】
- 保证运输效果：**流量控制和拥塞控制**

#### 与UDP的对比

- 连接：无连接与有连接
- 可靠性：可靠运输与最大努力交付
- 对数据的处理：不会组织报文（分块或合并）
- 拥塞控制的有无
- 开销大小
- 点对点限定/双工和单工

### 2.HTTP1.0 1.1 2.0

HTTP/1.1 **强化了 HTTP1.0+ 的 “keep-alive” 连接**

因为站点局部性，即对某个服务器发起 HTTP 请求的应用很可能在接下来发起更多请求，而 HTTP 基本是一个无状态协议，加上TCP连接的握手消耗以及可能的端口耗尽问题

keep-alive 连接允许 TCP 连接在**HTTP事务结束之后仍然将 TCP 连接保持打开状态**，这样可以减少消耗。但是由于哑代理问题，即不识别 Connection 含义的代码误转发的报文，会导致客户端第二条请求被忽略并使得服务器连接超时关闭

HTTP/1.1 规定 keep-alive **默认开启**，如果显式关闭则显式添加 Connection: close 首部。

并且，HTTP/1.1 允许**管道化连接**，即客户端不用等到第一条请求响应就可以继续发送其他请求

HTTP/2.0 主要提供了**头部压缩和多路复用**

### 3.HTTP状态码

200 OK：请求正常处理并返回

204 NO Content：客户端发给客户端请求得到成功处理并返回，但是没有资源可以返回

206 Patial Content：客户端进行了范围请求。

301 Moved Permanently：永久性重定向，表示请求的资源被分配新的URL。

**302 Found**：临时性重定向，表示请求的资源被分配了新的URL，但是资源还在。（可能与劫持有关）

303 See Other：表示请求的资源被分配了新的URL，应使用GET方法定向获取请求的资源；

**304 Not Modified**：表示客户端发送附带条件（是指采用GET方法的请求报文中包含if-Match、If-Modified-Since、If-None-Match、If-Range、If-Unmodified-Since中任一首部）的请求时，服务器端允许访问资源，但是请求没有满足条件的情况下返回改状态码；

307 Temporary Redirect：临时重定向，与303有着相同的含义，307会遵照浏览器标准不会从POST变成GET；（不同浏览器可能会出现不同的情况）；

400 Bad Request：表示请求报文中存在语法错误；

**403 Forbidden**：服务器拒绝该次访问（访问权限出现问题）

**404 Not Found**：表示服务器上无法找到请求的资源，除此之外，也可以在服务器拒绝请求但不想给拒绝原因时使用；

**500 Inter Server Error：**表示服务器在执行请求时发生了错误，也有可能是web应用存在的bug或某些临时的错误时；

**503 Server Unavailable：**表示服务器暂时处于超负载或正在进行停机维护，无法处理请求；

### 4.JWT

原本的session验证方式：

用户输入用户名密码并通过服务器验证后，服务器在当前session中保存相关数据后，传回用户一个cookie，随后用户每次请求通过这个cookie验证。

坏处是如果存在多台服务器，那么每台服务器都需要存放关于这个用户 session 数据，另外也会消耗内存。

JWT的组成：

Header：签名的算法，类型（JWT令牌统一为JWT）

Payload：存放实际传递的数据

Signature：通过一个只有服务器知道的密钥，组合header和payload进行加密。

特点：

除非另外加逻辑，否则签发后直到失效无法再废止（token的时效被显式写入了token正文，无法主动通过服务器调控）

### localhost与127.0.0.1

127.0.0.1以及localhost（如果hosts文件正常设置情况下）都不会经过网卡等网络设备

原理是：127.0.0.1称为一种特殊的回环地址，如果存在应用使用127.0.0.1时，根据网络协议层级，数据在包装到**网络层**时，如果发现ip为127.0.0.1时，数据将**不再向下包装，而是直接回送给本机的相关应用。**

而localhost仅仅只是多了一次在hosts文件中解析域名的过程，解析为127.0.0.1后，原理仍然相同。

### 所谓的TCP粘包

TCP保证了**可靠按序传输**，唯一的问题在于送出的数据为流式传输，可能导致**分块发送的数据在被读取前被不合法地切分为或者不合法地整合**等问题；或者**缓冲区数据未被完全发送或者完全接收**等问题

TCP实际是一个流式传输，由于应用逻辑需要所以要进行粘包和拆包，

解决方法：

添加标志位

根据具体应用需要，对读取或发送消息时，通过编程限制，保持信息边界。

比如确保缓冲区内容完全发送的代码：

```c++
int res;
int pos = 0; //下一次发送需要开始的位置：
while(pos < len)
{
res = send(sd, buffer + pos , len - pos, 0);
if(res <=0) goto err_handler; //去错误处理
pos += res;
}
```

### （HTTP环境下的）TCP性能问题

#### HTTP事务时延分析

与建立 TCP 连接，以及传输请求和响应报文的时间相比，事务处理时间可能 是很短的。除非客户端或服务器超载，或正在处理复杂的动态资源，否则 HTTP 时延就是由 TCP 网络时延构成的。

其中，主要时延有以下几点影响因素：

- URL的DNS解析（一般客户端会有近期站点的缓存）
- TCP连接的建立时延
- 请求报文的传输时延，服务器处理请求的时延，回送报文的传输时延

#### 性能聚焦点

##### TCP连接的握手时延

TCP连接时所发送的确认分组在40~60子节左右，加上三次握手。结果是，小的HTTP事务可能会在TCP建立上花费50%或者更多时间。

##### 延迟确认

TCP为了保证可靠传说具有自己的完整性校验与确认包等机制，由于于确认报文很小，所以 TCP 允许在发往相同方向的输出数据分组中对其进行“捎 带”。所以为了增加这种“捎带”的利用性，许多TCP栈实现了一种“延迟确认”算法：**延迟确认算法会在一个特定的窗口时间（通常是 100 ～ 200 毫秒）内将输出确认存放在缓冲区中**，以寻找能够捎带它的输出数据分组。

但是，HTTP 具有**双峰特征**的请求 - 应答行为降低了捎带信息的可能。当希望有相反方向回传分组的时候，偏偏没有那么多。所以，这种情况下延迟确认算法反而会引入相当大的时延。根据所使用操作系统的不同，可以调整或禁止延迟确认算法。

在对 TCP 栈的任何参数进行修改之前，一定要对自己在做什么有清醒的认识。TCP 中引入这些算法的目的是防止设计欠佳的应用程序对因特网造成破坏。对 TCP 配置进行的任意修改，都要绝对确保应用程序不会引发这些算法所要避免的问题。

##### TCP慢启动

TCP 数据传输的性能还取决于 TCP 连接的使用期（age）。TCP 连接会随着时间进行自我“调谐”，起初会限制连接的最大速度，如果数据成功传输，会随着时间推移提高传输速度

如果没有重用现存连接的工具。这种机制导致新建立的连接比已经交换一定量数据的连接慢一些。

##### Nagle算法与TCP_NODELAY

由于每个TCP段有长达40子节的标记和首部，所以如果 TCP 发送了大量包含少量数据的分组，网络的性能就会严重下降。

Nagle 算法试图在发送一个分组之前，将大量 TCP 数据绑定在一起，以提高网络效率。这种算法鼓励发送全尺寸段，仅当所有其他分组被确认后才允许发送非全尺寸分组。如果其他分组仍然在传输过程中，就将那部分数据缓存起来。只 有当挂起分组被确认，或者缓存中积累了足够发送一个全尺寸分组的数据时，才会 将缓存的数据发送出去。

Nagel算法会引发几种HTTP性能问题，首先，**小的HTTP报文会因无法填满一个分组而产生时延**；其次，Nagle 算法与延迟确认之间存在交互问题：**Nagle 算法会阻止数据的发送，直到有确认 分组抵达为止，但确认分组自身会被延迟确认算法延迟 100 ～ 200 毫秒。**

HTTP 应用程序常常会在自己的栈中设置参数 TCP_NODELAY，禁用 Nagle 算法， 提高性能。如果要这么做的话，一定要确保会向 TCP 写入大块的数据，这样就不会 产生一堆小分组了。

##### TIME_WAIT积累与端口耗尽

当某个 TCP 端点关闭 TCP 连接时，会在内存中维护一个小的控制块，用来记录最 近所关闭连接的 IP 地址和端口号。这类信息只会维持一小段时间，通常是所估计的最大分段使用期的两倍（称为 2MSL，通常为 2 分钟，根据设备设置不同而不同）。

在性能压力基准测试上，通常只有一台或几台用来产生流量的计算机连接到某 系统中去，这样就限制了连接到服务器的客户端 IP 地址数（不能在 2MSL 时间内使用同端口同IP建立连接）。

在客户端IP不变情况下，每次连接到服务器上去时，都会获得一个新的源端口但由于可用源端口的数量有限（比如，60 000 个），而且在 2MSL 秒（比如，120 秒）内连接是无法重用的，**连接率就被限制在了 60 000/120=500 次 / 秒。**超过这个速率发起连接，即使连接用完就释放，也会导致TIME_WAIT端口耗尽问题。

要修正这个问题，可以增加客户端负载生成机器的数量，或 者确保客户端和服务器在循环使用几个虚拟 IP 地址以增加更多的连接组合。

即使没有遇到端口耗尽问题，也要特别小心有大量连接处于打开状态的情况，或为 处于等待状态的连接分配了大量控制块的情况。在有大量打开连接或控制块的情况 下，有些操作系统的速度会严重减缓。

### CSRF攻击

用户浏览一个正常业务网站A之后，浏览器中保存了相关cookie信息，然后在访问了恶意网站B，B网站页面通过代码，使用用户的Token发起对A的业务操作

解决方法：

验证 **Referer/同源策略**：（Referer需要来自于自己网站的URL）

使用 **JWT**（Json Web Token）：通过Header中存放的JWT进行验证，攻击者无法像获取cookie一样获取到这个内容并发起攻击，再加上SSL加密，使得JWT本身不被截获

设置**httponly**，防止js代码获取cookie

### XSS攻击

即试图通过一些手段修改正常网页（两种，一种类似SQL/CMD Injection形式，将脚本注入到服务器上，用户访问url时将注入远端js；另一种是外部攻击，直接去尝试通过某种方式修改），使得页面内嵌入指定js代码，访问的用户就会通过用户浏览器自动执行一些恶意js程序，达到攻击者的效果。

如果用户真的不幸成功执行了这些js程序，可以导致访问劫持跳转，提交表单，窃取cookie值等各种结果

解决方法：

**过滤与转码**：设计页面时，对敏感标签进行过滤，对于常见控制符进行转码

**输入限制**：限制某些可输入项的长度，特殊符号等

使用**现代浏览器**：现代浏览器可以控制js只能访问自己所在网站的资源

### HTTPS机制

HTTPS 被称为 HTTP over TLS，HTTPS 的安全连接主要通过正确地完成 **TLS协议层握手** 来保证：

- 当客户端连接到支持 TLS 协议的服务器，要求创建安全连接，同时客户端列出受支持的**密码包(cipher)**（包括加密算法，散列算法等），开始握手
- 服务器从该列表决定密码包，并通知客户端
- 服务器发回其**数字证书**，这个证书通常包括**服务器的名称**、**受信任的证书颁发机构（CA）**和**服务器的公钥**
- 客户端确认其颁发的**证书的有效性**
- 为了产生一个用于安全连接的 **session key** ，客户端选择其中以下之一的策略：
  - 使用服务器的**公钥加密一个随机数，并将其发送到服务器**，这个数只能通过服务器自己的私钥解密；在会话期间，两边都使用这个随机数来生成一个唯一的 session key ，用于后续的加密和解密
  - 使用 **Diffile-Hellman 密钥交换方法**安全地生成用于加密和解密的随机唯一会话密钥，这个密钥具有**前向保密性**，即便服务器的密钥在未来被公开，它也无法被用于解密当前（过去）时间点的这个会话（即使这个会话被第三方截取）
- TLS协议的握手完成，开始利用产生的 session key 进行加密和解密，从而进行安全连接，握手完毕之后创建的连接是安全的，直到连接关闭
- 如果上述任何一个步骤失败，那么 TLS 握手过程就会失败，并且断开所有的连接

## 数据库（MYSQL & Redis）

### 1.MySQL- 视图

视图的作用：

简化查询

利于权限控制（比如建立一个开放部分数据的视图，然后再给一个仅能查询该视图的用户）

### 2.MySQL- 存储过程与函数

存储过程（stored procedure）和函数（stored function）统称为stored routines

区别：

- 存储过程实现的功能比函数**复杂**一些，而函数实现更具有针对性
- 存储过程可以调用**其他存储过程**，从而实现复杂操作。但是函数可以在**SQL语句中被调用**
- 存储过程可以返回**单个或多个结果集以及返回值**，甚至错误原因。但函数只能返回一个特定类型**值/表对象**，一般作为查询语句的一个部分调用
- 存储过程的 CRUD 操作**影响数据状态**，函数则不会

### 3.MySQL log

- **undolog**(InnoDB)
  - **回滚**日志文件，用于【事务执行失败】，修改异常等时进行回滚，以及在【MVCC】读中查看数据历史版本。
  - 由 **引擎层 InnoDB** 实现，属于**逻辑日志**
  - 记录数据修改被**修改前**的值。如果发生“把 id = 'B' 修改为 id = 'B2' ”则undo日志就会存放 id = 'B' 的记录。这样，如果这个修改出现异常，则可以通过该条undo日志实现回滚操作，保证一致性
  - 当事务提交后，undolog会置于一个待清理的链表中，等到判断没有数据用到该版本信息后再清理。
- **redolog**(InnoDB)
  - 重做**日志文件，用于**持久化硬盘。
  - 由 **引擎层 InnoDB** 产生
  - 记录数据被**修改后**的值，属于以页为单位的**物理日志，**记录物理数据页的修改信息，与SQL语句无关。
  - redolog包含两部分：一是内存中的日志缓冲(**redolog buffer**)，该部分日志是易失性的；二是磁盘上的重做日志文件(**redolog file**)，该部分日志是持久的。将redo日志缓冲刷盘到磁盘文件的策略可以人为指定（**innodb_flush_log_at_trx_commit选项**）
  - 当一条数据需要更新时,InnoDB会先将数据更新，然后记录 redoLog 在内存中，然后找个时间将redoLog的操作执行到磁盘上的文件上。不管是否提交成功都记录，如果回滚了，连回滚的修改也记录，从而保证事务的持久性。
  - 每个InnoDB存储引擎至少有**1个重做日志文件组（group）**，每个文件组下至少有**2个重做日志文件**，如默认的ib_logfile0和ib_logfile1，以循环写入方式运行。用户可以设置多个镜像日志组以提升可用性。
  - 用于【异常宕机】或者【介质故障】的数据恢复
- **binlog**
  - 由 **MySQL** 上层服务层自身产生，用于记录DML操作。
  - 属于**逻辑日志**，记录发生的SQL语句（DML），仅在事务提交完成后进行一次写入（redo log在事务进行中持续写入）
  - binlog 从缓存写入磁盘的策略也可以人为指定（**sync_binlog参数**）
  - 可以用于**恢复数据**与**主从复制**

### InnoDB特性

**Insert Buffer**：

对于不在缓冲池的非聚集索引页，不直接插入而是放到Insert Buffer对象中，以一定频率进行Merge

**异步IO**：

所有磁盘操作都是异步处理

**邻接页刷新**：

刷新脏页时检查该页周围页，如果是脏页一同刷新

**自适应哈希索引**：

对某个表进行多次存取后，如果引擎发现使用哈希可以提高性能，那么会将该表索引改为哈希索引

**Double Write**：

主要是为了提升数据页可靠性。

仅仅依赖 redo log，如果**写页时发生断裂（内存数据丢失，磁盘页写到一半受损）**，导致页本身的 checksum 等信息丢失，那么无法通过 redolog 修正。所以需要对写页这一步进行类似缓冲备份的的处理

该机制包含两部分存储：磁盘上（2M\*1）和内存（1M\*2）中。刷新脏页时，先复制到内存的 doublewrite buffer，然后buffer分两次，每次1MB刷到磁盘上的 doublewrite 段，写满后，再从buffer写入对应idb。

如果断裂发生在doublewrite，那么idb是干净的，可以redo恢复。如果断裂发生在idb，那么通过doublewrite备份覆盖idb，然后再redo恢复

**MVCC**

- - MVCC多版本并发控制是 **MySQL** 中基于乐观锁理论，用于 Read Commited 和 Repeatable Read 的实现
  - MySQL中，在表中每条数据后面添加两个字段：最**近修改该行数据的事务ID**，以及**指向该行回滚段（undo** **log表中）的指针**。
  - 引入 **ReadView** 的概念：ReadView 中包含以下四个信息

- - - **m_ids**：表示在生成readview时，当前系统中活跃的读写事务**id列表**；
    - **min_trx_id**：表示在生成readview时，当前系统中活跃的读写事务中最小的事务id，也就是m_ids中最小的值；
    - **max_trx_id**：表示生成readview时，系统中应该分配给下一个事务的id值；
    - **creator_trx_id**：表示生成该readview的事务的事务id；

- - 每次RC与RR的事务读取数据前会按规则产生一个ReadView ：RC在**每次读取数据前**都生成一个 ReadView ，RR在**第一次读取数据前**生成一个 ReadView ，之后一直复用该 ReadView
  - 获得 ReadView 后，按下面的规则按版本链顺序一直搜索到可访问的记录为止：

- - - 1、被访问版本：**trx_id == creator_trx_id****：**表明当前事务在访问自己修改过的记录，该版本**可以**被当前事务访问；
    - 2、被访问版本：**trx_id < min_trx_id：**表明生成该版本的事务在当前事务生成readview前已经提交，该版本**可以**被当前事务访问；
    - 3、被访问版本： **trx_id >= max_trx_id**，表明生成该版本的事务在当前事务生成readview后才开启，该版本**不可以**被当前事务访问；
    - 4、如果被访问版本的trx_id，**值****在readview的min_trx_id和max_trx_id之间，就需要判断trx_id属性值是不是在m_ids列表中？**

- - - - 如果**在**：说明创建readview时生成该版本的事务还是活跃的，该版本**不可以**被访问
      - 如果**不在**：说明创建readview时生成该版本的事务已经被提交，该版本**可以**被访问

#### 与MyISAM对比

| 特性     | MyISAM         | InnoDB                           |
| -------- | -------------- | -------------------------------- |
| 事务     | 否             | 是                               |
| 锁级别   | 表             | 行                               |
| 索引     | 索引与内容分离 | 支持聚簇索引，表内容存储在索引上 |
| 外键支持 | 否             | 是                               |
| 存储消耗 | 低             | 高                               |
| 内存消耗 | 低             | 高                               |

### 4.Redis 缓存雪崩 缓存穿透

#### 缓存雪崩

使用Redis【集群】，保证Redis服务不会挂掉

缓存【时间随机化】处理，避免集体失效

【限流降级】，如果某个服务不可用保证可以有某种备案使用，比如个性推荐服务不可用时换成热点数据推荐服务

#### 缓存穿透

接口做一些校验，比如用户本身的【鉴权】以及一些数据合法性的基础校验等

如果某次在缓存和数据库中都没找到某个数据，可以对该值增加一个【key-null值】，并设置较短有效时间

【布隆过滤器】，将所有key可能结果映射到布隆过滤器中，判断存在时才继续向下执行。

### 5.Redis 的近似 LRU 算法

由于性能原因，Redis 没有使用真实的 LRU 实现（这需要一个双向链表）

Redis 3.0 之后的做法是，提供一个待候选淘汰的 pool，存在按空闲时间排序默认的 16个 key。每次更新时，从 Redis 键空间随机选择 N 个 key，分别计算他们的空闲时间，仅当 key 在 ( pool 未满 并且 key 的空闲时间 >  pool 中的最小值时，才进入 pool)，然后，选择 pool 中空闲时间最大的 key 淘汰

### Redis 分布式锁

### Redis 缓存与DB同步

#### 基本运行方案：Cache Aside Pattern

- 读请求：读缓存，命中直接返回，否则查询DB返回，并将数据set到缓存
- 写请求：（如果要求强一致可以上对应key读锁）先更新DB，然后直接淘汰对应缓存（如果先淘汰缓存可能有读进程过来读从库数据写入），等待下次 cache miss

#### MySQL触发器 UDF函数（主动推送）

- 写请求：更新DB，根据触发器主动向redis写入

评价：较大程度影响mysql性能，适合读多写少的场景

### 通过Mysql binlog -> 中间件(canal) -> Redis

- 写请求：中间件伪装成slave，使master能推送binlog到中间件，中间件解析binlog后写入redis

### 6.数据库主从节点与复制主从表

![img](https://pic1.zhimg.com/80/v2-1b0c3f31bd398c39b9e0930059b0ca24_hd.jpg)

对于典型的主从：

三个进程（一个在主节点，两个在从节点）：

​	分别负责发送 bin-log（Log Dump thread），

​	请求 bin-log 并保存在从节点的 relay-log 中（I/O thread），

​	读取 relay-log 并执行（SQL thread）

两个从进程异步进行，互不干扰

主从复制本身存在两种模式：

异步：

​	主节点不主动push binlog，这样可能导致节点没法即时获得最新的 bin-log

半同步：

​	主节点默认情况延时 commit，当至少接收到一台从节点的返回后再commit，否则等待到超时再切换为异步并提交。

​    这样使得bin-log 至少传到了一个从节点上。

### 7.聚簇索引和非聚簇索引

如果索引B+树的叶子节点存储了**整行数据**的是主键索引，也被称之为**聚簇索引**。

一张表只能有一个聚簇索引

如果索引B+ Tree的叶子节点存储了**主键的值**的是非主键索引，也被称之为**非聚簇索引**

### 8.Hash索引和B+树索引对比以及应用

hash索引：

​	等值查找更快

​	不支持模糊擦护照与范围查找

​	性能不稳定

​	必然回表

**InnoDB自适应哈希索引：**InnoDB存储引擎会监控对表上各索引页的查询。如果观察到建立哈希索引可以带来速度提升，则会在B+树结构的索引基础上建立哈希索引，称之为自适应哈希索引。

### 9.最左索引原则

B+树对于联合索引原则上来说通过最左原则匹配，举例来说：对联合索引(a,b,c)，仅当`**where a = 'xx'**` / `**where a = 'xx' and b = 'xx'**` / `**where a = 'xx' and b = 'xx' and c = 'xx'**`三种情况（**a,ab,abc**）会走该索引，否则不走索引

但是存在“例外”，对于 `**where b = 'xx' and c = 'xx'**` 比如假设表中只存在 **a b c** 三个字段，查询的所有字段都可以在索引中找到，那么不需要再回表，情况变成了 **覆盖索引** 的情况

除此之外，还可能存在 mysql 隐式的**自动优化**情况：比如在上述例子中可以将 select * from table where b = 18 and c = 170 **改造**成 select * from table where a = '男' and b = 18 and c = 170 union all select * from table where a = '女' and b = 18 and c = 170，这样就可以走索引，但是这种优化是不确定事件，但是是一个需要考虑的因素。

### 10.Mysql 用户权限管理

### explain命令

#### 内容：

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1604159428212-a8b9d03a-5b2e-4d1a-a43e-b323e07bccd0.png)

- **id**: select选择标识符
- **select_type**: 表示查询的类型。
- **table**: 输出结果集的表
- **partitions**: 匹配的分区
- **type**: 表示表的连接类型
- **possible_keys**: 表示查询时，可能使用的索引
- **key**: 表示实际使用的索引
- **key_len**: 索引字段的长度
- **ref**: 列与索引的比较
- **rows**: 扫描出的行数(估算的行数)
- **filtered**: 按表条件过滤的行百分比
- **Extra**: 执行情况的描述和说明

#### explain 中的 select_type（查询的类型，主要是指明内外查询关系）

- **SIMPLE** (简单SELECT，不使用UNION或子查询等)
- **PRIMARY** (子查询中最外层查询，查询中若包含任何复杂的子部分，最外层的select被标记为PRIMARY)
- UNION (UNION中的第二个或后面的SELECT语句)
- DEPENDENT UNION (UNION中的第二个或后面的SELECT语句，取决于外面的查询)
- UNION RESULT (UNION的结果，union语句中第二个select开始后面所有select)
- SUBQUERY (子查询中的第一个SELECT，结果不依赖于外部查询)
- DEPENDENT SUBQUERY (子查询中的第一个SELECT，依赖于外部查询)
- DERIVED (派生表的SELECT, FROM子句的子查询)
- UNCACHEABLE SUBQUERY (一个子查询的结果不能被缓存，必须重新评估外链接的第一行)

#### explain 中的 type（表的连接类型）

1. **system**：最快，主键或唯一索引查找常量值，只有一条记录，很少能出现
2. **const**：**PK或者unique**上的**等值**查询
3. **eq_ref**：**PK或者unique**上的**join查询**，等值匹配，对于前表的每一行(row)，后表只有一行命中
4. **ref**：非唯一索引，等值匹配，可能有**多行命中**
5. **range**：索引上的范围扫描，例如：**between/in**
6. **index**：索引上的全集扫描，例如：InnoDB的**count**
7. **ALL**：最慢，**全表**扫描(full table scan)

#### explain 中的 Extra（执行情况的补充描述和说明）

1. **Using where**: 不用读取表中所有信息，仅通过索引就可以获取所需数据，这发生在**对表的全部的请求列都是同一个索引的部分**的时候，表示mysql服务器将在存储引擎检索行后再进行过滤
2. **Using temporary**：表示MySQL需要使用临时表来存储结果集，常见于排序和分组查询，常见 group by ; order by
3. **Using filesort**：当Query中包含 order by 操作，而且**无法利用索引完成的排序**操作称为“文件排序”
4. **Using join buffer**：改值强调了在获取连接条件时没有使用索引，并且需要连接缓冲区来存储中间结果。如果出现了这个值，那应该注意，根据查询的具体情况可能需要添加索引来改进能。
5. **Impossible where**：这个值强调了where语句会导致没有符合条件的行（通过收集统计信息不可能存在结果）。
6. **Select tables optimized away**：这个值意味着仅通过使用索引，优化器可能仅从聚合函数结果中返回一行
7. **No tables used**：Query语句中使用from dual 或不含任何from子句
8. **Using Index：** 表示相应的select操作中使用了覆盖索引（Covering Index），避免访问了表的数据行，效率不错

1. 1. 如果同时出现**Using Where**，表明索引被用来执行索引键值的查找，即没有符合前导列
   2. 如果没有同时出现**Using Where**，表明索引用于读取数据而不是执行查找。即索引符合前导列

## 各种小设计，算法等

### 撤销反撤销的实现

维护一个undoStack，reversStack，分别顺序存放正常操作和撤销过的操作

操作、撤销操作分别压栈即可；执行不可回滚操作时，清空undoStack，执行任何操作后清空reversStack

### 排序算法相关

#### 各类排序算法速度

![image-20210320232649291](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210320232649291.png)

**不稳定：选择，希尔，快速，堆**

**最好最坏速度差别小：归并，堆，希尔**

#### 快排基准元素的选择

如果选择随机一个元素作为基准点，那么在非特殊情况下的排序，出现最坏情况的概率大概为 1/(N*N)

**当重复元素非常多时**：序列很容易被划分为两个极不平衡的列，导致算法复杂度退化。这个时候可以采取**两路快排**的方式：【通过两个指针将i, j分为 <=V 和 >= V 两个部分，两侧都找到第一个不符合规则的元素（包括相等元素）的时候，交换这两个元素然后继续循环执行这个过程直到指针相遇】，这样至少可以保证在中部存在大量相等元素时两个指针可以互相向中部靠拢

#### 实际语言的实现

**Java 的 Arrays.sort()（jdk1.8） 中**采用了 **插入排序、双轴快速排序和归并排序（或Timsort）**组合的方式

虽然包括一些额外的判定（比如会事先判定数组基本有序性等），但基本会按照这个规律：

当数组长度小于 47：插入排序

当数组长度大于 286：归并排序（有序性好的时候采用 Timsort）

大于 47 小于 286：快速排序

和基本快速排序的差异：**先选取5个经验位置采样点，对五个采样点插入排序，然后选择其中 e2 e4 点作为快速排序的两个轴值less great**

选取轴后，先跳过数组两个分别小于 less 和 great 的部分，然后使用一个指针在less 和 great之间进行筛选，最终将数据分为三个部分，然后对两边进行递归的快速排序，再对中间进行递归排序

如果选择的五个元素刚好相等，选择传统的3-way快排

### 洗牌算法

#### Collections.shuffle()

```java
for (int i=size; i>1; i--)
    // 交换指定位置的两个元素
	swap(list, i-1, rnd.nextInt(i));
```

设置一个指针i从尾部开始，每次将 i 位置和 [0,i] 范围内随机一个位置的数进行交换（也可以理解为每次对未处理的数字中随机选择一个放到尾部

#### Fisher-Yates Shuffle

每次从原始数组中随机选择一个数字到新的数组中

#### Knuth-Durstenfeld Shuffle

和 Collections 的做法类似

## 系统设计思路

### 高并发的秒杀系统

**CAS**：首先验证库存和库存更新使用sql语句级别的 CAS 方式（版本值）

**请求限流**：请求量远远大于资源量的场合，那么大部分请求将是无效请求，尽量让这些请求在抵达数据库前被拒绝。可以使用第三方进行请求限流器，比如使用 redis （令牌桶，漏桶（请求时将当前时间以秒为单位的key写入redis（2秒超时时间），同时间的请求发生时对key值自增，如果达到阈值，返回错误））

**区别化限流/库存缓存**：除此之外，由于 redis 的限流措施不一定满足不同商品的流量差别，可以考虑将库存量信息作为 Redis 缓存，由于实际下单仍然保证在数据库CAS完成，通过 Redis 库存缓存来放行请求不会影响业务安全性。

**异步**：最后如果想进一步提高并发量，可以考虑请求异步化，下单请求通过限流和库存校验后，将订单任务发给 kafka，请求直接返回，通过消费程序从 kafka 获取下单任务并入库落地，完成后回调反馈给用户订单完成的情况（成功/失败）

### CAP 定理

- **一致性（Consistency）：**更新操作成功并返回客户端后，所有节点在**同一时间的数据完全一致**（等同于所有节点访问同一份最新的数据副本）
- **可用性（Availability ）：**服务一直可用，而且是正常响应时间，保证每个请求不管成功或者失败都有响应。
- **分区容忍性（Partition Tolerance）：**分布式系统在遇到**某节点或网络分区故障**的时候，仍然能够对外提供满足一致性或可用性的服务。

ZooKeeper 保证CP（极端环境下会丢弃一些请求，进行Leader选举时不可用）

Redis（单机版）保证CP，牺牲A，保证用户看到相同数据（没有冗余存储）和Master网络出错时，其他隔离子系统可以互相通讯

Redis不自动冗余数据

### BASE理论

定义：基本可用（Basically Available），软状态（Soft），最终一致性三词语的缩写，

- **基本可用：**系统**不可预知故障时允许损失部分可用**性（延长响应时间等）
- **软状态：**允许不会影响系统整体可用性的数据中间状态，也就是说，允许系统在不同节点的数据副本之间进行数据同步的过程中存在延时
- **最终一致性：**最终一致性强调系统中所有数据副本，经过**一段时间的同步之后，最终能达到一个一致状态**。因此，最终一致性的本质是需要系统最终数据能够达到一致，而不是实时一致。

### 请求防重

在程序中为每个请求添加唯一注解号，写一个切面类和自定义注解，切面类中通过Redis交互实现防重，为所有需要防重的请求添加这个注解

### 大文本集去重

打开