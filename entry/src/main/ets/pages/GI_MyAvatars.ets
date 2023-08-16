import GenshinAPI from '../model/ServiceProvider/GenshinAPI'
import PageBackButton from '../view/PageBackButton'
import common from '@ohos.app.ability.common'
import router from '@ohos.router'
import GameRole from '../model/User/GameRole'
import User from '../model/User/User'
import CookieType from '../common/service/CookieType'
import DynamicSecretVersion from '../common/service/DynamicSecretVersion'
import SaltType from '../common/service/SaltType'
import promptAction from '@ohos.promptAction'
import PageMoreButton from '../view/PageMoreButton'
import AvatarCard from '../view/page/GI_MyAvatars/AvatarCard'
import AvatarBriefInfo from '../viewmodel/page/GI_MyAvatars/AvatarBriefInfo'

@Entry
@Component
struct GI_MyAvatars {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private user: User = null
  private role: GameRole = null
  @State isRefreshing: boolean = false
  @State titleHeight: number = 70
  @State avatarList: AvatarBriefInfo[] = []

  aboutToAppear() {
    this.user = globalThis.SelUser as User
    this.role = globalThis.SelGIRole as GameRole
    if (!this.role || !this.user) {
      router.back()
    }
    this.isRefreshing = true
  }

  async getDataFromMihoyoServerAsync() {
    console.warn('getDataFromMihoyoServerAsync')
    try {
      var res = await new GenshinAPI()
        .applyCharacter(this.role.gameUid, this.role.region)
        .setCookie(this.user.cookie.getByType(CookieType.BothCLToken))
        .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
        .getResponseAsync()
    } catch (err) {
      console.warn(err)
    }
    console.warn('getDataFromMihoyoServerAsync done')
    this.isRefreshing = false
  }

  build() {
    Column() {
      Navigation() {
        Refresh({ refreshing: $$this.isRefreshing, offset: 20, friction: 62 }) {
          Scroll() {
            Column() {
              GridRow({
                columns: 12,
                gutter: { x: 5, y: 10 },
                direction: GridRowDirection.Row
              }) {
                ForEach(this.avatarList, (avatar: AvatarBriefInfo) => {
                  GridCol({ span: { xs: 6, sm: 4, md: 2, lg: 1 } }) {
                    Row() {
                      AvatarCard({ avatar: avatar })
                    }
                    .width('100%')
                  }
                  .borderRadius(8)
                  .clip(true)
                })
              }
              .width('100%')
            }
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .height('100%')
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
        }
        .onRefreshing(() => {
          this.getDataFromMihoyoServerAsync()
        })
      }
      .mode(NavigationMode.Stack)
      .title({
        builder: this.NavigationTitle,
        height: this.titleHeight
      })
      .margin({ bottom: `${globalThis?.avoidArea?.bottomRect?.height ?? 120}px` })
    }
    .backgroundColor($r('app.color.page_background_color'))
    .width('100%')
    .height('100%')
    .padding({ top: `${globalThis?.avoidArea?.topRect?.height ?? 120}px`, left: 8, right: 8 })
  }

  @Builder
  NavigationTitle() {
    Row() {
      PageBackButton()

      Text('我的角色')
        .fontSize(24)
        .fontColor($r('app.color.text_color'))
        .fontWeight(FontWeight.Bold)

      Blank()

      PageMoreButton({ titleHeight: this.titleHeight,
        menus: [{
          desc: '从角色展柜同步',
          action: () => { console.warn('hello') },
        }]
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .width('100%')
    .padding(8)
  }
}