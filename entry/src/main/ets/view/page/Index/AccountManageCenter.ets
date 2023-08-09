/**
 * @FileName: AccountManageCenter
 * @Author: Administrator
 * @Date: 2023/5/28 16:36
 * Description: 帐户管理中心控件
 */

import common from '@ohos.app.ability.common'
import User from '../../../model/User/User'
import AccountInfo from '../../../viewmodel/page/Index/AccountInfo'
import promptAction from '@ohos.promptAction'
import appSetting from '../../../common/preference/appSetting'

@Component
export default struct AccountManageCenter {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @Link userList: User[]
  @Link accountInfoList: AccountInfo[]

  async deletUser(uid: string) {
    let index: number
    for (index = 0; index < this.userList.length; ++index) {
      if (this.userList[index].uid == uid) {
        break;
      }
    }
    if (index >= this.userList.length) {
      promptAction.showToast({
        message: '删除账户失败'
      })
    }
    // 删除userList中的指定uid用户
    let new_userList: User[] = []
    for (let i = 0; i < index; ++i) {
      new_userList.push(this.userList[i])
    }
    for (let j = index + 1; j < this.userList.length; ++j) {
      new_userList.push(this.userList[j])
    }
    this.userList = new_userList
    // 刷新页面账户信息节点
    let new_accountInfoList: AccountInfo[] = []
    for (let user of this.userList) {
      new_accountInfoList.push(new AccountInfo(user))
    }
    this.accountInfoList = new_accountInfoList

    if (globalThis.selAccountUid == uid) {
      globalThis.selAccountUid = ''
    }
  }

  build() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.accountInfoList, (account: AccountInfo, index: number) => {
          ListItem() {
            Row() {
              Radio({ value: `Radio${index}`, group: 'userRadioGroup' })
                .checked(account.uid == globalThis.selAccountUid)
                .height(15)
                .width(15)
                .margin(10)
                .onChange(async (isChecked: boolean) => {
                  if (isChecked) {
                    globalThis.selAccountUid = account.uid
                    if (await appSetting.putAsync('selAccountUid', account.uid)) {
                      if (!(await appSetting.flushAsync())) {
                        promptAction.showToast({
                          message: '帐户切换保存失败'
                        })
                      }
                    } else {
                      console.error('无法向preference中存入信息')
                    }
                  }
                })

              Image(account.accountHeadImg)
                .height(50)
                .aspectRatio(1)
                .borderRadius(15)

              Column() {
                Text(account.nickname)
                  .fontColor($r('app.color.text_color'))
                  .fontSize(16)
                Text(account.uid)
                  .fontColor($r('app.color.sub_text_color'))
                  .fontSize(16)
              }
              .height(50)
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })

              Blank()

              Button() {
                Row() {
                  Text('删除')
                    .fontSize(15)
                    .fontColor($r('app.color.warning_color'))
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
              }
              .type(ButtonType.Capsule)
              .height(30)
              .width(60)
              .margin({ right: 10 })
              .backgroundColor($r('app.color.general_control_background_color'))
              .onClick(() => {
                AlertDialog.show({
                  title: '你正在删除一个账户（不可逆）',
                  message: `是否删除账户：${account.uid}`,
                  autoCancel: true,
                  alignment: DialogAlignment.Bottom,
                  gridCount: 4,
                  offset: { dx: 0, dy: -20 },
                  primaryButton: {
                    value: '取消',
                    fontColor: $r('app.color.text_color'),
                    action: () => {
                      promptAction.showToast({
                        message: '帐户删除操作已取消'
                      })
                    }
                  },
                  secondaryButton: {
                    value: '删除',
                    fontColor: $r('app.color.warning_color'),
                    action: () => {
                      this.deletUser(account.uid)
                    }
                  },
                  cancel: () => {
                    promptAction.showToast({
                      message: '帐户删除操作已取消'
                    })
                  }
                })
              })

            }
            .padding({ top: 10, bottom: 10, left: 5, right: 5 })
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .backgroundColor($r('app.color.card_background_color'))
            .backdropBlur(40)
            .borderRadius(10)
            .clip(true)
          }
        })
      }
      .height('80%')
      .borderRadius(10)
      .clip(true)
    }
    .width('100%')
    .height('100%')
    .padding(10)
  }
}