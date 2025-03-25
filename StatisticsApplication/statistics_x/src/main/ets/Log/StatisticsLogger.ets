import hilog from '@ohos.hilog';

export class StatisticsLogger {
  private domain: number;
  private prefix: string;
  private format: string = "%{public}s, %{public}s";
  private enabled: boolean = true

  constructor(prefix: string) {
    this.prefix = prefix;
    this.domain = 0xFF00;
  }

  debug(...args: Object[]): void {
    if (!this.enabled) {
      return
    }
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  info(...args: Object[]): void {
    if (!this.enabled) {
      return
    }
    hilog.info(this.domain, this.prefix, this.format, args);
  }

  warn(...args: Object[]): void {
    if (!this.enabled) {
      return
    }
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  error(...args: Object[]): void {
    hilog.error(this.domain, this.prefix, this.format, args);
  }

  debugJson(tag: string, data: Object) {
    this.jsonPrint(Level.DEBUG, tag, data);
  }

  infoJson(tag: string, data: Object) {
    this.jsonPrint(Level.INFO, tag, data);
  }

  warnJson(tag: string, data: Object) {
    this.jsonPrint(Level.WARN, tag, data);
  }

  errorJson(tag: string, data: Object) {
    this.jsonPrint(Level.ERROR, tag, data);
  }

  jsonPrint(level: Level, tag: string, data: Object) {
    if (!this.enabled || !data) {
      return;
    }
    const s = JSON.stringify(data, null, 2);
    const ss = s.split('\n')
    ss.forEach((value: string, _: number, __: string[]) => {
      this._print(level, tag, '\t' + value)
    })
  }

  private _print(level: Level, tag: string, content: Object) {
    switch (level) {
      case Level.DEBUG:
        this.debug(tag, content);
        break;
      case Level.INFO:
        this.info(tag, content);
        break;
      case Level.WARN:
        this.warn(tag, content);
        break;
      case Level.ERROR:
        this.error(tag, content);
        break;
    }
  }

  setEnabled(enabled: boolean) {
    this.enabled = enabled
  }
}

enum Level {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4
}

export default new StatisticsLogger('[--statistics--]');
