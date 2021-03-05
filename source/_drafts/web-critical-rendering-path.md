---
title: 【转载】Web-关键渲染路径
date: 2021-10-27 21:52:54
tags:
- Web
---



> 原文连接：https://developers.google.com/web/fundamentals/performance/critical-rendering-path

# 定义

*优化关键渲染路径*是指优先显示与当前用户操作有关的内容。

要提供快速的网络体验，浏览器需要做许多工作。这类工作大多数是我们这些网络开发者看不到的：我们编写标记，屏幕上就会显示出漂亮的页面。

但浏览器到底是如何使用我们的 HTML、CSS 和 JavaScript 在屏幕上渲染像素的呢？

从收到 HTML、CSS 和 JavaScript 字节到对其进行必需的处理，从而将它们转变成渲染的像素这一过程中有一些中间步骤，优化性能其实就是了解这些步骤中发生了什么 - 即**关键渲染路径（Cirtical Rendering Path）**。

![image.png](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/images/progressive-rendering.png)

# 构建对象模型

## 要点

- 字节 → 字符 → 令牌 → 节点 → 对象模型。
- HTML 标记转换成文档对象模型 (**DOM**)；CSS 标记转换成 CSS 对象模型 (**CSSOM**)。
- DOM 和 CSSOM 是独立的数据结构。
- Chrome DevTools Timeline 让我们可以捕获和检查 DOM 和 CSSOM 的构建和处理开销。

# 渲染树构建、布局及绘制

为了计算每个可见元素的布局，并输出给绘制流程，将像素渲染到屏幕上。需要将 CSSOM 树和 DOM 树合并成渲染树。

## 要点

- DOM 树与 CSSOM 树合并后形成渲染树。
- 渲染树只包含**渲染网页所需的节点。**
- **布局**计算每个对象的精确位置和大小。
- 最后一步是**绘制**，使用最终渲染树将像素渲染到屏幕上。

## 细节

![image.png](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/images/full-process.png)

为了构建渲染树，浏览器大体上完成了下列工作：

1. 从 DOM 树的根节点开始遍历每个可见节点。

- - 某些节点**不可见**（例如脚本标记、元标记等），因为它们不会体现在渲染输出中，所以会被忽略。
  - 某些节点**通过 CSS 隐藏**，因此在渲染树中也会被忽略，例如，上例中的 span 节点---不会出现在渲染树中，---因为有一个显式规则在该节点上设置了“display: none”属性。

1. 对于每个可见节点，为其找到适配的 CSSOM 规则并应用它们。
2. 发射可见节点，连同其内容和计算的样式。

Note：简单提一句，请注意 `visibility: hidden` 与 `display: none` 是不一样的。前者隐藏元素，但元素仍占据着布局空间（即将其渲染成一个空框），而后者 (`display: none`) 将元素从渲染树中完全移除，元素既不可见，也不是布局的组成部分。

最终输出的渲染同时包含了屏幕上的所有可见内容及其样式信息。**有了渲染树，我们就可以进入“布局”阶段。**

为弄清每个对象在网页上的确切大小和位置，浏览器从渲染树的根节点开始进行遍历。

布局流程的输出是一个“盒模型”，它会精确地捕获每个元素在视口内的确切位置和尺寸：所有相对测量值都转换为屏幕上的绝对像素。

最后，既然我们知道了哪些节点可见、它们的计算样式以及几何信息，我们终于可以将这些信息传递给最后一个阶段：将渲染树中的每个节点转换成屏幕上的实际像素。这一步通常称为“**绘制**”或“**栅格化**”。

上述步骤都需要浏览器完成大量工作，所以相当耗时。不过，Chrome DevTools 可以帮助我们对上述所有三个阶段进行深入的了解。让我们看一下最初“hello world”示例的布局阶段：

![image.png](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/images/cssom-timeline.png)

- “**Layout**”事件在时间线中捕获渲染树构建以及位置和尺寸计算。
- 布局完成后，浏览器会立即发出“Paint Setup”和“**Paint**”事件，将渲染树转换成屏幕上的像素。

执行渲染树构建、布局和绘制所需的时间将取决于文档大小、应用的样式，以及运行文档的设备：文档越大，浏览器需要完成的工作就越多；样式越复杂，绘制需要的时间就越长（例如，单色的绘制开销“较小”，而阴影的计算和渲染开销则要“大得多”）。

下面简要概述了浏览器完成的步骤：

1. 处理 HTML 标记并构建 DOM 树。
2. 处理 CSS 标记并构建 CSSOM 树。
3. 将 DOM 与 CSSOM 合并成一个渲染树。
4. 根据渲染树来布局，以计算每个节点的几何信息。
5. 将各个节点绘制到屏幕上。

我们的演示网页看起来可能很简单，实际上却需要完成相当多的工作。如果 DOM 或 CSSOM 被修改，您只能再执行一遍以上所有步骤，以确定哪些像素需要在屏幕上进行重新渲染。

***优化关键渲染路径\*就是指最大限度缩短执行上述第 1 步至第 5 步耗费的总时间。** 这样一来，就能尽快将内容渲染到屏幕上，此外还能缩短首次渲染后屏幕刷新的时间，即为交互式内容实现更高的刷新率。

# 阻塞渲染的CSS

默认情况下，CSS 被视为阻塞渲染的资源，这意味着：**浏览器将不会渲染任何已处理的内容，直至 CSSOM 构建完毕。**

请务必精简您的 CSS，尽快提供它，并利用**媒体类型**和**查询**来解除对渲染的阻塞。

在[渲染树构建](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/render-tree-construction)中，我们看到关键渲染路径要求我们**同时具有 DOM 和 CSSOM 才能构建渲染树**。这会给性能造成严重影响：**HTML 和 CSS 都是阻塞渲染的资源。** HTML 显然是必需的，因为如果没有 DOM，我们就没有可渲染的内容，但 CSS 的必要性可能就不太明显。如果我们在 CSS 不阻塞渲染的情况下尝试渲染一个普通网页会怎样？

## 要点

- 默认情况下，CSS 被视为阻塞渲染的资源。
- 我们可以通过媒体类型和媒体查询将一些 CSS 资源标记为不阻塞渲染。
- 浏览器会下载所有 CSS 资源，无论阻塞还是不阻塞。

## 细节

上例展示了纽约时报网站使用和不使用 CSS 的显示效果，它证明了为何要在 CSS 准备就绪之前阻塞渲染，---没有 CSS 的网页实际上无法使用。右侧的情况通常称为“内容样式短暂失效”(FOUC)。浏览器将阻塞渲染，直至 DOM 和 CSSOM 全都准备就绪。

***CSS 是阻塞渲染的资源。需要将它尽早、尽快地下载到客户端，以便缩短首次渲染的时间。\***

不过，如果我们有一些 CSS 样式只在特定条件下（例如显示网页或将网页投影到大型显示器上时）使用，又该如何？如果这些资源不阻塞渲染，该有多好。

我们可以通过 CSS“媒体类型”和“媒体查询”来解决这类用例：

```
<link href="style.css" rel="stylesheet">
<link href="print.css" rel="stylesheet" media="print">
<link href="other.css" rel="stylesheet" media="(min-width: 40em)">
```

[**媒体查询**](https://developers.google.com/web/fundamentals/design-and-ux/responsive/#use-css-media-queries-for-responsiveness)由媒体类型以及零个或多个检查特定媒体特征状况的表达式组成。

例如，上面的第一个样式表声明未提供任何媒体类型或查询，因此它适用于**所有情况**，也就是说，它始终会阻塞渲染。第二个样式表则不然，它只在**打印内容时适用**---或许您想重新安排布局、更改字体等等，因此在网页首次加载时，该样式表不需要阻塞渲染。最后，最后一个样式表声明提供由浏览器执行的“媒体查询”：**符合条件时，浏览器将阻塞渲染**，直至样式表下载并处理完毕。

让我们考虑下面这些实例：

```
<link href="style.css"    rel="stylesheet">
<link href="style.css"    rel="stylesheet" media="all">
<link href="portrait.css" rel="stylesheet" media="orientation:portrait">
<link href="print.css"    rel="stylesheet" media="print">
```

- 第一个声明阻塞渲染，适用于所有情况。
- 第二个声明同样阻塞渲染：“all”是默认类型，如果您不指定任何类型，则隐式设置为“all”。因此，第一个声明和第二个声明实际上是等效的。
- 第三个声明具有动态媒体查询，将在网页加载时计算。根据网页加载时设备的方向，portrait.css 可能阻塞渲染，也可能不阻塞渲染。
- 最后一个声明只在打印网页时应用，因此网页首次在浏览器中加载时，它不会阻塞渲染。

最后，请注意“阻塞渲染”仅是指浏览器是否需要暂停网页的首次渲染，直至该资源准备就绪。无论哪一种情况，浏览器仍会下载 CSS 资产，只不过不阻塞渲染的资源优先级较低罢了

# 使用 JavaScript 添加交互

JavaScript 允许我们修改网页的方方面面：内容、样式以及它如何响应用户交互。 不过，JavaScript 也会阻止 DOM 构建和延缓网页渲染。 为了实现最佳性能，可以让您的 JavaScript **异步执行**，并**去除**关键渲染路径中任何不必要的 JavaScript。

## 要点

- JavaScript 可以查询和修改 DOM 与 CSSOM。
- JavaScript 执行会阻止 CSSOM。
- 除非将 JavaScript 显式声明为异步，否则它会阻止构建 DOM。

## 细节

我们通过以上示例修改了现有 DOM 节点的内容和 CSS 样式，并为文档添加了一个全新的节点。

上例中的内联脚本靠近网页底部。如果我们将脚本移至 *span* 元素之上，您就会注意到脚本运行失败，这透露出一个重要事实：我们的脚本在文档的何处插入，就在何处执行。**当 HTML 解析器遇到一个 script 标记时，它会暂停构建 DOM，将控制权移交给 JavaScript 引擎；等 JavaScript 引擎运行完毕，浏览器会从中断的地方恢复 DOM 构建。**

换言之，我们的脚本块找不到网页中任何靠后的元素，因为它们尚未接受处理！或者，稍微换个说法：**执行我们的内联脚本会阻止 DOM 构建，也就延缓了首次渲染。**

在网页中引入脚本的另一个微妙事实是，它们不仅可以读取和修改 DOM 属性，还可以读取和修改 CSSOM 属性。实际上，我们在示例中就是这么做的：将 span 元素的 display 属性从 none 更改为 inline。最终结果如何？我们现在遇到了竞态问题。

如果浏览器尚未完成 CSSOM 的下载和构建，而我们却想在此时运行脚本，会怎样？答案很简单，对性能不利：**浏览器将延迟脚本执行和 DOM 构建，直至其完成 CSSOM 的下载和构建。**

简言之，JavaScript 在 DOM、CSSOM 和 JavaScript 执行之间引入了大量新的依赖关系，从而可能导致浏览器在处理以及在屏幕上渲染网页时出现大幅延迟：

- 脚本在文档中的位置很重要。
- 当浏览器遇到一个 script 标记时，DOM 构建将暂停，直至脚本完成执行。
- JavaScript 可以查询和修改 DOM 与 CSSOM。
- JavaScript 执行将暂停，直至 CSSOM 就绪。

“优化关键渲染路径”在很大程度上是指了解和优化 HTML、CSS 和 JavaScript 之间的依赖关系谱。

### 解析器阻止与异步 JavaScript

默认情况下，JavaScript 执行会“阻止解析器”：当浏览器遇到文档中的脚本时，它必须**暂停 DOM 构建，将控制权移交给 JavaScript 运行时，让脚本执行完毕，然后再继续构建 DOM**。我们在前面的示例中已经见过内联脚本的实用情况。实际上，内联脚本始终会阻止解析器，除非您编写额外代码来推迟它们的执行。

无论我们使用 <script> 标记还是内联 JavaScript 代码段，您都可以期待两者能够以相同方式工作。 在两种情况下，浏览器都会先暂停并执行脚本，然后才会处理剩余文档。不过，**如果是外部 JavaScript 文件，浏览器必须停下来，等待从磁盘、缓存或远程服务器获取脚本，这就可能给关键渲染路径增加数十至数千毫秒的延迟。**

向 script 标记添加异步（async）关键字可以指示浏览器在等待脚本可用期间不阻止 DOM 构建，这样可以显著提升性能。

# 评估关键渲染路径

作为每个可靠性能策略的基础，准确的评估和检测必不可少。 无法评估就谈不上优化。本文说明了评估 CRP 性能的不同方法。

- Lighthouse 方法会对页面运行一系列自动化测试，然后生成关于页面的 CRP 性能的报告。 这一方法对您的浏览器中加载的特定页面的 CRP 性能提供了快速且简单的高级概览，让您可以快速地测试、循环访问和提高其性能。
- Navigation Timing API 方法会捕获[真实用户监控 (RUM)](https://en.wikipedia.org/wiki/Real_user_monitoring) 指标。如名称所示，这些指标捕获自真实用户与网站的互动，并为真实的 CRP 性能（您的用户在各种设备和网络状况下的体验）提供了准确的信息。

通常情况下，最好利用 **Lighthouse 发现明显的 CRP 优化机会**，然后使用 **Navigation Timing API 设置您的代码**，以便监控应用在实际使用过程中的性能。

### 使用 Lighthouse 审核页面

Lighthouse 是一个网络应用审核工具，可以对特定页面运行一系列测试，然后在汇总报告中显示页面的结果。 您可以将 Lighthouse 作为 Chrome 扩展程序或 NPM 模块运行，这对将 Lighthouse 与持续集成系统集成非常有用。

请参阅[使用 Lighthouse 审核网络应用](https://developers.google.com/web/tools/lighthouse)，开始使用 Lighthouse。

您将 Lighthouse 作为 Chrome 扩展程序运行时，页面的 CRP 结果将如以下屏幕截图所示。

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603701565127-ecf2c6bf-cf72-430f-9628-92e7f3012640.png)

### 使用 Navigation Timing API 设置您的代码

结合使用 Navigation Timing API 和页面加载时发出的其他浏览器事件，您可以捕获并记录任何页面的真实 CRP 性能。

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603701613512-3791156e-e61e-4aa1-a352-129788397298.png)

上图中的每一个标签都对应着浏览器为其加载的每个网页追踪的细粒度时间戳。实际上，在这个具体例子中，我们展示的只是各种不同时间戳的一部分。我们暂且跳过所有**与网络有关的时间戳**，但在后面的课程中还会做详细介绍。

那么，这些时间戳有什么含义呢？

- `domLoading`：这是整个过程的起始时间戳，浏览器即将**开始解析**第一批收到的 HTML 文档字节。
- `domInteractive`：表示浏览器完成对所有 HTML 的解析并且 **DOM 构建完成**的时间点。
- `domContentLoaded`：表示 **DOM 准备就绪并且没有样式表阻止 JavaScript 执行**的时间点，这意味着现在我们可以**构建渲染树**了。

- - **许多 JavaScript 框架都会等待此事件发生后，才开始执行它们自己的逻辑。**因此，浏览器会捕获 `EventStart` 和 `EventEnd` 时间戳，让我们能够追踪执行所花费的时间。

- `domComplete`：顾名思义，所有处理完成，并且网页上的所有资源（图像等）都已下载完毕，也就是说，加载转环已停止旋转。
- `loadEvent`：作为每个网页加载的最后一步，浏览器会触发 `onload` 事件，以便触发额外的应用逻辑。
- HTML 规范中规定了每个事件的具体条件：应在何时触发、应满足什么条件等等。对我们而言，我们将重点放在与关键渲染路径有关的几个关键里程碑上：

- **`domInteractive`** 表示 DOM 准备就绪的时间点。
- **`domContentLoaded`**一般表示[DOM 和 CSSOM 均准备就绪](http://calendar.perfplanet.com/2012/deciphering-the-critical-rendering-path/)的时间点。

- - 如果没有阻塞解析器的 JavaScript，则 `DOMContentLoaded` 将在 `domInteractive` 后立即触发。

- **`domComplete`** 表示网页及其所有子资源都准备就绪的时间点。

完成了所有该做的工作，我们现在知道了需要追踪哪些具体的里程碑，以及用于输出这些评估的简单功能。请注意，除了将这些评估结果显示在网页上，您还可以修改代码，将这些评估结果发送到分析服务器上（[Google Analytics（分析）会自动完成这项工作](https://support.google.com/analytics/answer/1205784)），这是一种监控网页性能的好方法，可以借此找出哪些网页还需要作出进一步优化。

## DevTools ？

尽管本文档使用 Chrome DevTools 的 Network 面板说明 CRP 概念，DevTools 当前并不非常适合 CRP 评估，因为它没有隔离关键资源的内置机制。运行 [Lighthouse](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/measure-crp#lighthouse) 审核来帮助识别此类资源。

# 分析关键渲染路径性能

发现和解决关键渲染路径性能瓶颈需要充分了解常见的陷阱。 让我们踏上实践之旅，找出常见的性能模式，从而帮助您优化网页。

优化关键渲染路径能够让浏览器尽可能快地绘制网页：更快的网页渲染速度可以提高吸引力、增加网页浏览量以及[提高转化率](https://www.google.com/think/multiscreen/success.html)。为了最大程度减少访客看到空白屏幕的时间，我们需要优化加载的资源及其加载顺序。

为帮助说明这一流程，让我们先从可能的最简单情况入手，逐步构建我们的网页，使其包含更多资源、样式和应用逻辑。在此过程中，我们还会对每一种情况进行优化，以及了解可能出错的环节。

到目前为止，我们只关注了资源（CSS、JS 或 HTML 文件）可供处理后浏览器中会发生的情况，而忽略了从缓存或从网络获取资源所需的时间。我们作以下假设：

- 到服务器的网络往返（传播延迟时间）需要 100 毫秒。
- HTML 文档的服务器响应时间为 100 毫秒，所有其他文件的服务器响应时间均为 10 毫秒。

### 纯 HTML 的 CRP 体验分析

```
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Critical Path: No Style</title>
  </head>
  <body>
    <p>Hello <span>web performance</span> students!</p>
    <div><img src="awesome-photo.jpg"></div>
  </body>
</html>
```

我们将从基本 HTML 标记和单个图像（无 CSS 或 JavaScript）开始。让我们在 Chrome DevTools 中打开 Network 时间线并检查生成的资源瀑布：

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603702522370-d69d4200-6b6e-4f6c-ad15-6268d4e1e055.png)

正如预期的一样，HTML 文件下载花费了大约 200 毫秒。请注意，蓝线的透明部分表示浏览器在网络上等待（即尚未收到任何响应字节）的时间，而不透明部分表示的是收到第一批响应字节后完成下载的时间。HTML 下载量很小 (<4K)，我们只需单次往返便可获取整个文件。因此，获取 HTML 文档大约需要 200 毫秒，其中一半的时间花费在网络等待上，另一半花费在等待服务器响应上。

当 HTML 内容可用后，浏览器会解析字节，将它们转换成令牌，然后构建 DOM 树。请注意，为方便起见，DevTools 会在底部报告 DOMContentLoaded 事件的时间（216 毫秒），该时间同样与蓝色垂直线相符。HTML 下载结束与蓝色垂直线 (`DOMContentLoaded`) 之间的间隔是浏览器构建 DOM 树所花费的时间 — 在本例中仅为几毫秒。

请注意，我们的图片并未阻止 `domContentLoaded` 事件。这证明，我们构建渲染树甚至绘制网页时无需等待页面上的每个资产：**并非所有资源都对快速提供首次绘制具有关键作用**。事实上，当我们谈论关键渲染路径时，通常谈论的是 HTML 标记、CSS 和 JavaScript。**图像不会阻止页面的首次渲染**，不过，我们当然也应该尽力确保系统尽快绘制图像！

即便如此，系统还是会阻止图像上的 `load` 事件（也称为 `onload`）：DevTools 会在 335 毫秒时报告 `onload` 事件。回想一下，`onload` 事件标记的点是网页所需的**所有资源**均已下载并经过处理的点，这是加载微调框可以在浏览器中停止微调的点（由瀑布中的红色垂直线标记）。

### 结合使用 JavaScript 和 CSS 的 CRP 体验分析

```
<!DOCTYPE html>
<html>
  <head>
    <title>Critical Path: Measure Script</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <link href="style.css" rel="stylesheet">
  </head>
  <body onload="measureCRP()">
    <p>Hello <span>web performance</span> students!</p>
    <div><img src="awesome-photo.jpg"></div>
    <script src="timing.js"></script>
  </body>
</html>
```

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603702934853-bba53fde-f65b-4ddb-82c1-9cf22b210e51.png)

添加外部 CSS 和 JavaScript 文件将额外增加两个瀑布请求，浏览器差不多会同时发出这两个请求。不过，**请注意，现在 `domContentLoaded` 事件与 `onload` 事件之间的时间差小多了。**

原因？

- 与纯 HTML 示例不同，我们还需要获取并**解析 CSS 文件**才能构建 CSSOM，要想构建渲染树，DOM 和 CSSOM 缺一不可。
- 由于网页上还有一个阻止解析器的 JavaScript 文件，系统会在下载并解析 CSS 文件之前阻止 `domContentLoaded` 事件：因为 JavaScript 可能会查询 CSSOM，我们必须在阻塞 CSS 文件直到其下载完成，然后才能执行 JavaScript。

**如果我们用内联脚本替换外部脚本会怎样？**即使直接将脚本内联到网页中，浏览器仍然无法在构建 CSSOM 之前执行脚本。简言之，内联 JavaScript 也会阻止解析器。

不过，尽管内联脚本会阻止 CSS，但这样做是否能加快页面渲染速度呢？

让我们尝试一下，看看会发生什么。

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603703491288-2b491df8-1901-439d-86a4-b27071fbb4e5.png)

我们减少了一个请求，但 `onload` 和 `domContentLoaded` 时间实际上没有变化。为什么呢？怎么说呢，我们知道，这与 JavaScript 是内联的还是外部的并无关系，因为只要浏览器遇到 script 标记，就会进行阻止，并等到 CSSOM 构建完毕。此外，在我们的第一个示例中，浏览器是并行下载 CSS 和 JavaScript，并且差不多是同时完成。在此实例中，**内联 JavaScript 代码并无多大意义**。但是，我们可以通过多种策略加快网页的渲染速度。

- **为JavaScript添加async**

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603703751551-8e8e9bf9-7d85-4ea4-8f59-e85ec5117005.png)

解析 HTML 之后不久即会触发 `domContentLoaded` 事件；浏览器已得知不要阻止 JavaScript，并且由于没有其他阻止解析器的脚本，CSSOM 构建也可同步进行了。

- **同时内联 CSS 和 JavaScript**

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603703831374-c78b83d1-513b-408f-9b21-084d3e163756.png)

`domContentLoaded` 时间与前一示例中的时间实际上相同；只不过没有将 JavaScript 标记为异步，而是同时将 CSS 和 JS 内联到网页本身。这会使 HTML 页面显著增大，但好处是浏览器无需等待获取任何外部资源，网页已经内置了所有资源。

如您所见，即便是非常简单的网页，优化关键渲染路径也并非轻而易举：我们需要了解不同资源之间的依赖关系图，我们需要确定哪些资源是“关键资源”，我们还必须在不同策略中做出选择，找到在网页上加入这些资源的恰当方式。

### 性能模式

#### 纯HTML的关键路径

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603789071975-b25291cf-6f26-452c-a59b-a13a4dff3d1a.png)

#### HTML+CSS的关键路径

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603789102561-28853b97-6ac1-4c48-b475-d189b733ecbb.png)

#### HTML+CSS+JS的关键路径

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603789132429-7c9b929f-db07-4d85-8e13-c809faf22f1f.png)

- JavaScript既属于外部资源（需要带宽下载），又是一种解释器阻塞资源（阻塞DOM构建）
- 为了执行 JavaScript 文件，我们还需要阻塞，等待CSSOM下载与构建完成
- 所以上述过程的顺序为： `Build DOM` `Build CSSOM` `Run JS` `Build DOM` `Render page`

#### HTML+CSS+JS async的关键路径

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603790372801-f431f799-e90a-4c07-8d0f-2f0a7c6b3355.png)

- 脚本不再阻止解析器，也不再是关键渲染路径的组成部分。
- 由于没有其他关键脚本，CSS 也不需要阻止 `domContentLoaded` 事件。
- `domContentLoaded` 事件触发得越早，其他应用逻辑开始执行的时间就越早。

#### HTML+CSS仅用于打印+JS async的关键路径

![image.png](https://cdn.nlark.com/yuque/0/2020/png/2481276/1603790477740-b0a7bbc0-8582-4ada-a0e9-c161cbceba1a.png)

因为 style.css 资源只用于打印，浏览器不必阻止它便可渲染网页。所以，只要 DOM 构建完毕，浏览器便具有了渲染网页所需的足够信息。因此，该网页只有一项关键资源（HTML 文档），并且最短关键渲染路径长度为一次往返。

# 优化关键渲染路径

为尽快完成首次渲染，我们需要最大限度减小以下三种可变因素：

- 关键资源的数量。
- 关键路径长度。
- 关键字节的数量。

关键资源是可能阻止网页首次渲染的资源。这些资源越少，浏览器的工作量就越小，对 CPU 以及其他资源的占用也就越少。

同样，关键路径长度受所有关键资源与其字节大小之间依赖关系图的影响：某些资源只能在上一资源处理完毕之后才能开始下载，并且资源越大，下载所需的往返次数就越多。

最后，浏览器需要下载的**关键字节越少**，处理内容并让其出现在屏幕上的速度就越快。要减少字节数，我们可以**减少资源数（将它们删除或设为非关键资源）**，此外还要**压缩和优化各项资源**，确保最大限度减小传送大小。

# PageSpeed 规则和建议

本指南审视 PageSpeed Insights 规则背景：优化关键渲染路径时的注意事项以及原因。

## 消除阻塞渲染的 JavaScript 和 CSS

要以最快速度完成首次渲染，需要最大限度减少网页上关键资源的数量并（尽可能）消除这些资源，最大限度减少下载的关键字节数，以及优化关键路径长度。

## 优化 JavaScript 的使用

默认情况下，JavaScript 资源会阻塞解析器，除非将其标记为 `async` 或通过专门的 JavaScript 代码段进行添加。阻塞解析器的 JavaScript 会强制浏览器等待 CSSOM 并暂停 DOM 的构建，继而大大延迟首次渲染的时间。

### 首选使用异步 JavaScript 资源

异步资源不会阻塞文档解析器，让浏览器能够避免在执行脚本之前受阻于 CSSOM。通常，如果脚本可以使用 `async` 属性，也就意味着它并非首次渲染所必需。可以考虑在首次渲染后异步加载脚本。

### 避免同步服务器调用

使用 `navigator.sendBeacon()` 方法来限制 XMLHttpRequests 在 `unload` 处理程序中发送的数据。 因为许多浏览器都对此类请求有同步要求，所以可能减慢网页转换速度，有时还很明显。 以下代码展示了如何利用 `navigator.sendBeacon()` 向 `pagehide` 处理程序而不是 `unload` 处理程序中的服务器发送数据。

```
<script>
  function() {    window.addEventListener('pagehide', logData, false);
    function logData() {      navigator.sendBeacon(
        'https://putsreq.herokuapp.com/Dt7t2QzUkG18aDTMMcop',
        'Sent by a beacon!');
    }
  }();
</script>
```

新增的 `fetch()` 方法提供了一种方便的数据异步请求方式。由于它尚未做到随处可用，因此您应该利用功能检测来测试其是否存在，然后再使用。该方法通过 Promise 而非多个事件处理程序来处理响应。不同于对 XMLHttpRequest 的响应，从 Chrome 43 开始，fetch 响应将是 stream 对象。这意味着调用 `json()` 也会返回 Promise。

```
<script>fetch('./api/some.json')  
  .then(  
    function(response) {  
      if (response.status !== 200) {  
        console.log('Looks like there was a problem. Status Code: ' +  response.status);  
        return;  
      }
      // Examine the text in the response        response.json().then(function(data) {  
        console.log(data);  
      });  
    }  
  )  
  .catch(function(err) {  
    console.log('Fetch Error :-S', err);  
  });
</script>
```

`fetch()` 方法也可处理 POST 请求。

```
<script>fetch(url, {  method: 'post',  headers: {  
    "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"  
  },  
  body: 'foo=bar&lorem=ipsum'  
}).then(function() { // Aditional code });
</script>
```

### 延迟解析 JavaScript

为了最大限度减少浏览器渲染网页的工作量，应延迟任何非必需的脚本（即对构建首次渲染的可见内容无关紧要的脚本）。

### 避免运行时间长的 JavaScript

运行时间长的 JavaScript 会阻止浏览器构建 DOM、CSSOM 以及渲染网页，所以任何对首次渲染无关紧要的初始化逻辑和功能都应延后执行。如果需要运行较长的初始化序列，请考虑将其拆分为若干阶段，以便浏览器可以间隔处理其他事件。

## 优化 CSS 的使用

CSS 是构建渲染树的必备元素，首次构建网页时，JavaScript 常常受阻于 CSS。确保将任何非必需的 CSS 都标记为非关键资源（例如打印和其他媒体查询），并应确保尽可能减少关键 CSS 的数量，以及尽可能缩短传送时间。

### 将 CSS 置于文档 head 标签内

尽早在 HTML 文档内指定所有 CSS 资源，以便浏览器尽早发现 `<link>` 标记并尽早发出 CSS 请求。

### 避免使用 CSS import

一个样式表可以使用 CSS import (`@import`) 指令从另一样式表文件导入规则。不过，应避免使用这些指令，因为它们会在关键路径中增加往返次数：只有在收到并解析完带有 `@import` 规则的 CSS 样式表之后，才会发现导入的 CSS 资源。

### 内联阻塞渲染的 CSS

为获得最佳性能，您可能会考虑将关键 CSS 直接内联到 HTML 文档内。这样做不会增加关键路径中的往返次数，并且如果实现得当，在只有 HTML 是阻塞渲染的资源时，可实现“一次往返”关键路径长度。