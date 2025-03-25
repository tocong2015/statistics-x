import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getEventType, mapToJson, StatisticsConfig, StatisticsManager, StatisticsType } from 'statistics_x';
import { HashMap, JSON, util } from '@kit.ArkTS';
import StatisticsLogger from 'statistics_x/src/main/ets/Log/StatisticsLogger';


const DOMAIN = 0x0000;

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

}





