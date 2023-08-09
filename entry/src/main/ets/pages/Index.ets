import Want from '@ohos.app.ability.Want'
import wantConstant from '@ohos.ability.wantConstant'
import router from '@ohos.router'
import PageMoreButton from '../view/PageMoreButton'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import animator, { AnimatorResult } from '@ohos.animator'
import AccountManageCenter from '../view/page/Index/AccountManageCenter'
import User from '../model/User/User'
import GameRole from '../model/User/GameRole'
import AccountInfo from '../viewmodel/page/Index/AccountInfo'
import GameRoleInfo from '../viewmodel/page/Index/GameRoleInfo'
import GameRoleInfoCard from '../view/page/Index/GameRoleInfoCard'
import MihoyoAPI from '../model/ServiceProvider/MihoyoAPI'
import Cookie from '../model/User/Cookie'
import GameRoleChooseDialog from '../view/page/Index/GameRoleChooseDialog'
import GI_DailyNoteCard from '../view/page/Index/GI_DailyNoteCard'
import GI_DailyNoteInfo from '../viewmodel/page/Index/GI_DailyNoteInfo'
import Animator from '@ohos.animator'
import { getDBHelper } from '../common/database/DatabaseHelper'
import relationalStore from '@ohos.data.relationalStore'
import tableAccount from '../common/database/tables/account'
import appSetting from '../common/preference/appSetting'

/* 本页面中出现的Account指代User的UI相关信息 */

@Entry
@Component
struct Index {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State ready_exit: boolean = false                    // 标识第一次返回按钮已按下
  @State title: string = '仙麟阁'                        // 首页标题（应用名）
  @State titleHeight: number = 76                       // 标题栏高度
  @State selIndex: 0 | 1 = 0                            // 标识选中的是原神分区（0）还是星穹铁道分区（1）
  tabController: TabsController = new TabsController()  // 分区控制器

  @State userList: User[] = globalThis.userList ?? []   // 用户列表，由Start页面处理完成后获取
  @State accountInfoList: AccountInfo[] = []            // 与用户列表相关的账户列表UI对象
  selUser: User = null                                  // 选中的用户
  selGameRole_genshin: GameRole = null                  // 选中的原神角色
  selGameRole_starrail: GameRole = null                 // 选中的星铁角色
  @State selAccount: AccountInfo = new AccountInfo(this.selUser)                                // 与选中的账号信息关联的UI对象
  @State selGameRoleInfo_genshin: GameRoleInfo = new GameRoleInfo(new GameRole({}), '')         // 与选中的原神角色信息关联的UI对象
  @State selGameRoleInfo_starrail: GameRoleInfo = new GameRoleInfo(new GameRole({}), '')        // 与选中的星铁角色信息关联的UI对象

  @State showAMCP: boolean = false                      // 账户管理中心面板显隐控制
  @State loginTip: string = ''                          // 登录状态信息提示

  @State gameRoleList: GameRole[] = []                  // 所选账户的游戏角色列表，弹出游戏角色选择器时从网络加载
  gameRoleChooseDialogController_genshin: CustomDialogController = new CustomDialogController({         // 原神角色选择器弹窗控制器
    builder: GameRoleChooseDialog({
      selGameRoleInfo: $selGameRoleInfo_genshin,
      gameRoleList: $gameRoleList,
      cancel: () => {},
      confirm: async (role: GameRole) => {
        // 更新Index页面的选中信息，刷新UI节点
        this.selGameRole_genshin = role
        this.selGameRoleInfo_genshin = new GameRoleInfo(role)
        this.selUser.gameRoleChosen.Genshin.uid = role.gameUid
        globalThis.SelGIRole = this.selGameRole_genshin         // 更新全局“选中的原神角色”
        if (await appSetting.putAsync('selGIRoleUid', this.selUser.gameRoleChosen.Genshin.uid)) {
          if (!(await appSetting.flushAsync())) {
            promptAction.showToast({
              message: '原神角色选中保存失败'
            })
          }
        } else {
          console.error('无法向preference中存入信息')
        }
        this.updateGIDataAsync()
      }
    }),
    customStyle: true
  })
  gameRoleChooseDialogController_starrail: CustomDialogController = new CustomDialogController({        // 星铁角色选择器弹窗控制器
    builder: GameRoleChooseDialog({
      selGameRoleInfo: $selGameRoleInfo_starrail,
      gameRoleList: $gameRoleList,
      cancel: () => {},
      confirm: async (role: GameRole) => {
        this.selGameRole_starrail = role
        this.selGameRoleInfo_starrail = new GameRoleInfo(role)
        this.selUser.gameRoleChosen.StarRail.uid = role.gameUid
        globalThis.SelHSRRole = this.selGameRole_starrail       // 更新全局“选中的崩坏：星穹铁道角色”
        if (await appSetting.putAsync('selHSRRoleUid', this.selUser.gameRoleChosen.StarRail.uid)) {
          if (!(await appSetting.flushAsync())) {
            promptAction.showToast({
              message: '星穹铁道角色选中保存失败'
            })
          }
        } else {
          console.error('无法向preference中存入信息')
        }
      }
    }),
    customStyle: true
  })

  isAddingAccount: boolean = false

  /* 原神游戏数据 */
  @State GI_DailyNoteData: GI_DailyNoteInfo = new GI_DailyNoteInfo()
  @State GI_DailyNoteDataUpdateFlag: boolean = false

  async aboutToAppear() {
    await this.getAccountFromDatabaseAsync()
    for (let user of this.userList) {
      await user.updateUserInfoAsync()
    }
    await this.updateSelUserInfoAsync()
  }

  // 从本地数据库中读取账户列表
  async getAccountFromDatabaseAsync() {
    let DBHelper = getDBHelper(this.context)
    let predicate = new relationalStore.RdbPredicates('account')
    predicate.greaterThan('id', 0)
    try {
      let accountDataList = await DBHelper.queryInTableAccountAsync(predicate, tableAccount.fields)
      let userList: User[] = []
      for (let item of accountDataList) {
        userList.push(new User(item['cookies'], item['account_id']))
      }
      this.userList = userList
    } catch (err) {
      promptAction.showToast({
        message: '无法从本地数据库中读取帐户信息'
      })
    }
    await this.updateSelUserInfoAsync()
  }

  // 页面呈现生命周期函数
  async onPageShow() {
    if (this.isAddingAccount) {
      this.isAddingAccount = false
      let cookie = router.getParams()?.['cookie'] ?? ''
      if (!cookie) {
        this.isAddingAccount = false
        promptAction.showToast({
          message: '帐户创建已取消'
        })
        return
      }
      // 处理帐户创建过程
      await this.accountAddEventHandler(cookie)
      await this.updateSelUserInfoAsync()
    }
    router.clear()
  }
  // 页面返回回调函数
  onBackPress() {
    // 直接返回桌面
    this.backHome()

    return true
  }
  // 页面布局函数
  build() {
    Column() {
      Navigation() {
        Stack() {
          Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
            // 原神分区
            TabContent() {
              List({ space: 20 }) {
                ListItem() {
                  Column() {
                    List() {
                      ListItem() {        // 游戏角色控制入口控件
                        Button() {
                          Row() {
                            Image(this.selAccount.accountHeadImg)
                              .height(40)
                              .aspectRatio(1)
                              .borderRadius(20)
                            Column() {
                              Text(this.selGameRoleInfo_genshin.nickname ? this.selGameRoleInfo_genshin.nickname : (this.loginTip ? this.loginTip : this.getAccountTip('genshin')))
                                .fontColor($r('app.color.text_color'))
                                .fontSize(16)
                                .fontWeight(FontWeight.Medium)

                              Text(this.selGameRoleInfo_genshin.gameUid ? this.selGameRoleInfo_genshin.gameUid : '*********')
                                .fontColor($r('app.color.sub_text_color'))
                                .fontSize(16)
                            }
                            .height(40)
                            .margin({ left: 10, right: 10 })
                            .justifyContent(FlexAlign.SpaceBetween)
                            .alignItems(HorizontalAlign.Start)

                            Blank()

                            Image($r('app.media.ic_public_arrow_right'))
                              .height(25)
                          }
                          .margin({ left: 5, right: 5, top: 15, bottom: 15 })
                          .width('100%')
                        }
                        .type(ButtonType.Normal)
                        .borderRadius(16)
                        .backgroundColor('#00000000')
                        .onClick(() => {
                          if (this.selUser) {
                            this.selUser.getGameRoleListAsync()
                              .then((list) => {
                                this.gameRoleList = list
                                this.gameRoleChooseDialogController_genshin.open()
                              })
                          }
                        })
                      }
                      ListItem() {        // 帐户管理入口控件
                        Button() {
                          Row() {
                            Column()
                              .width(40)

                            Text('账号管理')
                              .fontColor($r('app.color.text_color'))
                              .fontSize(18)
                              .fontWeight(FontWeight.Medium)
                              .margin({ left: 10 })

                            Blank()

                            Image($r('app.media.ic_public_arrow_right'))
                              .height(25)
                          }
                          .margin({ left: 5, right: 5, top: 15, bottom: 15 })
                          .width('100%')
                        }
                        .type(ButtonType.Normal)
                        .borderRadius(16)
                        .backgroundColor('#00000000')
                        .onClick(() => {
                          this.showAMCP = true
                        })
                      }
                    }
                    .divider({ strokeWidth: 1, startMargin: 60, endMargin: 16, color: $r('app.color.stroke_line_color') })

                  }
                  .width('100%')
                  .padding(5)
                }
                .borderRadius(20)
                .backgroundColor($r('app.color.card_background_color'))
                .clip(true)

                ListItem() {
                  GI_DailyNoteCard({ data: $GI_DailyNoteData, isUpdating: $GI_DailyNoteDataUpdateFlag })
                }
                .borderRadius(20)
                .backgroundColor($r('app.color.card_background_color'))
                .clip(true)
              }
              .padding({ left: 15, right: 15 })
              .height('100%')
              .width('100%')
            }
            .tabBar(this.genshinBar())
            // 星穹铁道分区
            TabContent() {
              List() {
                ListItem() {
                  Column() {
                    List() {
                      ListItem() {        // 游戏角色控制入口控件
                        Button() {
                          Row() {
                            Image(this.selAccount.accountHeadImg)
                              .height(40)
                              .aspectRatio(1)
                              .borderRadius(20)
                            Column() {
                              Text(this.selGameRoleInfo_starrail.nickname ? this.selGameRoleInfo_starrail.nickname : (this.loginTip ? this.loginTip : this.getAccountTip('starrail')))
                                .fontColor($r('app.color.text_color'))
                                .fontSize(16)
                                .fontWeight(FontWeight.Medium)

                              Text(this.selGameRoleInfo_starrail.gameUid ? this.selGameRoleInfo_starrail.gameUid : '*********')
                                .fontColor($r('app.color.sub_text_color'))
                                .fontSize(16)
                            }
                            .height(40)
                            .margin({ left: 10, right: 10 })
                            .justifyContent(FlexAlign.SpaceBetween)
                            .alignItems(HorizontalAlign.Start)

                            Blank()

                            Image($r('app.media.ic_public_arrow_right'))
                              .height(25)
                          }
                          .margin({ left: 5, right: 5, top: 15, bottom: 15 })
                          .width('100%')
                        }
                        .type(ButtonType.Normal)
                        .borderRadius(16)
                        .backgroundColor('#00000000')
                        .onClick(() => {
                          if (this.selUser) {
                            this.selUser.getGameRoleListAsync()
                              .then((list) => {
                                this.gameRoleList = list
                                this.gameRoleChooseDialogController_starrail.open()
                              })
                          }
                        })
                      }
                      ListItem() {        // 帐户管理入口控件
                        Button() {
                          Row() {
                            Column()
                              .width(40)

                            Text('账号管理')
                              .fontColor($r('app.color.text_color'))
                              .fontSize(18)
                              .fontWeight(FontWeight.Medium)
                              .margin({ left: 10 })

                            Blank()

                            Image($r('app.media.ic_public_arrow_right'))
                              .height(25)
                          }
                          .margin({ left: 5, right: 5, top: 15, bottom: 15 })
                          .width('100%')
                        }
                        .type(ButtonType.Normal)
                        .borderRadius(16)
                        .backgroundColor('#00000000')
                        .onClick(() => {
                          this.showAMCP = true
                        })
                      }
                    }
                    .divider({ strokeWidth: 1, startMargin: 60, endMargin: 16, color: $r('app.color.stroke_line_color') })

                  }
                  .width('100%')
                  .padding(5)
                }
                .borderRadius(20)
                .backgroundColor($r('app.color.card_background_color'))
                .clip(true)
              }
              .padding({ left: 15, right: 15 })
              .height('100%')
              .width('100%')
            }
            .tabBar(this.starrailBar())
          }
          .animationDuration(0)
          .onChange((index) => {
            this.selIndex = index as 0 | 1
          })
          // 帐户控制中心面板控件
          this.AccountManageCenterPanel()
        }
      }
      .mode(NavigationMode.Stack)
      .title({
        builder: this.NavigationTitle,
        height: this.titleHeight
      })
      .margin({ bottom: `${globalThis?.avoidArea?.bottomRect?.height ?? 120}px` })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background_color'))
    .padding({ top: `${globalThis?.avoidArea?.topRect?.height ?? 120}px` })
  }
  // 退出应用
  exitApp() {
    this.context.terminateSelf()
  }
  // 返回桌面
  backHome() {
    let want: Want = {
      bundleName: 'com.huawei.android.launcher',
      abilityName:'com.huawei.android.launcher.unihome.UniHomeLauncher',
      action: 'android.intent.action.MAIN',
      flags: wantConstant.Flags.FLAG_NOT_OHOS_COMPONENT,
      entities: ['android.intent.category.LAUNCHER']
    }
    console.warn('返回桌面')
    this.context.startAbility(want, (error) => {
      if (error) {
        promptAction.showToast({
          message: '拉起桌面失败: error.code = ' + error.code
        })
      }
    })
  }

  getAccountTip(game: string) {
    if (this.userList.length == 0) return '请创建你的账户'
    if (!this.selUser) return '请选择一个账户'
    if (game == 'genshin' && !this.selGameRole_genshin) return '请选择一个角色'
    if (game == 'starrail' && !this.selGameRole_starrail) return '请选择一个角色'
  }

  // 异步更新选中的用户的信息，刷新用户列表并将新的选中信息（用户、原神角色、星铁角色）广播到全局（globalThis）
  async updateSelUserInfoAsync() {
    // 更新选中用户的账户信息
    let i: number
    for (i = 0; i < this.userList.length; ++i) {
      if (this.userList[i].uid == globalThis.selAccountUid) {
        this.loginTip = '登录中'
        // 更新选中帐户的信息
        this.selUser = this.userList[i]
        await this.selUser.updateBBSCookieAsync()
        await this.selUser.updateUserInfoAsync()
        // 刷新账号下的游戏角色列表
        let gameRoles = await this.selUser.getGameRoleListAsync()
        this.selUser.gameRoleChosen.Genshin.uid = globalThis.selGIRoleUid
        this.selUser.gameRoleChosen.StarRail.uid = globalThis.selHSRRoleUid
        console.warn(`genshinrole: ${this.selUser.gameRoleChosen.Genshin.uid}`)
        console.warn(`starrailrole: ${this.selUser.gameRoleChosen.StarRail.uid}`)
        for (let role of gameRoles) {
          if (this.selUser.gameRoleChosen.Genshin.uid && (this.selUser.gameRoleChosen.Genshin.uid == role.gameUid)) {
            this.selGameRole_genshin = role
          }
          if (this.selUser.gameRoleChosen.StarRail.uid && (this.selUser.gameRoleChosen.StarRail.uid == role.gameUid)) {
            this.selGameRole_starrail = role
          }
        }
        globalThis.SelUser = this.selUser                         // 更新全局“当前用户”

        if (this.selGameRole_genshin) {
          this.selGameRoleInfo_genshin = new GameRoleInfo(this.selGameRole_genshin)
          globalThis.SelGIRole = this.selGameRole_genshin         // 更新全局“选中的原神角色”
          this.updateGIDataAsync()        // 异步执行原神分区数据刷新
        } else {
          globalThis.SelGIRole = null
        }
        if (this.selGameRole_starrail) {
          this.selGameRoleInfo_starrail = new GameRoleInfo(this.selGameRole_starrail)
          globalThis.SelHSRRole = this.selGameRole_starrail       // 更新全局“选中的崩坏：星穹铁道角色”
        } else {
          globalThis.SelHSRRole = null
        }
        // 刷新头像
        this.selAccount = new AccountInfo(this.selUser)
        // 登录完成
        this.loginTip = ''
        globalThis.selAccountUid = this.selUser.uid

        break
      }
    }
    if (i == this.userList.length) {      // 没用选中角色，清除旧的游戏角色选中信息
      this.selUser = null
      this.selAccount = new AccountInfo(this.selUser)
      this.selGameRole_genshin = null
      this.selGameRole_starrail = null
      this.selGameRoleInfo_genshin = new GameRoleInfo(new GameRole({}), '')
      this.selGameRoleInfo_starrail = new GameRoleInfo(new GameRole({}), '')
    }
    // 刷新页面账户列表信息节点
    let new_accountInfoList: AccountInfo[] = []
    for (let user of this.userList) {
      new_accountInfoList.push(new AccountInfo(user))
    }
    this.accountInfoList = new_accountInfoList
  }

  async updateGIDataAsync() {
    // 更新体力数据
    this.GI_DailyNoteDataUpdateFlag = true
    let dailyNoteData = await this.selUser.getGIDailyNoteDateAsync()
    let dailyNoteInfo = new GI_DailyNoteInfo(dailyNoteData)
    this.GI_DailyNoteDataUpdateFlag = false
    animateTo({
      duration: 600,
      curve: Curve.EaseInOut,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: () => {
        console.info('play end')
      }
    }, () => {
      this.GI_DailyNoteData = dailyNoteInfo
    })
  }

  // 帐户控制中心面板入口组件
  @Builder
  AccountManageCenterPanel() {
    Panel(this.showAMCP) {
      Column() {
        Image($r('app.media.ic_user_portrait'))
          .height(30)
          .aspectRatio(1)
        Text('帐户管理中心')
          .fontSize(16)
          .fontColor($r('app.color.text_color'))
        Divider()

        Button() {
          Row() {
            Text('登录账户')
              .fontSize(18)
              .fontColor($r('app.color.high_light_text_color'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .type(ButtonType.Normal)
        .height(40)
        .width(160)
        .borderRadius(10)
        .backgroundColor($r('app.color.card_background_color'))
        .alignSelf(ItemAlign.End)
        .margin(10)
        .onClick(() => {
          this.isAddingAccount = true
          console.log(JSON.stringify(this.isAddingAccount))
          router.pushUrl({
            url: 'pages/Login'
          })
        })

        AccountManageCenter({ userList: $userList, accountInfoList: $accountInfoList })
      }
    }
    .backgroundColor($r('app.color.panel_background_color'))
    .type(PanelType.Foldable)
    .mode(PanelMode.Half)
    .halfHeight(500)
    .miniHeight(100)
    .dragBar(true) // 默认开启
    .onChange((width: number, height: number, mode: PanelMode) => {
      if (mode == 0) {
        this.showAMCP = false
        this.updateSelUserInfoAsync()
      }
    })
  }
  // 处理添加帐户的函数，获取米游社帐户cookie
  async accountAddEventHandler(cookie: string) {
    promptAction.showToast({
      message: '获取帐户信息...'
    })
    let newUser = new User(cookie)
    let success = await newUser.updateMultiCookieAsync()
    if (!success) {
      promptAction.showToast({
        message: '帐户创建失败'
      })
      return
    } else {
      let new_userList: User[] = []
      await newUser.updateBBSCookieAsync()
      await newUser.updateUserInfoAsync()
      for (let i = 0; i < this.userList.length; ++i) {
        if (this.userList[i].uid == newUser.uid) continue
        new_userList.push(this.userList[i])
      }

      new_userList.push(newUser)
      this.userList = new_userList

      await newUser.flush(this.context)
    }
  }

  @Builder
  NavigationTitle() {
    Row() {
      Text(this.title)
        .fontSize(30)
        .fontColor($r('app.color.text_color'))
        .fontWeight(FontWeight.Bold)

      Blank()

      PageMoreButton({ titleHeight: this.titleHeight,
        menus: [{
          desc: '关于',
          action: () => { console.warn('hello') },
        }, {
          desc: '退出应用',
          action: () => { this.exitApp() }
        }]
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .width('100%')
    .padding(8)
  }

  @Builder
  genshinBar() {
    Row() {
      Button() {
        Row() {
          Image($rawfile('GI/genshin_impact_icon.png'))
            .height('100%')
            .aspectRatio(1)
            .borderRadius(6)

          Text('原神')
            .fontSize(16)
            .fontColor(this.selIndex == 0 ? '#0a59f7' : $r('app.color.text_color'))
            .maxLines(1)
            .margin({ left: 10 })
        }
        .clip(true)
        .height('100%')
        .width('100%')
        .onClick(() => {
          if (this.selIndex === 1) {
            this.selIndex = 0
            this.tabController.changeIndex(this.selIndex)
          }
        })
      }
      .type(ButtonType.Normal)
      .backgroundColor('#00000000')
      .height('80%')
      .width('100%')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Bottom)
    .height('100%')
    .width('100%')
  }

  @Builder
  starrailBar() {
    Row() {
      Button() {
        Row() {
          Image($rawfile('HSR/honkai_star_rail_icon.png'))
            .height('100%')
            .aspectRatio(1)
            .borderRadius(6)

          Text('崩坏·星穹铁道')
            .fontSize(16)
            .fontColor(this.selIndex == 1 ? '#0a59f7' : $r('app.color.text_color'))
            .maxLines(1)
            .margin({ left: 10 })
        }
        .clip(true)
        .height('100%')
        .width('100%')
        .onClick(() => {
          if (this.selIndex === 0) {
            this.selIndex = 1
            this.tabController.changeIndex(this.selIndex)
          }
        })
      }
      .type(ButtonType.Normal)
      .backgroundColor('#00000000')
      .height('80%')
      .width('100%')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Bottom)
    .height('100%')
    .width('100%')
  }
}