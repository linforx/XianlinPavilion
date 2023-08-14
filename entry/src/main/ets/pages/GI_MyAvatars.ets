import GenshinAPI from '../model/ServiceProvider/GenshinAPI'
import PageBackButton from '../view/PageBackButton'
import common from '@ohos.app.ability.common'
import router from '@ohos.router'
import GameRole from '../model/User/GameRole'
import User from '../model/User/User'
import CookieType from '../common/service/CookieType'
import DynamicSecretVersion from '../common/service/DynamicSecretVersion'
import SaltType from '../common/service/SaltType'

@Entry
@Component
struct GI_MyAvatars {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private user: User = null
  private role: GameRole = null
  @State progress: number = 0;
  @State hideProgress: Visibility = Visibility.None;
  @State titleHeight: number = 76

  async aboutToAppear() {
    this.user = globalThis.SelUser as User
    this.role = globalThis.SelGIRole as GameRole
    if (!this.role || !this.user) {
      router.back()
    }
    let res = await new GenshinAPI()
      .applyCharacter(this.role.gameUid, this.role.region)
      .setCookie(this.user.cookie.getByType(CookieType.BothCLToken))
      .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
      .getResponseAsync()
    console.warn(res.data)
  }

  build() {
    Column() {
      Navigation() {

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
    .padding({ top: `${globalThis?.avoidArea?.topRect?.height ?? 120}px` })
  }

  @Builder
  NavigationTitle() {
    Row() {
      PageBackButton()

      Text('我的角色')
        .fontSize(16)
        .fontColor($r('app.color.text_color'))
        .fontWeight(FontWeight.Bold)

      Blank()
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .width('100%')
    .padding(8)
  }
}