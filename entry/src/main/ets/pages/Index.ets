import router from '@ohos.router'
import PageMoreButton from '../view/PageMoreButton'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import AccountManageCenter from '../view/page/Index/AccountManageCenter'
import User from '../model/User/User'
import GameRole from '../model/User/GameRole'
import AccountInfo from '../viewmodel/page/Index/AccountInfo'
import GameRoleInfo from '../viewmodel/page/Index/GameRoleInfo'
import GameRoleInfoCard from '../view/page/Index/GameRoleInfoCard'


@Entry
@Component
struct Index {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State ready_exit: boolean = false                    // 标识第一次返回按钮已按下
  @State title: string = '仙麟阁'                        // 首页标题（应用名）
  @State titleHeight: number = 76                       // 标题栏高度
  @State selIndex: 0 | 1 = 0                            // 标识选中的是原神分区（0）还是星穹铁道分区（1）
  tabController: TabsController = new TabsController()  // 分区控制器

  @State userList: User[] = globalThis.userList         // 用户列表，由Start页面处理完成后获取
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
      confirm: (role: GameRole) => {
        this.selGameRole_genshin = role
        this.selGameRoleInfo_genshin = new GameRoleInfo(role)
      }
    }),
    customStyle: true
  })
  gameRoleChooseDialogController_starrail: CustomDialogController = new CustomDialogController({        // 星铁角色选择器弹窗控制器
    builder: GameRoleChooseDialog({
      selGameRoleInfo: $selGameRoleInfo_starrail,
      gameRoleList: $gameRoleList,
      cancel: () => {},
      confirm: (role: GameRole) => {
        this.selGameRole_starrail = role
        this.selGameRoleInfo_starrail = new GameRoleInfo(role)
      }
    }),
    customStyle: true
  })

  exitApp() {
    this.context.terminateSelf()
  }

  getAccountTip(game: string) {
    if (this.userList.length == 0) return '请创建你的账户'
    if (!this.selUser) return '请选择一个账户'
    if (game == 'genshin' && !this.selGameRole_genshin) return '请选择一个角色'
    if (game == 'starrail' && !this.selGameRole_starrail) return '请选择一个角色'
  }

  async updateSelUserInfo() {
    for (let i = 0; i < this.userList.length; ++i) {
      if (this.userList[i].uid == globalThis.selAccountUid) {
        this.loginTip = '登录中'
        // 更新选中帐户的信息
        this.selUser = this.userList[i]
        await this.selUser.updateBBSCookieAsync()
        await this.selUser.updateUserInfoAsync()
        let gameRoles = await this.selUser.getGameRoleListAsync()
        for (let role of gameRoles) {
          if (this.selUser.gameRoleChosen.Genshin.uid && (this.selUser.gameRoleChosen.Genshin.uid == role.gameUid)) {
            this.selGameRole_genshin = role
          }
          if (this.selUser.gameRoleChosen.StarRail.uid && (this.selUser.gameRoleChosen.StarRail.uid == role.gameUid)) {
            this.selGameRole_starrail = role
          }
        }

        if (this.selGameRole_genshin) {
          this.selGameRoleInfo_genshin = new GameRoleInfo(this.selGameRole_genshin)
        }
        if (this.selGameRole_starrail) {
          this.selGameRoleInfo_starrail = new GameRoleInfo(this.selGameRole_starrail)
        }

        this.selAccount = new AccountInfo(this.selUser)
        this.loginTip = ''
      }
    }
  }

  async onPageShow() {
    await this.updateSelUserInfo()
  }

  onBackPress() {
    // 实现双击返回退出应用
    if (this.ready_exit) {
      this.exitApp()
    } else {
      this.ready_exit = true
      setTimeout(() => {
        this.ready_exit = false
      }, 1000)
    }

    return true
  }

  build() {
    Column() {
      Navigation() {
        Stack() {
          Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
            // 原神分区
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
          .animationDuration(300)
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background_color'))
  }

  @Builder
  AccountManageCenterPanel() {
    Panel(this.showAMCP) { // 展示日程
      Column() {
        Text('帐户管理中心')
          .fontSize(16)
          .fontColor($r('app.color.text_color'))
        Divider()

        Button() {
          Row() {
            Text('添加账户')
              .fontSize(20)
              .fontColor($r('app.color.high_light_text_color'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .type(ButtonType.Normal)
        .height(50)
        .width(200)
        .borderRadius(10)
        .backgroundColor($r('app.color.card_background_color'))
        .alignSelf(ItemAlign.End)
        .margin(10)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Login'
          })
        })

        Scroll() {
          AccountManageCenter({ userList: $userList })
        }
      }
    }
    .backgroundColor($r('app.color.panel_background_color'))
    .type(PanelType.Foldable)
    .mode(PanelMode.Half)
    .miniHeight(100)
    .dragBar(true) // 默认开启
    .onChange((width: number, height: number, mode: PanelMode) => {
      if (mode == 0) {
        this.showAMCP = false
        this.updateSelUserInfo()
      }
    })
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
      .height('61.4%')
      .width('100%')
      .padding({ left: 10, right: 10 })
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
      .height('61.4%')
      .width('100%')
      .padding({ left: 10, right: 10 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Bottom)
    .height('100%')
    .width('100%')
  }
}

// 游戏角色选择器面板
@CustomDialog
struct GameRoleChooseDialog {
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
    .constraintSize({ maxWidth: 400 })
    .padding({ top: 15, bottom: 15, left: 10, right: 10 })
    .borderRadius(20)
  }
}