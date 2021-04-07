# ZooKeeper 和 Eureka 的比较

### CAP偏重

Zookeeper -> **CP**

Zookeeper 在获取服务列表时因为 Leader 宕机而进行的 Leader 选举期间（30~120s），或者集群中半数以上服务器节点不可用时，Zookeeper将暂时无法处理这个请求，所以无法保证 A 服务可用性

Eureka -> **AP**

Eureka 集群通过 P2P 对等结构，不同于 zookeeper 的选举过程，当一台 Eureka Server 宕机之后，请求会被自动切换到新的 Eureka Server 上，保证了 A 可用性

# SpringCloud

## Swagger

### 基本

作用是在 SpringCould 项目下生成**运行时可访问的REST接口动态文档**，并且还可以以类似 postman 的方式进行即时的调用测试

可以通过在 Api 方法上插入注解的方式生成对应 Api ，也可以通过定义一个 SwaggerConfig 类，在类的方法中定义 api 扫描范围进行生成（AOP）

常用方式：

```java
@ApiOperation(value = "新增用户")	// 定义api名称
@ApiResponses({ @ApiResponse(code = 200, message = "OK", response = UserDto.class) })	// 定义返回REST返回格式
public UserDto addUser(@RequestBody AddUserParam param) {
    System.err.println(param.getName());
    return new UserDto();
}

// 参数类的定义
@Data
@ApiModel(value = "com.demo.param.AddUserParam", description = "新增用户参数")
public class AddUserParam {
    @ApiModelProperty(value = "ID")
    private String id;
    @ApiModelProperty(value = "名称")
    private String name;
    @ApiModelProperty(value = "年龄")
    private int age;
}
```

## Eureka

### 基本

作用是作为服务器注册中心（建立在HTTP层上），一般通过集群构建

### 使用

**注册中心侧：**

通过对入口类添加 `@EnableEurekaServer` 注解建立一个Eureka服务

对于集群，搭建方式简单通过两个 Eureka 互相注册

在同一个 Eureka 代码下建立两个配置文件（互相之间只有端口和名称不同），然后互相作为服务注册到对方的注册中心：

```yaml
## application-node1.properties:
eureka.client.serviceUrl.defaultZone=http://node2:9999/eureka/
## application-node2.properties:
eureka.client.serviceUrl.defaultZone=http://node1:8888/eureka/
```

启动时根据传入的内容不同读取不同的配置文件，从而启动不同url的Eureka注册中心

**服务侧：**

在 `application.properties` 配置中上同时加上两个注册中心的url即可：`eureka.client.serviceUrl.defaultZone=http://localhost:8888/eureka/,http://localhost:9999/eureka/`

然后，在对应服务的入口主类中加入 `@EnableDiscoveryClient`，服务器就注册了上去



尝试关闭其中一个，可以发现依然可以正常调用到服务

## Ribbon

### 基本

Ribbon 通过客户端负载均衡的方式进行负载，根据向注册中心查询可用实例列表和本地的负载均衡策略直接选择向具体哪个实例发起请求

### 使用

OpenFeign 包集成了 Ribbon，如果使用 Feign 做为服务调用方式，直接在对应 service 类上添加 `@RibbonClient` 注解即可

## OpenFeign

### 基本

一个轻量级http请求调用框架，可以表现为通过**接口+注解**的方式调用http请求

可以将原本的显式Http方法请求变为对一个 Autowired 注入的服务对象的普通方法调用

### 使用

**服务提供方：**

对于需要调用服务的**入口类**直接添加 `@EnableFeignClients` 启用OpenFeign

正常注册到服务中心后，创建一个 **服务类的接口** 作为 FeignClient，比如：

```java
// 名称需要和在服务中心注册的服务一致
@FeignClient("warehouse-service")
public interface WarehouseServiceFeignClient {
    @GetMapping("/stock")
    public Stock getStock(@RequestParam("skuId") Long skuId);
}
```

（消费方）在使用 Feign 发送请求前会先向服务中心查询该服务名称对应的所有实例信息，同时还会根据内置的 **Ribbon 负载均衡**选择一个实例发起 RESTful 请求，保证通信高可用

接受方的对象不强制要求和提供端 JSON 属性保持一致

**服务消费方：**

```java
@Resource // 或@Autowired
private WarehouseServiceFeignClient warehouseServiceFeignClient;

public void foo() {
    //像调用本地方法一样调用方法
    Stock stock = warehouseServiceFeignClient.getStock(skuId); 
    System.out.println(stock);
    // ..
}
```

