/**
 * @FileName: AccountManageCenter
 * @Author: Administrator
 * @Date: 2023/5/28 16:36
 * Description: 帐户管理中心控件
 */

import User from '../../../model/User/User'
import AccountInfo from '../../../viewmodel/page/Index/AccountInfo'

@Component
export default struct AccountManageCenter {
  @Link userList: User[]

  build() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.userList, (user: User, index: number) => {
          ListItem() {
            Row() {
              Image(user.accountHeadImg)
                .height(50)
                .aspectRatio(1)
                .borderRadius(15)

              Column() {
                Text(user.nickname)
                  .fontColor($r('app.color.text_color'))
                  .fontSize(16)
                Text(user.uid)
                  .fontColor($r('app.color.sub_text_color'))
                  .fontSize(16)
              }
              .height(50)
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })

              Blank()

              Radio({ value: `Radio${index}`, group: 'userRadioGroup' })
                .checked(user.uid == globalThis.selAccountUid)
                .height(15)
                .width(15)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    globalThis.selAccountUid = user.uid
                  }
                })
            }
            .padding({ top: 10, bottom: 10, left: 5, right: 5 })
            .width('100%')
            .backgroundColor($r('app.color.card_background_color'))
            .backdropBlur(40)
            .borderRadius(10)
            .clip(true)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding(10)
  }
}