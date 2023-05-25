import util from '@ohos.util';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World'
  @State number: Number = 1
  private context = globalThis.getContext()


  async getFileText(path: string) {
    let value = await this.context.resourceManager.getRawFileContent(path)
    let decoder = util.TextDecoder.create('utf-8', { ignoreBOM : true })
    let retStr = decoder.decodeWithStream( value , {stream: false});
    console.warn(retStr)
  }


  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getFileText('EnkaAPIResource/characters.json')
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}