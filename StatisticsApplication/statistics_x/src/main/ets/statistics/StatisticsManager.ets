import { PreferenceCache } from '../cache/PreferenceCache';
import Logger from '../Log/Logger';

import { StatisticsConfig } from './StatisticsConfig';
import { StatisticsType } from './StatisticsType';
import { StatisticsUIObserver } from './StatisticsUIObserver';
import { util } from '@kit.ArkTS';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';

/**
 * @author: tc
 * @time: 2025/3/24 13:30
 * @description: 埋点入口，是外面的唯一入口
 **/
export class StatisticsManager {
  private static instance: StatisticsManager;
  private _config: StatisticsConfig | null = null;
  private uiContext: UIContext | null = null

  private constructor() {
  }

  public static getInstance(): StatisticsManager {
    if (!StatisticsManager.instance) {
      StatisticsManager.instance = new StatisticsManager();
    }
    return StatisticsManager.instance;
  }

  public get config(): StatisticsConfig {
    return this._config!;
  }

  /**
   * @author: tc
   * @time: 2025/3/24 13:42
   * @description:注册
   **/
  register(config: StatisticsConfig, uiContext: UIContext, context: Context, entryAbility: Object) {
    this._config = config
    this.uiContext = uiContext

    //初始化缓存
    PreferenceCache.init(context)
    this.initAspect(entryAbility)

    this.addUIObserver()

  }

  private initAspect(entryAbility: Object) {

    util.Aspect.addBefore(entryAbility, "onBackground", false, () => {
      Logger.debug("进入后台")
      StatisticsUIObserver.getInstance().sendAppDestroyStatisticsProperty()
    })

    util.Aspect.addBefore(entryAbility, "onDestroy", false, () => {
      Logger.debug("app销毁")
      StatisticsUIObserver.getInstance().sendAppDestroyStatisticsProperty()
    })

    util.Aspect.addBefore(entryAbility, "onForeground", false, () => {
      Logger.debug("进去前台")
      StatisticsUIObserver.getInstance().sendAppStartStatisticsProperty()
    })

    util.Aspect.addBefore(entryAbility, "onNewWant", false, (want: Want, launchParam: AbilityConstant.LaunchParam) => {
      Logger.debug("被动打开")
      StatisticsUIObserver.getInstance().sendAppStartPassively()
    })

    StatisticsUIObserver.getInstance().sendAppInstall()
    StatisticsUIObserver.getInstance().sendAppCrash()


  }

  /**
   * @author tc
   * @date 2025/3/24  22:24
   * @desc 手动埋点
   **/
  sendNoAutoStatistics(property: object, currentUrl?: string, refererUrl?: string) {
    StatisticsUIObserver.getInstance().sendNoAutoStatistics(property, currentUrl, refererUrl)
  }


  /**
   * @author: tc
   * @time: 2025/3/24 13:43
   * @description:UI观察
   **/
  private addUIObserver() {
    if (this._config?.autoTrackTypes.has(StatisticsType.APP_CLICK)) {
      Logger.debug("注册点击事件监听")
      this.uiContext?.getUIObserver().on("willClick", (event: ClickEvent, node?: FrameNode) => {
        let clickObserver = StatisticsUIObserver.getInstance().getClickObserver()
        clickObserver(node, this.uiContext, event)
      })
    }


    Logger.debug("注册页面事件监听")

    this.uiContext?.getUIObserver().on('routerPageUpdate', (info) => {
      let viewScreenCallback = StatisticsUIObserver.getInstance().getRouterViewScreenCallback()
      viewScreenCallback(info)
    });


    this.uiContext?.getUIObserver().on('navDestinationSwitch', (info) => {
      let viewScreenCallback = StatisticsUIObserver.getInstance().getNaviViewScreenCallback()
      viewScreenCallback(info)
    })
  }

  haveSpecialStatisticsType(type: StatisticsType) {
    if (this.config != null) {
      return this._config!.autoTrackTypes.has(type)
    } else {
      return false
    }
  }
}