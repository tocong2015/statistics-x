import Logger from "../Log/Logger";
import { StatisticsType } from "./StatisticsType";
import { hash } from "@kit.CoreFileKit";
import { HashMap } from "@kit.ArkTS";

export class StatisticsConfig {
  private _enableLog: boolean = false; //开始日志
  private _autoTrackTypes: Set<StatisticsType> = new Set(); //忽略的事件的类型
  private _autoTrackIgnorePage?: Set<string> | undefined; //忽略的页面路径

  private _persistentProperty: object | null = null; //静态属性

  public set persistentProperty(value: object | null) {
    this._persistentProperty = value;
  }

  public get persistentProperty(): object | null {
    return this._persistentProperty;
  }
  private _dynamicProperty: (() => object) | null = null; //动态属性

  public set dynamicProperty(value: (() => object) | null) {
    this._dynamicProperty = value;
  }

  public get dynamicProperty(): (() => object) | null {
    return this._dynamicProperty;
  }

  //获取埋点的回调
  private _statisticsGetCallback: ((statisticsType: StatisticsType, statisticsProperty: object,
    customComponentProperty: object | undefined,
    persistentProperty: object | null, dynamicProperty: object | undefined) => void) | null = null;

  public set statisticsGetCallback(value: ((statisticsType: StatisticsType, statisticsProperty: object,
    customComponentProperty: object | undefined,
    persistentProperty: object | null, dynamicProperty: object | undefined) => void) | null) {
    this._statisticsGetCallback = value;
  }

  public get statisticsGetCallback(): ((statisticsType: StatisticsType, statisticsProperty: object,
    customComponentProperty: object | undefined,
    persistentProperty: object | null, dynamicProperty: object | undefined) => void) | null {
    return this._statisticsGetCallback;
  }





  public set enableLog(value: boolean) {
    this._enableLog = value;
    Logger.setEnabled(value)

  }

  public get enableLog(): boolean {
    return this._enableLog;
  }


  public set autoTrackTypes(value: Set<StatisticsType>) {
    this._autoTrackTypes = value;
  }

  public get autoTrackTypes(): Set<StatisticsType> {
    return this._autoTrackTypes;
  }


  public set autoTrackIgnorePage(value: Set<string> | undefined) {
    this._autoTrackIgnorePage = value;
  }

  public get autoTrackIgnorePage(): Set<string> | undefined {
    return this._autoTrackIgnorePage;
  }
}