import { PreferenceCache } from '../cache/PreferenceCache';
import Logger from '../Log/Logger';

import { StatisticsConfig } from './StatisticsConfig';
import { StatisticsType } from './StatisticsType';
import { StatisticsUIObserver } from './StatisticsUIObserver';
import { util } from '@kit.ArkTS';
import { UIAbility } from '@kit.AbilityKit';

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
  register(config: StatisticsConfig, uiContext: UIContext, context: Context) {
    this._config = config
    this.uiContext = uiContext
    //this.initAspect()
    //初始化缓存
    PreferenceCache.init(context)

    this.addUIObserver()

  }

   initAspect() {
     console.debug("增加aop")
     try {
       util.Aspect.addBefore(UIAbility, "onForeground", false,
         (instance: UIAbility,) => {
           console.debug("监听到ability 初始化")


         })
     }catch (e) {
       console.error("增加aop错误："+e)
     }

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