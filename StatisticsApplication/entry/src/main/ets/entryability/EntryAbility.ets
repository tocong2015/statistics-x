import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getEventType, mapToJson, StatisticsConfig, StatisticsManager, StatisticsType } from 'statistics_x';
import { HashMap, JSON } from '@kit.ArkTS';
import Logger from 'statistics_x/src/main/ets/Log/Logger';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');


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
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }


  initStatistics(uiContext: UIContext) {
    let config = new StatisticsConfig()
    config.enableLog = true
    config.autoTrackTypes =
      new Set([StatisticsType.APP_CLICK, StatisticsType.APP_VIEW_SCREEN, StatisticsType.APP_PAGE_LEAVE])
    config.statisticsGetCallback = (statisticsType, statisticsProperty,
      customComponentProperty,
      persistentProperty, dynamicProperty) => {
      Logger.warn('----------------------一个埋点开始---------------------------')
      Logger.debug("埋点类型:" + getEventType(statisticsType))
      Logger.debug("埋点属性:\n" + statisticsProperty)
      Logger.debugJson("埋点属性:" ,statisticsProperty)
      if (customComponentProperty) {
        Logger.debug("埋点自定义属性:\n" + JSON.stringify(customComponentProperty))
      }
      if (persistentProperty) {
        Logger.debug("全局埋点静态属性:\n" + persistentProperty)
      }
      if (dynamicProperty) {
        Logger.debug("全局埋点动态属性:\n" + dynamicProperty)
      }
      Logger.warn('----------------------一个埋点结束---------------------------')

    }

    StatisticsManager.getInstance().register(config, uiContext, this.context)


  }
}


