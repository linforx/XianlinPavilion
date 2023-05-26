import { readRawfileTextAsync } from '../common/utils/Utils'

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
            let str = await readRawfileTextAsync(this.context, 'EnkaAPIResource/characters.json')
            let json = JSON.parse(str)
            console.warn(`${json['10000002']['NameTextMapHash']}`)
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}