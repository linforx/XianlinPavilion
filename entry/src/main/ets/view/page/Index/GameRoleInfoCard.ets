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
  private selectUID: string
  private index
  private role: GameRoleInfo
  build() {
    Button() {
      Row() {
        Column() {
          Text(this.role.nickname)
            .fontColor($r('app.color.text_color'))
            .fontSize(16)
          Text(this.role.gameUid)
            .fontColor($r('app.color.sub_text_color'))
            .fontSize(16)
        }
        .height(50)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })

        Blank()

        Radio({ value: `Radio${this.index}`, group: 'gameRoleRadioGroup' })
          .checked(this.role.gameUid == this.selectUID)
          .height(15)
          .width(15)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectIndex = this.index
            }
            console.log(`Radio${this.index} status is ` + isChecked)
          })
      }
      .width('100%')
    }
    .width('61.4%')
    .type(ButtonType.Normal)
    .backgroundColor('#00000000')
    .borderRadius(10)
    .padding({ top: 10, bottom: 10, left: 5, right: 5 })
    .clip(true)
  }
}
