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

  dialogController: CustomDialogController = new CustomDialogController({
    builder: Menus({ menuList: this.menus }),
    customStyle: true,
    alignment: DialogAlignment.TopEnd,
    offset: { dx: -15, dy: this.titleHeight }
  })

  build() {
    Button() {
      Column() {
        Image($r('app.media.ic_public_more'))
          .height('64%')
          .aspectRatio(1)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .type(ButtonType.Normal)
    .backgroundColor('#00000000')
    .height('100%')
    .aspectRatio(1)
    .borderRadius(8)
    .clip(true)
    .onClick((event) => {
      this.dialogController.open()
    })
  }
}

@CustomDialog
struct Menus {
  controller: CustomDialogController
  private menuList: { desc: string, action: () => void, icon?: string | Resource | PixelMap }[]

  build() {
    Column() {
      List() {
        ForEach(this.menuList, (item: { desc: string, action: () => void, icon?: string | Resource | PixelMap }) => {
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
            .borderRadius(14)
            .height(52)
            .width('100%')
            .clip(true)
            .onClick(() => {
              item.action()
              promptAction.showToast({
                message: 'action 执行'
              })
              this.controller.close()
            })
          }
        })
      }
      .divider({ strokeWidth: 1, startMargin: 15, endMargin: 15 })
      .width('100%')
      .constraintSize({ maxHeight: this.menuList.length * 52 })
      .borderRadius(14)
      .clip(true)
    }
    .width(160)
    .backgroundColor('#fff')
    .borderRadius(16)
    .padding(5)
  }
}