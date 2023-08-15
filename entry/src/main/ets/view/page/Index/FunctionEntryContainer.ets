import FunctionEntryCard from './FuntionEntryCard'

@Component
export default struct FunctionEntryContainer {
  private functions = [
    { title: '我的角色', icon: $rawfile('GI/resource/others/roleIcon.png'), targetPage: 'pages/GI_MyAvatars' },
  ]
  @State bgColors: Color[] = [Color.Red, Color.Orange, Color.Yellow, Color.Green, Color.Pink, Color.Grey, Color.Blue, Color.Brown]
  @State currentBp: string = 'unknown'

  build() {
    Column() {
      GridRow({
        columns: 12,
        gutter: { x: 5, y: 10 },
        direction: GridRowDirection.Row
      }) {
        ForEach(this.functions, (item) => {
          GridCol({ span: { xs: 4, sm: 3, md: 2, lg: 1 } }) {
            Row() {
              FunctionEntryCard({ title: item.title, icon: item.icon, targetPage: item.targetPage })
            }
            .width('100%')
            .height(80)
          }
          .borderWidth(2)
          .borderRadius(8)
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}