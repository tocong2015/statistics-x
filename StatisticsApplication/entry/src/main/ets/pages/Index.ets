import { router } from '@kit.ArkUI';


@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
         router.pushUrl({url:"pages/SecondPage"})
        })
    }
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {

  }

  onPageShow(): void {
    console.debug("首页展示")
  }
}