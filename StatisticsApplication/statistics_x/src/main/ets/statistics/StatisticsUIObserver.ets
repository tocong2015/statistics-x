import Logger from "../Log/Logger"
import { FrameNodeUtil } from "../util/FrameNodeUtil"
import { PageInfo, uiObserver } from "@kit.ArkUI"
import { HashMap } from "@kit.ArkTS"
import { StatisticsManager, StatisticsType } from "../../../../Index"
import { PreferenceCache } from "../cache/PreferenceCache"
import { PreferenceFileType } from "../cache/PreferenceFileType"
import { TimeUtil } from "../util/TimeUtil"
import { hiAppEvent } from "@kit.PerformanceAnalysisKit"

/**
 * @author: tc
 * @time: 2025/3/24 13:46
 * @description:UI观察者
 **/
export class StatisticsUIObserver {
  private static mInstance: StatisticsUIObserver | null = null
  currentPageUrl = "" //当前页面
  refererPageUrl = "" //上一页面
  pageDurationMap: HashMap<string, number> = new HashMap();
  private _isFirstDay = true //是否是安装第一天
  private _isFirstLaunch = true //是否是第一次启动

  private preferenceUtil = PreferenceCache.getPreference(PreferenceFileType.DEVICE)

  static getInstance() {
    if (StatisticsUIObserver.mInstance == null) {
      StatisticsUIObserver.mInstance = new StatisticsUIObserver()
    }
    return StatisticsUIObserver.mInstance
  }

  private constructor() {
    this.validateIsFirstDay()
    this.validateIsFirstLaunch()
  }


  getClickObserver() {
    return (node: FrameNode | undefined, uiContext: UIContext | null, clickEvent: ClickEvent) => {
      if (node == undefined || uiContext == null) {
        return
      }

      //获取用户设置的节点ID（通用属性设置的ID）。
      let id: string = node.getId();
      //自定义属性
      let trackData = node.getCustomProperty(id);
      //节点类型
      let nodeType = node.getNodeType()

      Logger.debug("组件点击:组件自定义属性:" + trackData + "\n" + "组件点击:组件类型:" + nodeType)
      let nodeContent = ""
      try {
        nodeContent =
          FrameNodeUtil.getNodeText(node, Number(clickEvent.target.area.width), Number(clickEvent.target.area.height))
      } catch (e) {
      }
      Logger.debug("组件点击:组件上面的文本:" + nodeContent)
      if (trackData != null) {
        Logger.debug("组件点击：组件自定义属性:" + trackData)
      }
      //获取系统分配的唯一标识的节点UniqueID。
      //可以判断当前FrameNode是否对应一个实体FrameNode节点。当UniqueId大于0时表示该对象对应一个实体FrameNode节点。
      let uniqueId: number = node.getUniqueId();
      //通过组件的uniqueId获取该节点对应的Router和NavDestination页面信息。
      //navDestinationInfo属性为其对应的NavDestination信息；
      let pageInfo: PageInfo = uiContext.getPageInfoByUniqueId(uniqueId);
      if (pageInfo.routerPageInfo) {
        Logger.debug("按钮点击:在router页面:" + JSON.stringify(pageInfo.routerPageInfo))
      } else if (pageInfo.navDestinationInfo) {
        Logger.debug("按钮点击:在navi页面:" + JSON.stringify(pageInfo.routerPageInfo))
      }

      if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_CLICK) &&
        StatisticsManager.getInstance().config != null &&
      StatisticsManager.getInstance().config.statisticsGetCallback) {

        StatisticsManager.getInstance().config.statisticsGetCallback!(StatisticsType.APP_CLICK,
          this.createAppClickStatisticsProperty(nodeType, nodeContent), trackData,
          StatisticsManager.getInstance().config.persistentProperty,
          StatisticsManager.getInstance().config!.dynamicProperty?.())
      }
    }
  }

  getNaviViewScreenCallback() {
    return (info: uiObserver.NavDestinationSwitchInfo) => {
      //先判断 from
      let fromUrl = ""
      let pageId = ""
      if (typeof info.from == "string") {
        fromUrl = info.from
      } else {
        fromUrl = info.from.name.toString()
        pageId = info.from.navDestinationId
      }
      //$AppPageLeave  页面离开
      Logger.debug(":page离开:\n" + "--上一页面--:" + this.refererPageUrl + "\n" + "--当前页面--:" +
        fromUrl)
      //   SAEventCreator.createSAEventData(SAAutoTrackType.APP_PAGE_LEAVE, this.refererPageUrl, fromUrl)

      if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_PAGE_LEAVE) &&
      StatisticsManager.getInstance().config.statisticsGetCallback) {
        StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_PAGE_LEAVE,
          this.createPageLeaveStatisticsProperty(pageId, fromUrl, this.refererPageUrl), undefined,
          StatisticsManager.getInstance().config!.persistentProperty,
          StatisticsManager.getInstance().config!.dynamicProperty?.())
      }

      this.refererPageUrl = fromUrl
      //再判断to
      let toUrl = ""
      let toPageId: string = ""
      if (typeof info.to == "string") {
        toUrl = info.to
      } else {
        toUrl = info.to.name.toString()
        toPageId = info.to.navDestinationId
      }
      //$AppViewScreen 页面展示
      this.pageDurationMap.set(toUrl + toPageId, new Date().getTime())
      Logger.debug(":page展示:\n" + "--上一页面--:" + this.refererPageUrl + "\n" + "--当前页面--:" + toUrl)
      this.currentPageUrl = toUrl

      if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_VIEW_SCREEN) &&
        StatisticsManager.getInstance().config != null &&
      StatisticsManager.getInstance().config.statisticsGetCallback) {
        StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_VIEW_SCREEN,
          this.createPageViewStatisticsProperty(), undefined,
          StatisticsManager.getInstance().config!.persistentProperty,
          StatisticsManager.getInstance().config!.dynamicProperty?.())
      }

      //  let statisticData = SAEventCreator.createSAEventData(SAAutoTrackType.APP_VIEW_SCREEN, this.refererPageUrl, toUrl)
      //发送数据
      //  StatisticsSend.cacheLocalDB(JSON.stringify(statisticData))
    }
  }


  getRouterViewScreenCallback() {
    return (info: uiObserver.RouterPageInfo) => {
      if (info.state == uiObserver.RouterPageState.ON_PAGE_SHOW) {
        this.currentPageUrl = info.path
        Logger.debug("--statistics--:show" + JSON.stringify(info))
        this.currentPageUrl = info.name
        this.pageDurationMap.set(info.name + info.pageId, new Date().getTime())
        if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_VIEW_SCREEN) &&
          StatisticsManager.getInstance().config != null &&
        StatisticsManager.getInstance().config.statisticsGetCallback) {
          StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_VIEW_SCREEN,
            this.createPageViewStatisticsProperty(), undefined,
            StatisticsManager.getInstance().config!.persistentProperty,
            StatisticsManager.getInstance().config!.dynamicProperty?.())
        }

      } else if (info.state == uiObserver.RouterPageState.ON_PAGE_HIDE) {
        Logger.debug("--statistics--:hide" + JSON.stringify(info))

        if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_PAGE_LEAVE) &&
          StatisticsManager.getInstance().config != null &&
        StatisticsManager.getInstance().config.statisticsGetCallback) {
          StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_PAGE_LEAVE,
            this.createPageLeaveStatisticsProperty(info.pageId), undefined,
            StatisticsManager.getInstance().config!.persistentProperty,
            StatisticsManager.getInstance().config!.dynamicProperty?.())
        }
        this.refererPageUrl = info.name

      }
    }
  }


  /**
   * @author: tc
   * @time: 2025/3/24 15:48
   * @description: 点击埋点的属性
   **/
  private createAppClickStatisticsProperty(elementType: string, elementContent: string): object {
    let property: object = new Object()

    property["referer_url"] = this.refererPageUrl
    property["current_url"] = this.currentPageUrl
    property["is_first_day"] = this._isFirstDay
    property["is_first_time"] = this._isFirstLaunch
    property["element_type"] = elementType
    property["element_content"] = elementContent
    return property
  }

  private createPageViewStatisticsProperty(currentUrl?: string, refererUrl?: string): object {

    let property: object = new Object()
    property["referer_url"] = refererUrl ?? this.refererPageUrl
    property["current_url"] = currentUrl ?? this.currentPageUrl
    property["is_first_day"] = this._isFirstDay
    property["is_first_time"] = this._isFirstLaunch
    return property
  }

  private createPageLeaveStatisticsProperty(pageId: string, currentUrl?: string, refererUrl?: string): object {
    let property: object = new Object()

    property["referer_url"] = refererUrl ?? this.refererPageUrl
    property["current_url"] = currentUrl ?? this.currentPageUrl
    property["is_first_day"] = this._isFirstDay
    property["is_first_time"] = this._isFirstLaunch
    let nowTime = new Date().getTime()
    let pageViewTime = this.getPageViewTime(currentUrl ?? this.currentPageUrl, pageId + "")
    if (pageViewTime != undefined) {
      property["event_duration"] = (nowTime - pageViewTime).toString()
    }
    return property
  }


  sendAppDestroyStatisticsProperty() {
    if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_END) &&
      StatisticsManager.getInstance().config != null &&
    StatisticsManager.getInstance().config.statisticsGetCallback) {
      let property: object = new Object()
      property["is_first_day"] = this._isFirstDay
      property["is_first_time"] = this._isFirstLaunch

      StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_END,
        property, undefined,
        StatisticsManager.getInstance().config!.persistentProperty,
        StatisticsManager.getInstance().config!.dynamicProperty?.())
    }
  }

  sendAppStartStatisticsProperty() {
    if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_START) &&
      StatisticsManager.getInstance().config != null &&
    StatisticsManager.getInstance().config.statisticsGetCallback) {
      let property: object = new Object()
      property["is_first_day"] = this._isFirstDay
      property["is_first_time"] = this._isFirstLaunch
      StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_START,
        property,
        undefined,
        StatisticsManager.getInstance().config!.persistentProperty,
        StatisticsManager.getInstance().config!.dynamicProperty?.()
      )
    }
  }


  sendAppStartPassively() {
    if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_START_PASSIVELY) &&
      StatisticsManager.getInstance().config != null &&
    StatisticsManager.getInstance().config.statisticsGetCallback) {

      StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_START_PASSIVELY,
        this.createPageViewStatisticsProperty(),
        undefined,
        StatisticsManager.getInstance().config!.persistentProperty,
        StatisticsManager.getInstance().config!.dynamicProperty?.()
      )
    }
  }


  sendAppInstall() {
    if (this._isFirstLaunch && StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_INSTALL) &&
      StatisticsManager.getInstance().config != null &&
    StatisticsManager.getInstance().config.statisticsGetCallback) {

      StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_INSTALL,
        new Object(),
        undefined,
        StatisticsManager.getInstance().config!.persistentProperty,
        StatisticsManager.getInstance().config!.dynamicProperty?.()
      )
    }
  }

  sendAppCrash() {

    if (StatisticsManager.getInstance().haveSpecialStatisticsType(StatisticsType.APP_CRASH) &&
      StatisticsManager.getInstance().config != null &&
    StatisticsManager.getInstance().config.statisticsGetCallback) {
      hiAppEvent.addWatcher({
        name: "crash_watcher",
        appEventFilters: [{
          domain: hiAppEvent.domain.OS,
          names: [hiAppEvent.event.APP_CRASH]
        }],
        onReceive: (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
          try {
            for (let appEventGroupsElement of appEventGroups) {
              for (let appEventInfosElement of appEventGroupsElement.appEventInfos) {
                let crashTrace = JSON.stringify(appEventInfosElement.params['exception'])
                let crashType: string = appEventInfosElement.params['crash_type']
                let property: object = new Object()
                property["is_first_day"] = this._isFirstDay
                property["is_first_time"] = this._isFirstLaunch
                property["crash_trace"] = crashTrace
                property["crash_type"] = crashType
                StatisticsManager.getInstance().config?.statisticsGetCallback!(StatisticsType.APP_CRASH,
                  property,
                  undefined,
                  StatisticsManager.getInstance().config!.persistentProperty,
                  StatisticsManager.getInstance().config!.dynamicProperty?.()
                )
              }
            }
          } catch (e) {
          }
        }
      })


    }
  }


  private getPageViewTime(pageUrl: string, pageId: string) {
    let viewPageTime = this.pageDurationMap.get(pageUrl + pageId)
    this.pageDurationMap.remove(pageUrl)
    return viewPageTime
  }

  private validateIsFirstDay() {
    let installTime = this.preferenceUtil.getSync("install_time", 0) as number
    if (installTime == 0) {
      this._isFirstDay = true
      this.preferenceUtil.putSync("install_time", new Date().getTime() / 1000)
    } else {
      this._isFirstDay = TimeUtil.isSameDay(installTime, new Date().getTime() / 1000)
    }
  }

  private validateIsFirstLaunch() {
    let firstLaunch = this.preferenceUtil.getSync("first_launch", true) as boolean
    this._isFirstLaunch = firstLaunch
    this.preferenceUtil.getSync("first_launch", false)
  }
}