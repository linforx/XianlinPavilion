import PageBackButton from '../view/PageBackButton';
import webview from '@ohos.web.webview';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Login {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State url: string = 'Hello World'
  private mihoyoLogin: string = 'https://user.mihoyo.com/#/login/captcha'
  @State progress: number = 0;
  @State hideProgress: Visibility = Visibility.None;
  @State titleHeight: number = 76
  controller: WebviewController = new webview.WebviewController()

  build() {
    Column() {
      Navigation() {
        Column() {
          Progress({ value: this.progress, total: 100 })
            .color('#0000ff')
            .visibility(this.hideProgress)
            .width('100%')
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
            Web({ src: this.mihoyoLogin, controller: this.controller })
              .zoomAccess(true)
              .domStorageAccess(true)
              .javaScriptAccess(true)
              .geolocationAccess(true)

            Button('我已登录')
              .fontColor($r('app.color.text_color'))
              .fontSize(20)
              .height(50)
              .backgroundColor($r('app.color.card_background_color'))
              .type(ButtonType.Normal)
              .borderRadius(10)
              .onClick(() => {
                this.controller.runJavaScript('document.cookie', (err, result) => {
                  if (result.includes('login_ticket')) {
                    result = result.replace(/^"|"$/g, '')
                    console.info(`The document.cookie return cookie is: ${result}`)

                    router.pushUrl({
                      url: 'pages/Index',
                      params: {
                        cookie: result
                      }
                    }, router.RouterMode.Single)
                  } else {
                    promptAction.showToast({
                      message: '请登录后再点击完成'
                    })
                    this.controller.loadUrl(this.mihoyoLogin)
                  }
                })
              })
              .flexShrink(0)
              .margin({ top: 10, bottom: 10 })
          }
          .height('100%')
          .width('100%')
        }
        .height('100%')
        .width('100%')
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

      Text(this.mihoyoLogin)
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