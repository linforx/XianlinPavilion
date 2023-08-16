import AvatarBriefInfo from '../../../viewmodel/page/GI_MyAvatars/AvatarBriefInfo'
import WeaponBriefInfo from '../../../viewmodel/page/GI_MyAvatars/WeaponBriefInfo'

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
              Image($rawfile(`GI/resource/${this.avatar.id}/UI_AvatarIcon_Ayaka.webp`))
                .width(100)
                .objectFit(ImageFit.Contain)
                .aspectRatio(1)
            }
            .width(100)
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
            .width(100)
            .height(32)
            .borderRadius(10)
            .clip(true)
          }

          Row() {
            Image($rawfile(`GI/resource/others/star${this.avatar.rarity}.png`))
              .height(18)
          }
          .width(100)
          .justifyContent(FlexAlign.Center)
          .margin({ top: 85 })

          Stack() {
            Progress({ value: this.avatar.activedConstellation, total: 6, type: ProgressType.ScaleRing })
              .width(20)
              .style({ strokeWidth: 5, scaleCount: 6, scaleWidth: 5 })
              .borderRadius(10)
              .backdropBlur(20)
            Text(`${this.avatar.activedConstellation}`)
              .fontSize(12)
              .fontColor($r('app.color.primary_text_inversion'))
          }
          .margin({ left: 80 })
        }
        .width(100)
      }
    }
    .type(ButtonType.Normal)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(10)
  }
}