import Avatar from '../../../model/Game/GenshinImpact/Avatar'
import AvatarBriefInfo from '../../../viewmodel/page/GI_MyAvatars/AvatarBriefInfo'

@Preview
@CustomDialog
export default struct EnkaSyncResultCard {
  controller: CustomDialogController
  @Link avatarList: AvatarBriefInfo[]

  build() {
    Column() {
      Text(`本次更新了如下角色（共${this.avatarList.length ?? 0}个）`)
        .fontSize(18)
        .fontColor($r('app.color.text_color'))

      Scroll() {
        GridRow({
          columns: 12,
          gutter: { x: 5, y: 20 },
          direction: GridRowDirection.Row
        }) {
          ForEach(this.avatarList, (avatar: AvatarBriefInfo) => {
            GridCol({ span: { xs: 6, sm: 3, md: 3, lg: 3 } }) {
              Row() {
                Column() {
                  Column() {
                    Image($rawfile(`GI/resource/${avatar.id}/${avatar.icon}.webp`))
                      .width('100%')
                      .aspectRatio(1)
                  }
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundImage($rawfile('GI/resource/others/RarityBGI/bg5.png'))
                  .backgroundImageSize(ImageSize.Contain)
                  .borderRadius({ topLeft: 8, topRight: 8, bottomLeft: 8, bottomRight: 24 })
                  .clip(true)

                  Row() {
                    Text(avatar.name)
                      .fontSize(16)
                      .fontColor($r('app.color.text_color'))
                  }
                  .width('100%')
                  .height(20)
                  .justifyContent(FlexAlign.Center)
                }
                .width(80)
                .borderRadius(8)
                .backgroundColor($r('app.color.card_background_color'))
                .clip(true)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .borderRadius(8)
            .clip(true)
          })
        }
      }
      .height(260)
      .width('100%')

      Row() {
        Button('确认')
          .type(ButtonType.Normal)
          .backgroundColor('#00000000')
          .height(40)
          .width(200)
          .borderRadius(20)
          .fontSize(18)
          .fontColor($r('app.color.high_light_text_color'))
          .onClick(() => {
            this.controller.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .backgroundColor($r('app.color.page_background_color'))
    .width('88%')
    .constraintSize({ maxWidth: 400, maxHeight: 350 })
    .padding({ top: 15, bottom: 15, left: 15, right: 15 })
    .borderRadius(20)
  }
}