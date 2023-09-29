import ConstellationInfo from '../../../../viewmodel/page/GI_MyAvatarDetails/ConstellationInfo'
import ConstellationDetailsDialog from './ConstellationDetailsDialog'

@Component
export default struct ConstellationInfoViewer {
  info: ConstellationInfo = null
  element: string = ''
  _size: number = 60

  TalentDetailsDialogController: CustomDialogController = new CustomDialogController({
    builder: ConstellationDetailsDialog({ info: this.info }),
    customStyle: true
  })

  build() {
    Column() {
      Image($rawfile(this.info.icon))
        .width(this._size / 2)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .margin({ top: '4%', left: '2%' })
    }
    .width(this._size)
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundImage($rawfile(`GI/resource/others/ElementalConstellationBGI/talent-${this.element.toLowerCase()}.png`))
    .backgroundImageSize(ImageSize.Contain)
    .onClick(() => {
      this.TalentDetailsDialogController.open()
    })
  }
}