/**
 * @author: tc
 * @time: 2025/3/24 13:28
 * @description:埋点类型
 **/
export enum StatisticsType {
  NO_AUTO, //手动埋点
  APP_START, //应用启动
  APP_START_PASSIVELY, //被动打开
  APP_FOREGROUND,//应用进入前台
  APP_BACKGROUND,//应用进入后台
  APP_END, //应用退出
  APP_CLICK, //元素点击
  APP_VIEW_SCREEN, //页面浏览
  APP_PAGE_LEAVE, //页面
  APP_CRASH, //崩溃
  APP_INSTALL, //app安装
  //APP_PUSH_CLICK, //推送点击
}

export function getEventType(event: StatisticsType) {
  let eventName = ""
  switch (event) {
    case StatisticsType.APP_START:
      eventName = "$AppStart"
      break;
    case StatisticsType.APP_END:
      eventName = "$AppEnd"
      break;
    case StatisticsType.APP_CLICK:
      eventName = "$AppClick"
      break;
    case StatisticsType.APP_PAGE_LEAVE:
      eventName = "$AppPageLeave"
      break;
    case StatisticsType.APP_VIEW_SCREEN:
      eventName = "$AppViewScreen"
      break;
    case StatisticsType.APP_CRASH:
      eventName = "AppCrashed"
      break;
    case StatisticsType.APP_INSTALL:
      eventName = "$AppInstall"
      break;
    case StatisticsType.APP_START_PASSIVELY:
      eventName = "$AppStartPassively"
      break;
    /* case StatisticsType.APP_PUSH_CLICK:
       eventName = "$AppPushClick"
       break;*/
  }

  return eventName;

}