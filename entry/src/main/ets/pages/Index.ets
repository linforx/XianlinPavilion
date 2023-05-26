import EnkaAPI from '../model/ServiceProvider/EnkaAPI'
import router from '@ohos.router'
import PageBackButton from '../viewmodel/PageBackButton'
import PageMoreButton from '../viewmodel/PageMoreButton'


@Entry
@Component
struct Index {
  @State title: string = '仙麟阁'
  @State titleHeight: number = 80
  @State message: string = 'Hello World'
  @State number: Number = 1
  private context = globalThis.getContext()
  private arr: number[] = [0, 1, 2, 3]
  @State isActive: boolean = false
  @State dex: number = 0

  build() {
    Column() {
      Navigation() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(async () => {
            let characters = await EnkaAPI.getCharactersMapAsync(this.context)
            let loc = await EnkaAPI.getLocalizationMapAsync(this.context)
            let response = await new EnkaAPI()
              .applyGetGameInfo({ hostOption: 0, uid: '151157466' })
              .getResponseAsync()
            if (response.success) {
              var data = JSON.parse(response.data)
              console.warn(`${data['avatarInfoList'][0]['fightPropMap']['22']}`)
            }
          })
      }
      .title({
        builder: this.NavigationTitle,
        height: this.titleHeight
      })
      .toolBar()
    }.height('100%')
  }

  @Builder
  NavigationTitle() {
    Row() {
      Column() {
        Image($r('app.media.app_icon'))
          .height('80%')
          .aspectRatio(1)
          .borderRadius(8)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height('100%')
      .aspectRatio(1)


      Text(this.title)
        .fontSize(30)
        .fontColor($r('app.color.text_color'))
        .fontWeight(FontWeight.Bold)

      Blank()

      PageMoreButton({ titleHeight: this.titleHeight,
        menus: [{
          desc: '第一',
          action: () => { console.warn('hello') },
          icon: $rawfile('GI/resource/10000002/UI_AvatarIcon_Side_Ayaka.webp')
        }, {
          desc: '第二',
          action: () => { console.warn('hello') },
          icon: $rawfile('GI/resource/10000002/UI_AvatarIcon_Side_Ayaka.webp')
        }, {
          desc: '第三',
          action: () => { console.warn('hello') },
          icon: $rawfile('GI/resource/10000002/UI_AvatarIcon_Side_Ayaka.webp')
        }, {
          desc: '第四',
          action: () => { console.warn('hello') }
        }]
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .width('100%')
    .padding(8)
  }
}