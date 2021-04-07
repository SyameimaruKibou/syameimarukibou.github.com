---
title: 使用 Hexo + Github Pages + Travis 自动部署个人博客
date: 2021-03-05 14:55:08
tags:
- hexo
- CI/CD
---
## 背景

本人大概从去年（20年）才逐渐开始有了记东西的意识（在此之间想记有用的东西的时候基本都是进收藏夹吃灰），同时希望能够云端同步使得我能在其他设备上观看，但是博客的形式又太正式（不适合逐步完善或者随手记一些小东西），Typora这些简单编辑器又不适合统一管理。所以开始有意识地找这类软件，然后找到了一个叫【语雀】的算是比较适合这些需求的知识库软件。

但是时间一长，另外的问题暴露出来：简单的一层分类开始膨胀，找一个内容有时候要找半天，已经完工的内容和随手记的半成品内容杂糅。加上语雀没有移动APP只有微信小程序（启动速度和操作速度感人）。我意识到果然还是必须要养成写博客的习惯，一个是要下意识去养成一个完成什么东西的意识，二来也是一个日积月累的过程。

机会难得，既然要写博客的话就要去尝试新的东西，所以我没有去用csdn或者博客园之类常见的现成博客平台，而是用了偶然得知的静态博客框架 Hexo，在各类教程的帮助下终于算是完成了一个比较完整的 hexo 体系（hexo + github pages + travis CI）。于是我也来简单地记录一下我搭建我的博客的过程。

## hexo 基本安装

搭建过程中参照的文章：

hexo 官方教程：https://hexo.io/zh-cn/docs/

不如 的文章：hexo你的博客：http://ibruce.info/2013/11/22/hexo-your-blog/

zthxxx 的文章：使用 Travis 自动构建 hexo 到 GitHub：https://blog.zthxxx.me/post/build-hexo-blog-by-travis-ci/#

（写这篇文章的时间点这位老哥的博客不知道为什么上不去了...）

首先 hexo 依赖于 Node.js，同时后续的部署和模板下载都需要 Git 支持，所以如果没有的话需要先安装这些内容：

- [Node.js](http://nodejs.org/) (Node.js 版本需不低于 10.13，建议使用 Node.js 12.0 及以上版本)
- [Git](http://git-scm.com/)

前置程序安装完成后，用 npm （Node.js 已经附带，如果提示无指令的话可以检查系统变量）就可以直接全局安装 hexo

```powershell
$ npm install -g hexo-cli
```

> hexo-cli 代表支持简单交互的 hexo 脚手架，现在 hexo-cli 已经包含了 hexo 本体，所以不需要再像以前一样先 install hexo 再 install hexo-cli

安装完成后进行初始化操作以及基本内容下载

```powershell
$ hexo init <folder> # 初始化hexo结构
$ cd <folder> # 移动到文件夹
$ npm install # 下载必要依赖
```

folder 指的是我们希望放置我们的 hexo 博客本体的文件夹位置，如果不存在，hexo 会根据给定的 folder 自动在该目录下创建，我一般命名为 hexo_blog

npm install 会为我们下载并配置一个 hello_world 式使用一个默认主题的 hexo 项目，这使得我们的博客马上就可以投入使用，只需要再简单创建一篇文章即可

完成后，尝试通过指令生成一篇文章

```powershell
$ hexo new [layout] <title>
```

[layout]可以不填，这时直接使用默认的 layout（即post），仅需指定标题即可

这时候我们就可以赶紧来看一下我们博客的效果：

```powershell
$ hexo generate #或简写 hexo g，用于生成网页静态页面
$ hexo server # 或简写 hexo s，用于启动本地服务器
```

这时候命令行也会提示我们 Hexo is running at  `http://localhost:4000`，即 hexo 的默认部署端口为4000，点击进入就能看到我们的博客应该大概启动起来像这样：

![](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210305103544546.png)

> 这里是用了我已经操作过的界面，可能有点不同但基本应该长这样

到这里基本的本地 hexo 安装和演示基本就完成了

## hexo 远程部署：GitHub Page + Travis CI 自动构建

在进行下一步部署之前我们来梳理一下 hexo 的结构来确定我们的需求

就对 hexo 的文件结构来说，在不考虑其他内容的情况下 hexo 的关键内容有这些：

```
.
├── _config.yml		#hexo的基本配置文件 
├── package.json	#hexo依赖的内容
├── scaffolds		#决定新建文件的模板文件夹			
├── source			#用户资源存放处，主要是文章和图片资源等
├── themes			#主题，决定文章如何被渲染
└── public			#最终渲染出的博客页面，博客页面的关键
```

hexo本质上来说就是一个，所以我们可以把这些文件分成两部分：hexo配置，主题与源资源文件（**/public以外**的部分），最终渲染出的静态页面（**/public** 部分，即我们最终在`http://localhost:4000`看到的页面）。

到目前为止我们的操作就可以概述为这样的流程：

![](https://cdn.jsdelivr.net/gh/syameimarukibou/imagebox/img/image-20210305111320680.png)

所以如果要云端部署（让其他人可以通过互联网访问我们的博客），最关键的就是需要把我们输出的静态页面部署到可以连通互联网的远程服务器而不是本地的localhost上。

一种思路就是：一个是在个人云服务器（阿里云腾讯云等）上再安装一份hexo，然后在云服务器完整地进行以上的一套流程（编写文章 -> hexo -g -> hexo -s），然后就可以在本地访问我们的页面内容 

当然这样就相当麻烦，写完文章不但要手动上传到服务器，还需要再在服务器进行渲染等操作，不符合我们写博客的要求。

于是我们可以使用 GitHub Pages 完成我们的需求。简单来说，GitHub Pages 为我们提供免费的静态网页文件托管与解析服务，将我们渲染好的界面上传到指定的git仓库上（要求我们使用 username.github.io 作为仓库名，username是自己的github用户名），我们就能通过互联网访问我们生成好的博客界面。

### 使用Github Pages

**通过hexo配置一键部署**：hexo为我们提供了快速方便的一键部署功能，只要设置好配置就能通过一条指令（`hexo deploy`或`hexo d`）完成部署过程

实际上，hexo d 就相当于代替我们完成了**将本地生成的静态网页 git push -force 上了我们 Pages 托管的 git 仓库**的过程。

由于相当于使用 git 进行 push 操作，本地 git 需要有操作远程操作的权限（设置 SSH-key）。如果没有在本地配置过 SSH-key 则需要先进行 SSH-key 配置。SSH-key 的设置网上有很多教程，这里不再重复。

设置好后，在 hexo 项目下的 _config.yml 修改 deploy 项配置即可，如下：

```yml
deploy:
  type: git
  repo: <repository url> #git@github.com:SyameimaruKibou/syameimarukibou.github.io
  branch: [branch]	#master
  message: [message]
```

> 注意 repo 与 branch：由于我们通过 SSH-key 进行鉴权，所以 repo url 应该输入 ssh 形式的 url 而不是https形式的url（https需要每次输入账户密码）；对于branch，Pages 默认解析 username.github.io 下的 master 分支，那么要注意 branch 的选择，一般填 master， 而 hexo 对 github 默认值为 gh-pages

有时需要在 hexo deploy 前执行 hexo clean 清除缓存。

完成之后，在浏览器中输入 `username.github.io`应该就能看到和本地看到的效果一样的网页效果。

### 使用 Travis CI 自动部署

到这里为止 hexo 的基本配置与操作已经完成。对于我现在的协作使用体验来说，使用 `hexo d` 一键配置相比 Travis  其实已经足够方便，使用 Tarvis CI 进行部署仅仅只是因为我个人想要从中学习体验一些 CI 过程。

Travis CI 的部署过程 比起 `hexo d` ，相当于更进一步代替我们进行本地的 `hexo g` 的过程：我们这次将自己的 hexo 项目的**源代码**（不是静态页面）上传到 github 上，然后 Tarvis CI 会自动监测指定 github 仓库的变化，Tarvis CI 会为我们启动一个精简的云端Linux系统，根据部署配置文件（.travis.yml）和源代码，**然后 Tarvis CI 在云端的机器上进行 hexo 项目基本构建以及静态页面生成，然后帮我们再部署到 Pages 托管的仓库上。**

所以也可以看得出来，相比云端监听并启动服务代替我们生成静态页面再传回 github pages 的仓库，其实本地的渲染和 git push 要明显更快一些。当然，理解 Travis 这个运作过程可以帮助我们理解一些自动化测试与部署的思想

为了完成这个过程我们要进行这些步骤：

1. 注册 Travis CI 账号，和自己的 github 账号关联，并开放存放hexo博客的仓库的权限
2. 在自己的 hexo 项目下创建 _travis.yml 配置文件，并输入配置项
3. 将自己的 hexo 项目本体上传到 github 上，注意和 Pages 托管的【保存静态页面文件】的仓库区分开（一般可以选择在同一个仓库下创建两个分支，一个分支存放源代码，一个分支存放静态页面
4. 由于 Travis CI 运行结束后需要将静态页面 git push 到 Pages 托管的仓库，需要为 Travis CI 运行过程中提供 允许访问我们仓库的 token 

### 踩坑记录

#### kaze主题的使用

使用 kaze 这个主题时候踩了两次坑，~~基本都是因为其官方文档的“直接通过 npm 安装”的建议引起的~~

第一个坑是配置文件的坑（```_config.yml```）：如果直接用 npm 安装，它直接会将本体安装在本地的 ``` /node_modules``` 下而不是```/themes```文件夹下，导致一开始没找到它的默认配置文件（在它本体目录下：``` /hexo-theme-kaze/_config.yml ```），而我根据hexo文档直接在hexo根目录建立_config.[theme].yml 无法覆盖它的任何内容，导致一开始的布局无法更改。

> 根据官方文档，Hexo 配置文件中的 `theme_config` 的优先级最高，其次是 `_config.[theme].yml` 文件，最后是位于主题目录下的 `_config.yml` 文件。

之后我删掉了kaze下的```_config.yml```，仅保留了`_config.[theme].yml`和`_config.yml`。

第二个坑原因类似但是表现不一样：一次云端部署之后，我发现我在 kaze 主题源文件中修改的样式没有生效（~~我调大了原layout的头像大小~~），我很快意识到又和 ```/node_modules```有关：传上 github 的源代码不包括 node 依赖，这些依赖会在 travis CI 中通过 npm install 重新下载，这就包括了 kaze 本体，所以我对原layout的修改也被重置了。

之后我把 ``` /node_modules/hexo-theme-kaze```  这里的 kaze 本体直接移动到了 ```/themes``` 文件夹下，然后改名为 kaze ，之后又修改了 package.json 去掉了这项依赖（~~因为改完语法错了差点翻车~~），之后的部署就没有问题了（~~最后刷新了好几遍头像大小还是没变，刚刚更新了文章刷新之后又变了，怀疑是因为浏览器缓存~~）