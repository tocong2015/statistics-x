export class TimeUtil {

  static locale = "zh-CN";
  /**
   * 单位 ：s
   * */
  static isSameDay(firstTime: number, secondTime: number) {
    return TimeUtil.parse_yyyy_MM_dd(firstTime) == TimeUtil.parse_yyyy_MM_dd(secondTime)

  }

  /**
   * @param secondTime 时间（单位：s）
   * 返回 2024/04/09   yyyy/MM/dd
   * */
  static parse_yyyy_MM_dd(secondTime: number): string {
    let date = new Date(secondTime * 1000);
    let dateFormat1 = new Intl.DateTimeFormat(TimeUtil.locale, {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    });
    let formattedDate1 = dateFormat1.format(date);
    return formattedDate1;
  }
}