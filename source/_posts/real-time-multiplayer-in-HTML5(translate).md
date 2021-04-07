---
title: 用网页实现一个即时多人对战游戏[翻译]
date: 2020-11-09 21:24:09
categories: 游戏服务端
tags:
- 游戏服务端
- 翻译
---

>  原标题：Real Time Multiplayer in HTML5
>
> 原文链接：[**http://buildnewgames.com/real-time-multiplayer/**](http://buildnewgames.com/real-time-multiplayer/)
>
> 根据情况对原文进行了适当的删改，仅保留实现的关键点部分

（注：本文章演示了基于HTML5的一个小型多人即时在线游戏的demo设计）

## Gameplay部分

### 帧速率

物体的移动不能简单地通过在Update()函数循环+=1来完成（因为存在刷新率的概念，即Update()不一定会在单位时间内以相同频率运行同样的次数），所以需要引入**增量时间（deltaTime）**的概念

deltaTime 的值为**渲染每一帧所花费的毫秒数（ms per frame）**， 使得每帧移动的像素距离根据帧率变化而变化，从而达到在任何帧率下具有相同速度的效果

![deltatime](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/deltatime.png)

## 多人游戏基本流程

除了 GamePlay 本身之外，GamePlay 之前的各种准备流程也是需要考虑的部分，包括客户端之间的通讯，客户端与服务端的连接等

这个基本的流程如图所示

![network1](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/network1.png)

## 网络与游戏循环

在这个多人游戏demo中，我们希望在服务器和客户端上能够同时运行相同的游戏逻辑。

在服务器上，从网络获得的输入将会被执行并实施到所有player上，然后，这一更改将会以一个固定的频率发送给其他player；在客户端上，输入将会被捕捉并发送给server，同时位置将会在在等待服务器回应的同时就进行更新（通过 **客户端预测** 的手段）

这是一个整体流程的例子：

1. 客户端侧按下"右"键，player将立刻向右移动
2. 服务器接受这个输入信息，并保存起来等待下一次更新
3. 服务器进行更新，实施player的输入，将其在服务器状态上向右移
4. 所有状态上的更新将被发送给所有的客户端
5. 客户端接受消息，并立刻设置这个（具有更高权威性的）player position
6. 对于返回数据和预测数据之间的误差，客户端应该进行一些平滑处理

![network2](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/network2.png)

### 游戏服务器建立

在服务器上，存在两个运行中的 loop：**物理更新循环（Physics updates loop）**和**服务器更新循环/数据广播循环（Server updates loop）**

- 物理循环：以相对较高的频率更新，主要是为了更新服务器的物理状态
- 服务器循环：以相对较低的频率更新，主要是为了广播服务器状态

### 服务器物理循环（66hz,每15ms一次update）

物理循环指的是服务端获得客户端输入后如何修改其服务器上的游戏状态，为了正确执行游戏逻辑，物理循环的频率需要更高

服务器的物理循环过程如下：

- 处理我们从网络存储的输入
- 根据存储的输入来确定他们打算移动的方向
- 将此方向的更改应用于玩家位置
- 存储最后处理的输入数字
- 清除我们存储的所有输入

### 服务器数据广播循环（22hz,每45ms一次update）

更新循环将服务器的状态发送到所有客户端。具体状态包含哪些内容因游戏而异，在我们的示例中，状态由

**【玩家位置，已经处理过的玩家输入（最后处理的输入编号），本地服务器时间】**

组成

状态更新中发送的内容取决于自己，通常可以采用多个服务器更新循环来降低使用的流量。一个简单的例子是昼/夜循环。如果周期的变化率远低于其他所有变化，则可以每5秒而不是每45毫秒发送一次太阳状态。

### 客户端更新循环

在客户端我们也执行类似的循环，通常帧率会达到60fps或以上。在 HTML5 中，我们通常使用 **RequestAnimationFrame** 来处理这个更新。

更新循环的过程如下：

- 清空 canvas
- 绘制信息与状态
- 处理输入（**发送input**到服务器）
- **更新位置 （使用客户端预测）**
- **根据server position更新其他player位置 (通过插值)**
- 在 canvas 上**绘制**其他players

### 客户端物理循环

客户端物理循环的关键就是要一直**保持客户端位置与服务器所决定的位置同步**，给定相同的输入，服务器端和客户端物理都应该尽可能得出相同的结论，这样才能使客户端预测能够有效地掩盖客户端在网络上的延迟

为了达到这个目的，客户端需要经常根据服务器的反馈修正本地游戏的误差

## 重要的网络概念

### client prediction（本机客户端预测）

虽然客户端的游戏物理循环需要严格保持与服务器位置同步，但是如果只通过服务器回传数据更新位置，那么我们从**输入到获得游戏响应之间可能存在很大的延迟**，这将导致游戏几乎无法游玩。

解决方法就是 client prediciton ，即在**输入后立刻进行操作，并且预测服务器结果**，假设客户端与服务端计算结果一致，那么本地播放将达到和服务器端一样的效果。当然，如果从服务器收到的信息与本地不一致，或者出现丢包等问题，那么本地需要有适当的补正。

### Interpolation of other client positions（他机客户端位置插值）

对于在本地客户端显示的其他客户端信息，由于信息全部来自于网络，如果简单根据服务器得到的信息简单显示，也将导致渲染混乱。

解决的方法就是**收到服务器信息后先存储起来**，然后在已存储的位置信息中进行插值，这样会使得我们所绘制的位置信息将略晚于服务器几帧，但这样将允许我们对其他player的位置进行非常顺滑的绘制。

根据起源引擎的文章，在我们的demo中我们绘制的位置将晚于实际服务器位置100ms。

## 理解demo代码

### demo结构

代码包含四个文件，每个都是项目重要的一部分。

每个文件的作用如下所示：

- **client.js** 游戏客户端在浏览器上运行的逻辑
- **app.js** 服务器侧在node.js上运行的程序，包含 node/express/socket.io 等关键组件的组织与配置
- **game.server.js** 游戏服务器的逻辑（比如“大厅”）
- **game.core.js** 游戏本身的逻辑，包含服务端和客户端

#### 核心游戏代码

game.core.js 是示例中的重要部分。该代码在服务器（在node.js上运行）和客户端（在浏览器中运行）之间**共享**。这使得代码**可以完全使用相同的功能和算法来处理输入，同步运动和共享数据结构**。

但是游戏本身运行的游戏逻辑代码非常简单（仅仅包含个体的四方向移动和墙面的碰撞检测）

game.core.js 文件包含三个class，细节如下所示

#### The *game_core* class

该class是整个游戏状态的驱动因素。它包含这些功能：

- 运行update函数
- 处理游戏的网络输入输出
- 游戏发生信息改变时管理这些更改

该 game_core 可以被描述为 **game world** 。这个 world 包括两个player，一个边界，同时运行这个 world 的逻辑。这个类保证物理模拟正确并且能处理正确时间的player inputs。

这个 game world 是多人游戏本身发生的场所。我们希望这个 game world 能够在三个地方同时存在（对于这个demo而言）。所以我们需要在每个 client 以及 server 上运行一份这个 game world 的 **copy** —— 这属于 **game.server.js** 中游戏大厅（**lobby**）的功能，它创造一个 world 使得每一组 players 能够加入。

每个代码都根据其产生的作用而命名。由于整个代码在服务器端与客户端共享，如果函数命名以 `client_` 开始，那么该函数必然将不会在 server 上被调用，同理，以 `server_` 开头的函数则相反。除此之外的其他函数则都直接和游戏状态相关，在server 和 client 之间共享使用 

#### The *game_player* class

player 的核心代码可能远比想象的简单地多，但是每个 player class 只是简单地包含自己属性以及如何绘制他们本身。绘制代码不会在 server side 被使用

## 代码中重要功能的实际实现

### 实体插值（对于其他client）

包含其他客户端显示时的插值/平滑处理。主要包含以下逻辑：

- 将来自服务器的其他有关客户端的**网络消息存储**至少100ms
- 在当前最新的已知位置和更新的一个位置之间进行插值（比服务器时间晚100ms）
- 在插值位置绘制插值client

代码：

```javascript


client_onserverupdate_recieved = function(data){

//....
        
            //存储服务器时间（这将表示数据在网络上传输直到我们接收到为止发生的时延量）
        this.server_time = data.t;
            //更新本地offset时间，这个值会被我们向后推迟100ms（net_offset）
        this.client_time = this.server_time - (this.net_offset/1000);

//....

            // 缓冲我们从服务器获得的数据（server_updates 是一个存放缓冲的队列）
        this.server_updates.push(data);

            // 如果缓存长度超限需要进行截取
            // 如果我们的 buffer_size 按秒计算，那么这个限制长度应该为标准帧数*限制秒数
        if(this.server_updates.length >= ( 60*this.buffer_size )) {
            this.server_updates.splice(0,1);
        }

//....

} //onserverupdate


// 在我们绘制其他个体前，我们需要基于current_time，对它们在timeline上的位置进行插值

client_process_net_updates = function() {

    	// 第一步 : 需要基于current_time，找到它们在 timeline 上对应的 position
    	// 根据 current_time 我们一般会在 timeline 中获得两个position，一个在 current_time 前
    	// 我们分别将其称为 past_pos 和 target_pos，插值就发生在这个两个位置之间
    	// 然后 : 根据 past_pos target_pos current_time 三个参数对 other_pos 进行线性插值
    	// other player position = lerp ( past_pos, target_pos, current_time );

//....

        //other players 在 timeline 中在 current_time 之前以及之后的两个位置
    var other_target_pos = target.pos;
    var other_past_pos = previous.pos;

        // 只是基于网络位置缓冲的线性插值
        // 我们先计算ghost的位置（ghost的位置比我们渲染的other要提前100ms，即net_offset），用于后续smooth
    this.ghosts.pos_other.pos = this.v_lerp( other_past_pos, other_target_pos, time_point );

        //如果我们开启了 client_smoothing 选项
    if(this.client_smoothing) {

            // 对 other_player 基于上一次 other 位置和现在 ghost 位置进行再次线性插值
        	// 这个插值程度值将由我们设置的 smooth 度和物理发生的 delta_time 共同决定
        this.players.other.pos = this.v_lerp( this.players.other.pos, this.ghosts.pos_other.pos, this._pdt*this.client_smooth);

    } else {

            // 如果没有开启 client_smoothing 选项，直接将 other_player 移动到 ghost 位置上
        this.players.other.pos = this.pos(this.ghosts.pos_other.pos);

    }
//....
}
```

### 本机客户端预测（本地client）

预测发生在两个位置：收到 **server 有效应答时**，以及 **绘制本地输入结果前**，逻辑如下所示：

- 处理 client 输入
- 存储输入以及输入的时间（为了后续的平滑处理）
- 存储 inputs 序列
- 发送 inputs 序列到服务器

当收到server对最后一个已知的输入序列的确认后：

- 移除 server 已经确认处理过的那些 inputs
- 对仍然等待被确认的 inputs 进行再实施

简化的处理输入的代码如下所示：

```javascript
// 本地输入处理与发送
client_handle_input = function() {
    
//....

            //更新本地输入seq
        this.input_seq += 1;

            //保存当前的的输入状态，作为一个 snapshot 发送
        this.players.self.inputs.push({
            inputs : input,
            time : this.local_time.fixed(3),
            seq : this.input_seq
        });

            //发送数据
            //在输入的前面用"i."标记，代表发送的是一个输入相关的报文（因为客户端可能还会发送其他报文给服务器
        var server_packet = 'i.';
            server_packet += input.join('-') + '.';
            server_packet += this.local_time.toFixed(3).replace('.','-') + '.';
            server_packet += this.input_seq;
            
            //Go
        this.socket.send(  server_packet  );

//....

}


// 在 Update loop 以及当我们收到服务器的消息的时候，立刻更新 client position
// 因为 server 具有绝对主导权
// 但是为了位置的连贯性，我们也需要实施尚未从server获得确认的input

client_process_net_prediction_correction = function() {
//....

        // 获得从server获得的最新的一个 server data
    var latest_server_data = this.server_updates[this.server_updates.length-1];

    	// 提取自己的数据
    var my_last_input_on_server = this.players.self.host ? 
                                    latest_server_data.his : 
                                        latest_server_data.cis;

        //如果server向我们发送了 'host input sequence' 或者 'client input sequence' 状态
    if(my_last_input_on_server) {

        var lastinputseq_index = -1;

            //根据最新的server数据，查找本地inputs序列中的对应下标（lastinputseq_index）
        for(var i = 0; i < this.players.self.inputs.length; ++i) {

            if(this.players.self.inputs[i].seq == my_last_input_on_server) {
                lastinputseq_index = i;
                break;
            }

        }

            //Now we can crop the list of any updates we have already processed
        if(lastinputseq_index != -1) {

            //since we have now gotten an acknowledgement from the server that our inputs here have been accepted
            //and we now predict from the last known position instead of wherever we were.

                // 根据 server 确认情况，移除已经得到确认的inputs序列
            var number_to_clear = Math.abs(lastinputseq_index + 1));
            this.players.self.inputs.splice(0, number_to_clear);

                // player 现在将被放置到到新的 server location
            this.players.self.cur_state.pos = this.pos(my_server_pos);
            this.players.self.last_input_seq = lastinputseq_index;
            
                // 现在我们需要对 server 尚未确认的 inputs 进行再实施，这将使得我们的动作能够连贯继续下去
                // 同时也需要同时对server position 进行再确认
            this.client_update_physics();
            this.client_update_local_position();

        } // if(lastinputseq_index != -1)
    } //if my_last_input_on_server


//....
}
```