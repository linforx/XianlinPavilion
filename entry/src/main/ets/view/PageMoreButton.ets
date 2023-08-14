/**
 * @FileName: PageMoreButton
 * @Author: Administrator
 * @Date: 2023/5/26 17:11
 * Description:
 */
import promptAction from '@ohos.promptAction'

@Component
export default struct PageMoreButton {
  @Prop titleHeight: number
  private menus: { desc: string, action: () => void, icon?: string | Resource | PixelMap }[] = []



  build() {
    Button() {
      Column() {
        Image($r('app.media.ic_public_more'))
          .height(40)
          .aspectRatio(1)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .type(ButtonType.Normal)
    .backgroundColor('#00000000')
    .height(60)
    .aspectRatio(1)
    .borderRadius(8)
    .clip(true)
    .bindMenu(this.Menus())
  }

  @Builder
  Menus() {
    Column() {
      List() {
        ForEach(this.menus, (item) => {
          ListItem() {
            Button() {
              Row() {
                if (item['icon']) {
                  Image(item.icon)
                    .height('80%')
                    .aspectRatio(1)
                }
                Text(item.desc)
                  .fontSize(20)
                  .fontColor($r('app.color.text_color'))
                  .margin({ top: 10, bottom: 10 })
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .height('100%')
              .alignItems(VerticalAlign.Center)
              .padding(5)
            }
            .type(ButtonType.Normal)
            .backgroundColor('#00000000')
            .borderRadius(20)
            .height(52)
            .width('100%')
            .clip(true)
            .onClick(() => {
              item.action()
              promptAction.showToast({
                message: 'action 执行'
              })
            })
          }
        })
      }
      .divider({ strokeWidth: 1, startMargin: 15, endMargin: 15, color: $r('app.color.stroke_line_color') })
      .width('100%')
      .height(this.menus.length * 52)
      .constraintSize({ maxHeight: this.menus.length * 52 })
      .borderRadius(18)
      .clip(true)
    }
    .width(180)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(20)
    .padding(2)
  }
}

