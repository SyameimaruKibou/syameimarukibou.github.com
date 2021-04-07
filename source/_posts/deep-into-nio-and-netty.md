## Java NIO

### 基本

于JDK1.4 引入，并且已经基于nio重新实现了旧的I/O包，即使不显式用nio编写代码，nio也已经在旧io中发挥了作用

其速度的提高是因为nio的结构更适用于操作系统执行I/O的方式：**通道(Channel)** 、**缓冲器(Buffer)**、**多路复用选择器(Selector)**，**分别负责传输和存储。我们只能与Buffer交互，Channel要么从Buffer获得数据，要么向Buffer发送数据。**Selector则是提供一种单线程非阻塞的处理**多个连接**的手段（多用于网络）

Java NIO 将 NIO 抽象为 Channel ，Channel 又可以分为 FileChannel 和 SocketChannel，分别用于文件io和网络io

### NIO的文件读写基本操作过程

```java
// 文件写

// 1. 从FileStream 获得一个 Channel
FileChannel fc = new FileOutputStream("data.txt").getChannel();
// 2. 显式调用 allocate() 方法分配 ByteBuffer 的存储空间，可以通过 allocateDirect() 分配更快的堆外内存
ByteBuffer buff = ByteBuffer.allocate(1024);
// 3. 向 buffer 写入数据（包括编码格式）
buff.put("Some Text".getBytes(StandardCharsets.UTF_8))
// 4. 让 ByteBuffer 做好向 Channel 写入数据的准备(position = 0)
buff.flip();
// 5. 使用ByteBuffer写入Channel
fc.write(buff);
// 6. 关闭 Channel
fc.close();

// 文件读

// 1. 从FileStream 获得一个 Channel
FileChannel fc = new FileInputStream("data.txt").getChannel();
// 2. 显式调用 allocate() 方法分配 ByteBuffer 的存储空间，可以通过 allocateDirect() 分配更快的堆外内存
ByteBuffer buff = ByteBuffer.allocate(1024);
// 3. 告知 Channel 向 ByteBuffer 存储字节
fc.read(buff);
// 4. 让 ByteBuffer 做好被读取数据的准备(position = 0)
buff.flip();
// 5. 循环输出 ByteBuffer 中的结果（其中还涉及到格式转换/解码过程）
while(buff.hasRemaining())
    System.out.print((char)buff.get());
```

### 分配 ByteBuffer 的三种方式

mmap（内存映射），allocateDirect（直接内存），allocate（堆内内存）

mmap 构造时将绑定一个 fd，使得读写数据时不需要再经过**内核空间到用户空间的copy交换**，两个空间将映射到同一个内存上

读写速度上 mmap -> allocateDirect -> allocate

## Netty

### 关键组件

#### BootStrap、ServerBootstrap

作用是引导和配置一个 Netty 应用，**串联各个组件**

#### Future、ChannelFuture

用于保存异步处理结果，它们可以**注册一个监听**，当操作失败或成功时会自动触发注册的监听事件

#### Channel

Netty 网络通信的组件，用于**执行网络 I/O 操作**

可以通过 Channel 获得当前网络连接的通道状态，配置参数等。

对于异步网络调用将立即返回一个 ChannelFuture 实例，通过在 ChannelFuture 上注册监听器，可以在 I/O 操作有回应时通知调用者

可以有不同协议和不同阻塞类型的 Channel（TCP、UDP等）

#### Selector

Netty 基于 Selector 对象实现 I/O 多路复用，通过 Selector，**一个线程可以监听多个连接的 Channel 事件。**

向一个 Selector 中注册若干个 Channel，Selector 内部机制就可以不断查询（select）注册的 Channel 中是否含有已经就绪的 I/O 事件（可读写，网络事件完成等），使得程序可以简单地使用一个线程高效管理多个 Channel

同时，对 selector 中的 selectedKey 集合进行了替换，替换为了自己实现的 set 集合，效率更高

#### ChannelHandler及其实现类

一个接口，**用于处理 I/O 事件或者拦截 I/O 操作，并将其转发到 ChannelPipeline (业务处理链) 中的下一个处理程序**

由于接口包括的方法太多，经常使用其他实现类（处理**入站I/O**：`ChannelInboundHandler`，处理**出站I/O**：`ChannelOutboundHandler`），通常是自行定义一个 Handler 类去继承 ChannelInboundHandlerAdapter，需要自行实现各种方法来实现业务逻辑

方法实现通常包括 通道注册事件、通道取消注册事件、通道就绪事件、通道读取数据事件、通道数据读取完毕事件、通道异常事件等

#### Pipeline、ChannelPipeline

是一个由 Handler 组成的 List，负责处理和拦截 inbound 或者 outbound 的事件和操作，相当于一个贯穿 Netty 的链

每个 Channel 有且仅有一个 ChannelPipeLine 对应

入站事件和出站事件在一个双向链表中，入站事件会从链表 **head 往后传递**到最后一个入站的 handler，出站事件会从链表 **tail 往前传递**到最前一个出站的 handler，两种类型的 handler 互不干扰

#### EventLoopGroup、NioEventLoopGroup

用于更好地利用多核 CPU 资源，实现 Reactor 模型。

![image-20210404193227509](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210404193227509.png)

```java
EventLoopGroup bossGroup = new NioEventLoopGroup(1);
EventLoopGroup workerGroup = new NioEventLoopGroup();
ServerBootstrap b = new ServerBootstrap();
b.group(bossGroup, workerGroup)
 .channel(NioServerSocketChannel.class)
 ...
```

bossGroup 中只有一个线程, 而 workerGroup 中的线程是 CPU 核心数乘以2, 因此对应的到 Reactor 线程模型中, 我们知道, 这样设置的 NioEventLoopGroup 其实就是 Reactor 多线程模型。