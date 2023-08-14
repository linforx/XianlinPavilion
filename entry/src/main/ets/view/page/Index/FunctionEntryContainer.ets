@Entry
@Component
export default struct FunctionEntryContainer {
  build() {
    GridRow() {
      GridCol({ span: { sm: 12 } }) {
        GridRow() {
          GridCol({ span: { sm: 2 } }) {
            Row() {
              Text('left').fontSize(24)
            }
            .justifyContent(FlexAlign.Center)
            .height('90%')
          }.backgroundColor('#ff41dbaa')

          GridCol({ span: { sm: 10 } }) {
            Row() {
              Text('right').fontSize(24)
            }
            .justifyContent(FlexAlign.Center)
            .height('90%')
          }.backgroundColor('#ff4168db')
        }
        .backgroundColor('#19000000')
        .height('100%')
      }

      GridCol({ span: { sm: 12 } }) {
        Row() {
          Text('footer')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('10%')
        .backgroundColor(Color.Pink)
      }
    }
    .width('100%')
  }
}