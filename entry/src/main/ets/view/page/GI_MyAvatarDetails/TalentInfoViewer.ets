import TalentDetailsDialog from './TalentDetailsDialog'
import TalentInfo from '../../../viewmodel/page/GI_MyAvatarDetails/TalentInfo'

@Component
export default struct TalentInfoViewer {
  info: TalentInfo = null
  element: string = ''
  _size: number = 75

  TalentDetailsDialogController: CustomDialogController = new CustomDialogController({
    builder: TalentDetailsDialog({ info: this.info, talentWiki: this.info.wiki['promote'] }),
    customStyle: true
  })

  build() {
    Stack() {
      Image($rawfile(this.info.icon))
        .width(this._size / 2)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .margin({ top: '4%', left: '2%' })
      Row() {
        Text(`${this.info.current_level + (this.info.extraUpgrade ? 3 : 0)}`)
          .fontSize(16)
          .fontColor(this.info.extraUpgrade ? '#f7ce00' : Color.White)
          .fontWeight(this.info.extraUpgrade ? FontWeight.Medium : FontWeight.Normal)
      }
      .width(this._size / 2)
      .height(this._size / 3.2)
      .borderRadius(5)
      .backdropBlur(20)
      .backgroundColor('#4D000000')
      .justifyContent(FlexAlign.Center)
      .margin({ top: this._size / 1.5 })
    }
    .width(this._size)
    .aspectRatio(1)
    .alignContent(Alignment.Center)
    .backgroundImage($rawfile(`GI/resource/others/ElementalConstellationBGI/talent-${this.element.toLowerCase()}.png`))
    .backgroundImageSize(ImageSize.Contain)
    .onClick(() => {
      this.TalentDetailsDialogController.open()
    })
  }
}