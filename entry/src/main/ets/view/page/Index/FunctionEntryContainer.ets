import FunctionEntryCard from './FuntionEntryCard'

@Component
export default struct FunctionEntryContainer {
  private functions = [
    { title: '我的角色', icon: $rawfile('GI/resource/others/roleIcon.png'), targetPage: 'pages/GenshinImpact/MyAvatars' },
    { title: '百科图鉴', icon: $rawfile('GI/resource/others/wiki.png'), targetPage: 'pages/GenshinImpact/WikiCategory' }
  ]
  @State bgColors: Color[] = [Color.Red, Color.Orange, Color.Yellow, Color.Green, Color.Pink, Color.Grey, Color.Blue, Color.Brown]

  build() {
    Column() {
      GridRow({
        columns: 12,
        gutter: { x: 10, y: 10 },
        direction: GridRowDirection.Row
      }) {
        ForEach(this.functions, (item) => {
          GridCol({ span: { xs: 4, sm: 3, md: 2, lg: 2 } }) {
            Row() {
              FunctionEntryCard({ title: item.title, icon: item.icon, targetPage: item.targetPage })
            }
            .width('100%')
            .height(80)
          }
          .borderRadius(8)
          .clip(true)
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}