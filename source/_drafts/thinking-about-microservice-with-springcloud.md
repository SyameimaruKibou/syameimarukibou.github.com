---
title: 纸上谈兵，从SpringCloud起步谈谈个人对微服务的认识
date: 2021-03-15 16:43:33
categories: 微服务
tags:
- 微服务
- Spring
---

## 定义与基本理解

> 微服务是一种开发软件的架构和组织方法，其中软件由通过明确定义的 API 进行通信的小型独立服务组成。这些服务由各个小型独立团队负责。
>
> —— Amazon Web Service (AWS) 首页（ https://aws.amazon.com/cn/microservices/）对微服务的解释

>*Microservice architecture – a variant of the service-oriented architecture(SOA) structural style – arranges an application as a collection of loosely coupled services. In a microservices architecture, services are fine-grained and the protocols are lightweight.*
>
>微服务架构是一种基于服务架构（SOA）的变体，它将应用编排为一系列松耦合服务的集合。在微服务架构中，服务应当足够细颗粒且通讯协议应当足够轻量
>
>—— 维基百科(EN)对 micro service 的解释

> 微服务就是一些协同工作的小而自治的服务
>
> —— Sam Newman《微服务设计(Building Microservice)》

根据以上各个解释我们可以简单地认识到，微服务架构有这些要素：

- **服务**
- **通讯协议**

所以 **微服务 = 服务 + 通讯协议**

~~本文结束……当然不可能~~

让我们再稍微深入理解一点点，但是不要太深入 	

**通讯协议**应该相对来说比较容易理解，就是服务用何种方式去使用另一个服务，我们可以去用我们典型的前后端分离的小项目去对比，前端通过发起 http 请求来获得资源（使用后端服务）的方式就是一种通讯协议的表现，在这种情况下我们使用了一种(http之上的) RESTful 通讯协议，当然，除了RESTful还有别的，RPC，GraphQL等。但是到此为止，我们已经清楚了通讯协议大概要做什么

那么什么是**服务**？

从上述定义的描述中我们可以明白，这些服务有这些特点：

细颗粒，自治，（服务间）松耦合

如何理解**细颗粒**和**自治**？也许我们很容易理解字面上的意思，如果要让我们自己来操刀将自己的应用进行细分的时候可能又很难下手。我个人的体验是它们应该具有相互调节的关系，**我们尽可能让切分出来的应用粒度足够细，但是又要保证它包括足够的内容可以保证自身功能的自治（独立进行）**。（对于到底多细，Sam Newman 给出的一个参考是”一个团队能够足以维护为止“）

至于**松耦合**，比起性质它更像是一个评量服务好坏的标准，它从另一个方面为我们提供了如何切分应用的参考，这可能就需要涉及具体业务，自身选择暴露的API甚至是选择的通讯协议本身。虽然让一个应用切分为互相松耦合的服务集很难，但是对于每个服务，一个很方便的从结果验证的定义方式是：**如果服务是松耦合的，那么修改这个服务内部内容后应该不需要去修改其他服务**

至此，我们大致就了解了微服务的基本含义，当然，这些内容还远远不足以能够支撑我们去完成一个能够在现实场景派上实际用场的微服务应用。

## 从SpringBoot起步

大概还是我开始第一次用 SpringBoot 构建后端应用的时候，编写完成之后我按一如既往的方法输出了 war 文件并将其放到了 Tomcat 容器中，然而应用却没有像预想的一样运行。最后查了多方资料之后，才知道 SpringBoot 自己已经集成了 Jetty 服务器容器，不用再需要手动提供 ——这是我第一次对于 SpringBoot 独立性的体会，当然， SpringBoot 本身的独立并不仅仅只是这么浅显的一点点。

为什么突然提到 SpringBoot ？因为 SpringBoot 这样的独立性和我们刚刚提到的服务的特征非常相似——它可以在一个 SprintBoot 应用的基础上

![](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210329152803297.png)

## 微服务的代价

