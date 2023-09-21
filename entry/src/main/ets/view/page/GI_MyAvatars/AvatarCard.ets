import AvatarBriefInfo from '../../../viewmodel/page/GI_MyAvatars/AvatarBriefInfo'
import WeaponBriefInfo from '../../../viewmodel/page/GI_MyAvatars/WeaponBriefInfo'
import router from '@ohos.router'

@Preview
@Component
export default struct AvatarCard {
  @ObjectLink avatar: AvatarBriefInfo

  build() {
    Button() {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            Column() {
              Image($rawfile(`GI/resource/${(this.avatar.id == 10000005 || this.avatar.id == 10000007) ? this.avatar.id + '-' + this.avatar.element.toLowerCase() : this.avatar.id}/${this.avatar.icon}.webp`))
                .width('100%')
                .aspectRatio(1)
                .objectFit(ImageFit.Contain)
            }
            .width('100%')
            .aspectRatio(1)
            .backgroundImage($rawfile(`GI/resource/others/RarityBGI/bg${this.avatar.rarity}.png`))
            .backgroundImageSize(ImageSize.Contain)
            .borderRadius({ topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 30 })
            .clip(true)

            Column() {
              Text(this.avatar.name)
                .fontSize(15)
                .height(15)
              Row() {
                Image($rawfile(`GI/resource/${this.avatar.weapon.id}/${this.avatar.weapon.icon}.webp`))
                  .height('100%')
                  .aspectRatio(1)

                Text(this.avatar.weapon.name)
                  .fontSize(10)
              }
              .height(17)
            }
            .width('100%')
            .height(32)
            .borderRadius(10)
            .clip(true)
          }

          Row() {
            Image($rawfile(`GI/resource/others/star${this.avatar.rarity}.png`))
              .height(18)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 95 })

          Row() {
            Image($rawfile(`GI/resource/others/ElementIcon/${this.avatar.element}.png`))
              .height(25)
              .aspectRatio(1)
          }
          .width(25)
          .borderRadius(15)
          .justifyContent(FlexAlign.Center)
          .margin({ right: 70, top: 7 })

          Stack() {
            Text(`${this.avatar.activedConstellation}`)
              .fontSize(15)
              .fontColor($r('app.color.primary_text_inversion'))
          }
          .margin({ left: 95 })
        }
        .width(110)
      }
    }
    .type(ButtonType.Normal)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(10)
  }
}