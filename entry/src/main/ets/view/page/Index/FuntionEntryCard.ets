import router from '@ohos.router'
@Component
export default struct FunctionEntryCard {
  private title: string = ''
  private icon: Resource | string
  private targetPage: string = ''

  build() {
    Button() {
      Column({ space: 5 }) {
        Row() {
          Image(this.icon)
            .width(40)
            .aspectRatio(1)
        }
        .justifyContent(FlexAlign.Center)
        .width(40)
        .aspectRatio(1)
        .borderRadius(8)
        .clip(true)

        Row() {
          Text(this.title)
            .fontColor($r('app.color.text_color'))
            .fontSize(16)
            .maxLines(1)
        }
        .justifyContent(FlexAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .type(ButtonType.Normal)
    .borderRadius(20)
    .backgroundColor($r('app.color.card_background_color'))
    .onClick(() => {
      console.log('转跳子功能页: ' + this.title)
      router.pushUrl({
        url: this.targetPage
      })
    })
  }
}