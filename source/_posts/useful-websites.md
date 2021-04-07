---
title: 实用网站与应用分享（一）
date: 2021-03-14 01:16:37
categories: 实用工具
tags:
- 实用工具
---

分享一些在我上网冲浪过程中收藏过或者有在实际使用的实用应用/插件/网站（更新中）

## 1. 搜索 Everything

![image-20210314234933653](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210314234933653.png)

**描述：一个本地文件快速搜索器**

一个极简且方便的本地文件搜索应用，安装并配置完成后搜索自己电脑上的文件基本没有响应时间就能出搜索结果，也很难出现搜不到的情况（原理我猜测应该是空间换时间，对磁盘上所有文件创建了前缀树），比windows资源管理器自带的搜索快很多。

## 2. Sublime Text 3

![image-20210315000050370](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210315000050370.png)

**描述：一个启动很快的代码查看器**

作为一个前后端都经常有在接触的人，经常会为了看一个项目某个部分一会儿打开这个IDE一会儿打开那个IDE的情况，有时只是想点开一个xml配置文件稍微改动一下，或者说单纯只是从网上下到了一个大神的项目想分析下结构，这种时候IDE就很笨重，但是用记事本打开又很不方便

这时候 Sublime Text 的优势就体现出来了，由于它本身并不是任何语言的一个 IDE （Sublime 可以加上插件作为 IDEA ，但是我没有使用这种方式），所以启动非常快，相当于一个带代码格式化和代码高亮的记事本，当我只是想看看某个项目文件的代码的时候，或者我只想改一下某个配置文件时，我一般就直接用 Sublime 打开了，很方便（而且还可以加入系统上下文，对任何文件直接用右键选择“用 Sublime”打开）

## 3. devhints.io

![image-20210315001224927](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210315001224927.png)

![image-20210315001712267](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210315001712267.png)

**描述：一个程序员用的各种语言的语法速查站**

虽然我们平时编程到一半的时候遇到某个语法突然想不起一般都是直接去百度或者一直挂着那个语言的文档，但是这个网站给了你一个更集中方便的选择，它支持几乎各种语言的语法速查。

## 4. OneTab

![](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210315002111339.png)

**描述：一个高效的网站归档暂存的 chrome 插件**

作为程序员，想学习一个内容或者改一个bug的时候打开一连串网页是常态，但是当你不得不暂时得“挂起”手头学习的内容的时候，这一连串的网页如何处理又是问题，如果就这么放着不管过两天又会埋藏进历史记录的深海中。

Chrome 上的插件 OneTab 提供了一个很好的选择，一键就能将当前chrome包含的所有页面打包集中收集在 OneTab 页面里，方便我们随时挂起当前任务和继续以前的任务的需求

## 5. Postman

![image-20210315004107926](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210315004107926.png)

**描述：一个方便强大的API调试和http请求工具**

说来惭愧，我去年调试自己的后端接口的时候还是另外写了一个 java 的 http 请求类然后硬修改 java 代码来进行调试的

Postman 提供了一个比这个方便的多的 Api 调用的可视化操作工具，可以方便的进行参数的增删，请求头的修改和 body 的输入等，比浏览器输入和自写请求工具类方便得多。

## 6. Termius

![](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210315004623316.png)

**描述：一个启动很快的全平台SSH软件**

Termius 的 UI 比 XShell 现代很多，启动非常快，如果已经配置过主机，从启动到连接基本就是秒级别。

如果使用付费还可以使用 SFTP 等各种功能，但是免费版本身作为一个 SSH 客户端来说基本使用已经很足够了