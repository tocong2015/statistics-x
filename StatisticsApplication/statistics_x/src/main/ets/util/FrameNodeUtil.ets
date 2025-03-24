export class FrameNodeUtil {
  /**
   * @author: tc
   * @time: 2025/3/18 14:38
   * @description:获取节点内容
   **/
  static getNodeText(node: FrameNode, targetWidth: number, targetHeight: number,): string {
    let textList: string[] = [];
    // 检查当前节点是否有文本属性

    let inspectorObject: object = node.getInspectorInfo()
    if (inspectorObject["$attrs"]) {
      let attrsObject: object = inspectorObject["$attrs"]
      if (attrsObject["content"] && attrsObject["width"] && attrsObject["height"]) {
        /* let width = (attrsObject["width"] as string)
         let height = attrsObject["height"] as string
         if (this.truncateToTwoDecimals(targetWidth) ==
         this.truncateToTwoDecimals(Number(width.slice(0, width.length - 2))) &&
           this.truncateToTwoDecimals(targetHeight) ==
           this.truncateToTwoDecimals(Number(height.slice(0, height.length - 2)))) {
           textList.push(attrsObject["content"])
         }*/
        textList.push(attrsObject["content"])

      }
    }


    // 递归遍历子节点
    let childCount = node.getChildrenCount();
    for (let i = 0; i < childCount; i++) {
      let childNode = node.getChild(i)
      if (childNode) {
        let childTextList = FrameNodeUtil.getNodeText(childNode, targetWidth, targetHeight);
        textList = textList.concat(childTextList);
      }
    }
    return textList.join(",");

  }
}