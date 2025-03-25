# statistics-x

---
#### 专门为OpenHarmony开发的埋点库，支持非侵入式自动埋点和手动埋点，更加轻便和简单。

## 简介

---
#### 本库支持*router*和*navigation*混合路由的页面展示隐藏监听，同时也支持UI组件上的自定义属性的点击监听。
 
- 支持自动埋点事件 应用启动(APP_START)
- 支持自动埋点事件 应用被动启动(APP_START_PASSIVELY)
- 支持自动埋点事件 应用退出(APP_END)
- 支持自动埋点事件 应用进入后台(APP_BACKGROUND)
- 支持自动埋点事件 应用进入前台(APP_FOREGROUND)
- 支持自动埋点事件 组件点击(APP_CLICK)
- 支持自动埋点事件 页面展示(APP_VIEW_SCREEN)
- 支持自动埋点事件 页面隐藏(APP_PAGE_LEAVE)
- 支持自动埋点事件 应用崩溃(APP_CRASH)
- 支持自动埋点事件 应用首次安装(APP_INSTALL)
- 支持手动埋点事件 手动发送(NO_AUTO)  
<br>


#### 事件属性说明

|      属性名      |  属性描述   |                            事件                            |
|:-------------:|:-------:|:--------------------------------------------------------:|
|  referer_url  | 上一个页面地址 |      应用被动启动、应用退出、应用进入后台、应用进入前台、组件点击、页面展示、页面隐藏、手动发送       |
|  current_url  | 当前页面地址  |      应用被动启动、应用退出、应用进入后台、应用进入前台、组件点击、页面展示、页面隐藏、手动发送       |
| is_first_day  |  首日打开   | 应用启动、 应用被动启动、应用退出、应用崩溃、应用进入后台、应用进入前台、组件点击、页面展示、页面隐藏、手动发送 |
| is_first_time |  首次打开   |   应用启动、 应用被动启动、应用退出、应用崩溃、应用进入后台、应用进入前台、组件点击、页面展示、页面隐藏、手动发送   |
|  crash_trace  |  异常信息   |                           应用崩溃                           |
|  crash_type   |  崩溃类型   |                           应用崩溃                           |
|  element_type   |  组件类型   |                           应用点击                           |
|  element_content   | 组件文本内容  |                           应用点击                           |
|  event_duration   |  停留时间   |                           页面展示                           |

<br>

## 下载安装

---

ohpm install @shhzcj/statistics-x

<br>


## 类说明

----
##### 配置类:StatisticsConfig

| 属性名称          | 属性类型               | 属性描述    |
|----------------|--------------------|---------|
| enableLog      | boolean            | 是否开启日志  
| autoTrackTypes | Set                | 跟踪埋点类型  
| autoTrackIgnorePage | Set                | 忽略的页面路径(后期版本)
| persistentProperty | object             | 全局静态属性  |
| dynamicProperty | fuction:()=>object | 全局动态属性  |
| statisticsGetCallback | fuction:()=>void   | 埋点回调函数  |

<br>

##### 埋点回调函数fuction:()=>void
| 参数名称                  | 参数类型               | 参数描述   |
|-----------------------|--------------------|--------|
| statisticsType             | StatisticsType     | 跟踪埋点类型 
| statisticsProperty        | object             | 埋点数据   
| customComponentProperty   | object \|undefined | UI组件自定义属性 
| persistentProperty    | object \|null      | 全局静态属性 |
| dynamicProperty       | object \|undefined | 全局动态属性 |


<br>

##### 埋点类:StatisticsManager

| 方法名称  | 方法描述    |
|-----------------------|---------|
| register              | 埋点注册  
| sendNoAutoStatistics        | 发送手动埋点


<br>


## 使用案例

---

##### EntryAbility
```typescript 

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);


  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {

  }

  onDestroy(): void {

  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability


    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {

        return;
      }

      windowStage.getMainWindow().then((value) => {
        //初始化埋点
        let uiContext = value.getUIContext()
        this.initStatistics(uiContext)
      }).catch((error: object) => {
      })
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources

  }

  onForeground(): void {
    // Ability has brought to foreground

  }

  onBackground(): void {
    // Ability has back to background

  }



}


```

##### initStatistics

```typescript
  initStatistics(uiContext: UIContext) {

    let config = new StatisticsConfig()
    config.enableLog = true
    config.autoTrackTypes =
      new Set([StatisticsType.APP_CLICK,
        StatisticsType.APP_VIEW_SCREEN,
        StatisticsType.APP_PAGE_LEAVE,
        StatisticsType.APP_START,
        StatisticsType.APP_START_PASSIVELY,
        StatisticsType.APP_END,
        StatisticsType.APP_CRASH,
        StatisticsType.APP_INSTALL,])

    let persistentProperty: object = new Object()
    persistentProperty["a"] = 1
    persistentProperty["b"] = 2

    config.persistentProperty = persistentProperty

    config.dynamicProperty = () => {
      let dynamicProperty: object = new Object()
      dynamicProperty["time"] = new Date().getTime()
      dynamicProperty["login_id"] = util.generateRandomUUID()
      return dynamicProperty
    }

    config.statisticsGetCallback = (statisticsType, statisticsProperty,
      customComponentProperty,
      persistentProperty, dynamicProperty) => {
      StatisticsLogger.warn('----------------------一个埋点开始---------------------------')
      StatisticsLogger.debug("埋点类型:" + getEventType(statisticsType))
      StatisticsLogger.debugJson("框架赋予埋点属性:", statisticsProperty)
      if (customComponentProperty) {
        StatisticsLogger.debugJson("埋点组件上自定义属性:", customComponentProperty)
      }
      if (persistentProperty) {
        StatisticsLogger.debugJson("全局埋点静态属性:", persistentProperty)
      }
      if (dynamicProperty) {
        StatisticsLogger.debugJson("全局埋点动态属性:", dynamicProperty)
      }
      StatisticsLogger.warn('----------------------一个埋点结束---------------------------')

    }


    StatisticsManager.getInstance().register(config, uiContext, this.context, EntryAbility)

  }
```

<br>

## 约束和限制
---

在下述版本验证通过：

DevEco Studio 5.0.3 Release

Build #DS-233.14475.28.36.5090300

Build Version: 5.0.9.300, built on March 13, 2025


## 开源协议

---
本项目基于 Apache License 2.0 ，请自由的享受和参与开源。

## 联系我们

---

这是一个开源项目，如果您在使用过程中有任何问题 或者 有什么改进的建议，欢迎联系我们。
邮箱地址：tocongshanghai@163.com




