/**
 * @FileName: GameRoleChooseDialog
 * @Author: Administrator
 * @Date: 2023/5/31 14:29
 * Description: 游戏角色选择器面板
 */

import GameRole from '../../../model/User/GameRole'
import GameRoleInfo from '../../../viewmodel/page/Index/GameRoleInfo'
import GameRoleInfoCard from './GameRoleInfoCard'


@CustomDialog
export default struct GameRoleChooseDialog {
  @Link selGameRoleInfo: GameRoleInfo
  @Link gameRoleList: GameRole[]
  @State selIndex: number = -1
  controller: CustomDialogController
  cancel: () => void
  confirm: (role: GameRole) => void

  aboutToAppear() {
    let i = 0;
    for (let role of this.gameRoleList) {
      if (role.gameUid == this.selGameRoleInfo.gameUid) {
        this.selIndex = i
      }
      ++i
    }
  }

  build() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.gameRoleList, (role: GameRole, index: number) => {
          ListItem() {
            GameRoleInfoCard({ selectIndex: $selIndex, index: index, role: new GameRoleInfo(role) })
          }
        })
      }
      .width('100%')
      .constraintSize({ maxHeight: 5 * 52 })
      .alignListItem(ListItemAlign.Center)

      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .backgroundColor('#00000000')
          .height(40)
          .width(150)
          .borderRadius(20)
          .fontSize(18)
          .fontColor($r('app.color.text_color'))
          .onClick(() => {
            this.cancel()
            this.controller.close()
          })
        Button('确认')
          .type(ButtonType.Normal)
          .backgroundColor('#00000000')
          .height(40)
          .width(150)
          .borderRadius(20)
          .fontSize(18)
          .fontColor($r('app.color.high_light_text_color'))
          .onClick(() => {
            this.confirm(this.selIndex >= 0 ? this.gameRoleList[this.selIndex] : null)
            this.controller.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin(10)
    }
    .backgroundColor($r('app.color.page_background_color'))
    .width('88%')
    .constraintSize({ maxWidth: 350 })
    .padding({ top: 15, bottom: 15, left: 15, right: 15 })
    .borderRadius(20)
  }
}