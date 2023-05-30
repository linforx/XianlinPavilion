/**
 * @FileName: UserInfoCard
 * @Author: Administrator
 * @Date: 2023/5/28 13:57
 * Description: 游戏角色信息卡，游戏角色选择器控件的子控件，展示角色信息
 */

import GameRoleInfo from '../../../viewmodel/page/Index/GameRoleInfo'

@Component
export default struct GameRoleInfoCard {
  @Link selectIndex: number
  private index: number
  private role: GameRoleInfo

  build() {
    Button() {
      Row() {
        Column() {
          Text(this.role.nickname)
            .fontColor(this.selectIndex == this.index ? $r('app.color.primary_text_inversion') : $r('app.color.text_color'))
            .fontSize(16)
          Text(this.role.gameUid)
            .fontColor(this.selectIndex == this.index ? $r('app.color.secondary_text_inversion') : $r('app.color.text_color'))
            .fontSize(16)
        }
        .height(50)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
      }
      .width('100%')
    }
    .width('80%')
    .constraintSize({ maxWidth: 300 })
    .type(ButtonType.Normal)
    .backgroundColor(this.selectIndex == this.index ? $r('app.color.high_light_text_color') : '#00000000')
    .borderRadius(10)
    .padding({ top: 10, bottom: 10, left: 5, right: 5 })
    .clip(true)
    .onClick(() => {
      this.selectIndex = this.index
    })
  }
}
