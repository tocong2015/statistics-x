import dataPreferences from '@ohos.data.preferences';
import { StringBuilder } from '../string/StringBuilder';
import { PreferenceFileType } from './PreferenceFileType';

export class PreferenceUtil {
  private mContext: Context | null = null;
  private mPreferences: dataPreferences.Preferences | null = null;
  private mName: PreferenceFileType | null = null;
  private mLongNumberLength = 4096;

  public constructor(context: Context, name: PreferenceFileType) {
    this.mContext = context;
    this.mName = name;
    let Options: dataPreferences.Options = { name: this.mName };
    this.mPreferences = dataPreferences.getPreferencesSync(this.mContext, Options);
  }

  // 异步存储
  public put(key: string, value: dataPreferences.ValueType) {
    this.mPreferences?.put(key, value).then(() => {
      this.mPreferences?.flush()
    })
  }

  public putLongString(key: string, value: string) {
    if (value.length < this.mLongNumberLength) {
      this.put(key, value);
    } else {
      let group = Math.ceil(value.length / this.mLongNumberLength);
      this.put(key + "group", group);
      for (let i = 0; i < group - 1; i++) {
        this.put(key + `${i}`, value.substring(i * this.mLongNumberLength, (i + 1) * this.mLongNumberLength));
      }
      this.put(key + `${group - 1}`, value.substring((group - 1) * this.mLongNumberLength));
    }
  }

  public putLongStringSync(key: string, value: string) {
    if (value.length < this.mLongNumberLength) {
      this.putSync(key, value);
    } else {
      let group = Math.ceil(value.length / this.mLongNumberLength);
      this.putSync(key + "group", group);
      for (let i = 0; i < group - 1; i++) {
        this.putSync(key + `${i}`, value.substring(i * this.mLongNumberLength, (i + 1) * this.mLongNumberLength));
      }
      this.putSync(key + `${group - 1}`, value.substring((group - 1) * this.mLongNumberLength));
    }
  }

  public getLongStringSync(key: string, defaultValue: string): string {
    let group = this.getSync(key + "group", -1) as number;
    if (group == -1) {
      return this.getSync(key, defaultValue) as string;
    } else {
      let stringBuilder = new StringBuilder();
      for (let i = 0; i < group; i++) {
        stringBuilder.append(this.getSync(key + `${i}`, defaultValue) as string);
      }
      return stringBuilder.toString();
    }
  }


  public putSync(key: string, value: dataPreferences.ValueType) {
    this.mPreferences?.putSync(key, value);
    this.mPreferences?.flush();
  }

  public getSync(key: string, defaultValue: dataPreferences.ValueType): dataPreferences.ValueType | undefined {
    return this.mPreferences?.getSync(key, defaultValue);
  }


  public deleteSync(key: string) {
    let group = this.getSync(key + "group", -1) as number;
    if (group == -1) {
      this.mPreferences?.deleteSync(key);
    } else {
      this.mPreferences?.deleteSync(key + "group")
      for (let i = 0; i < group; i++) {
        this.mPreferences?.deleteSync(key + `${i}`);
      }
    }
    this.mPreferences?.flush();
  }

  public deleteAll() {
    let Options: dataPreferences.Options = { name: this.mName! };
    dataPreferences.deletePreferences(this.mContext, Options);
  }
}