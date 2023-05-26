import EnkaAPI from '../model/ServiceProvider/EnkaAPI'


@Entry
@Component
struct Index {
  @State message: string = 'Hello World'
  @State number: Number = 1
  private context = globalThis.getContext()

  build() {
    Row() {
      Column() {
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
      .width('100%')
    }
    .height('100%')
  }
}