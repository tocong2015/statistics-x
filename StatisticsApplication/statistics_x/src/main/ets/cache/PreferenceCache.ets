import { HashMap } from '@kit.ArkTS';
import { PreferenceUtil } from './PreferencesUtil';
import { PreferenceFileType } from './PreferenceFileType';

export class PreferenceCache {
  private static mContext: Context | null = null;
  private static mHashMap: HashMap<PreferenceFileType, PreferenceUtil> = new HashMap();

  public static init(context: Context) {
    PreferenceCache.mContext = context;
  }

  static getPreference(name: PreferenceFileType): PreferenceUtil {
    let preferenceUtil = PreferenceCache.mHashMap.get(name);
    if (!preferenceUtil) {
      if (PreferenceCache.mContext) {
        preferenceUtil = new PreferenceUtil(PreferenceCache.mContext, name);
        PreferenceCache.mHashMap.set(name, preferenceUtil);
      }
    }
    return preferenceUtil;
  }

  static deletePreference(name: PreferenceFileType) {
    let preferenceUtil = PreferenceCache.mHashMap.get(name);
    if (preferenceUtil) {
      preferenceUtil.deleteAll();
    }
  }
}