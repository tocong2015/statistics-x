import { HashMap } from "@kit.ArkTS";

export function mapToJson(map: HashMap<string, string>): string {
  // 创建一个空对象来存储转换后的键值对
  const jsonObj: Record<string, string> = {};

  // 遍历Map
  map.forEach((value, key) => {
    // 将键转换为字符串（如果它还不是字符串的话）
    const stringKey = typeof key === 'string' ? key : JSON.stringify(key);

    // 将键值对存储到对象中
    if(value){
      jsonObj[stringKey] = value;
    }

  });

  // 将对象转换为JSON字符串
  return JSON.stringify(jsonObj);
}