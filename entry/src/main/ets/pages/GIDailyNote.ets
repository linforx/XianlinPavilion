import PageBackButton from '../view/PageBackButton';
import webview from '@ohos.web.webview';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import User from '../model/User/User';
import CoreEnvironment from '../common/service/CoreEnvironment'
import MihoyoJSInterface from '../model/Web/Bridge/MihoyoJSInterface'
import GameRole from '../model/User/GameRole';

const htmlScripts: string = "" +
"var h5Port;" +
"var output = document.querySelector(\'.output\');" +
"window.addEventListener(\'message\', function (event) {" +
"    if (event.data === \'__init_port__\') {" +
"        console.warn('init port');" +
"        if (event.ports[0] !== null) {" +
"            h5Port = event.ports[0];" +
"            h5Port.onmessage = function (event) {" +
"              var msg = \'Got message from ets:\';" +
"              var result = event.data;" +
"              if (typeof(result) === \'string\') {" +
"                console.info(`received string message from html5, string is: ${result}`);" +
"                msg = msg + result;" +
"              } else if (typeof(result) === \'object\') {" +
"                if (result instanceof ArrayBuffer) {" +
"                  console.info(`received arraybuffer from html5, length is: ${result.byteLength}`);" +
"                  msg = msg + \'lenght is \' + result.byteLength;" +
"                } else {" +
"                  console.info(\'not support\');" +
"                }" +
"              } else {" +
"                console.info(\'not support\');" +
"              }" +
"            }" +
"        }" +
"        console.warn('init port done');" +
"    }" +
"})"

@Entry
@Component
struct GIDailyNote {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State url: string = 'Hello World'
  @State progress: number = 0;
  @State hideProgress: Visibility = Visibility.None;
  @State titleHeight: number = 60
  controller: WebviewController = new webview.WebviewController()
  ports: webview.WebMessagePort[]
  private user: User = null
  private role: GameRole = null

  private loadDone: boolean = false

  aboutToAppear() {
    this.user = globalThis.SelUser as User
    this.role = globalThis.SelGIRole as GameRole
    let query = `role_id=${this.role.gameUid}&server=${this.role.region}`
    this.url = `https://webstatic.mihoyo.com/app/community-game-records/index.html?bbs_presentation_style=fullscreen#/ys/daily/?${query}`
    // 初始化Web客户端Cookie
  }

  setCookie(name: string, value: string, domain?: string, expires: number = 1, path: string = '/') {
    let cookie = name + "=" + encodeURIComponent(value);

    if (expires) {
      var date = new Date();
      date.setDate(date.getDate() + expires);
      cookie += "; expires=" + date.toUTCString();
    }

    if (path) {
      cookie += "; path=" + path;
    }

    if (domain) {
      cookie += "; domain=" + domain;
    }

    let script = `document.cookie='${cookie}'`
    console.warn('run js: ' + script)
    this.controller.runJavaScript(script)
      .then(value => {
        console.log('script result: ' + value)
      })
  }

  registerHtmlEtsMessagePorts() {
    this.controller.runJavaScript(htmlScripts)
      .then(() => {
        this.controller.runJavaScript(`window.MiHoYoJSInterface = { postMessage: function(data) { if (h5Port) { h5Port.postMessage(data); } else { console.error('h5Port is null, Please initialize first'); } },closePage: function() { this.postMessage('{"method":"closePage"}') } };`)
      })
    // 1、创建两个消息端口。
    this.ports = this.controller.createWebMessagePorts();
    // 2、在应用侧的消息端口(如端口1)上注册回调事件。
    this.ports[1].onMessageEvent((result: webview.WebMessage) => {
      let msg = 'Got msg from HTML:';
      if (typeof(result) === 'string') {
        console.info(`received string message from html5, string is: ${result}`);
        msg = msg + result;
        let jsParams = JSON.parse(result.trim())
        MihoyoJSInterface.getJsResultFromJsParamAsync(jsParams).then(result => {
          if (result != null && jsParams.callback != null) {
            this.executeCallbackScript(jsParams.callback, JSON.stringify(result))
          }
        })
      } else if (typeof(result) === 'object') {
        if (result instanceof ArrayBuffer) {
          console.info(`received arraybuffer from html5, length is: ${result.byteLength}`);
          msg = msg + 'lenght is ' + result.byteLength;
        } else {
          console.info('not support');
        }
      } else {
        console.info('not support');
      }
    })
    // 3、将另一个消息端口(如端口0)发送到HTML侧，由HTML侧保存并使用。
    this.controller.postMessage('__init_port__', [this.ports[0]], '*');
  }

  executeCallbackScript(callback: string, payload?: string) {
    if (!callback) return ''
    let js = payload ? `mhyWebBridge("${callback}",${payload})` : `mhyWebBridge("${callback}")`
    console.warn('ExecuteScript: ' + js)
    this.controller.runJavaScript(js)
  }

  build() {
    Column() {
      Navigation() {
        Stack({ alignContent: Alignment.Top }) {
          Web({ src: this.url, controller: this.controller })
            .zoomAccess(true)
            .domStorageAccess(true)
            .javaScriptAccess(true)
            .geolocationAccess(true)
            .userAgent(CoreEnvironment.miHoYoBBSUserAgent)
            .onConsole(event => {
              console.warn('web console: ' + event.message)
              return false
            })
            .onProgressChange(event =>{
              this.progress = event.newProgress
            })
            .onPageBegin(() => {
              this.hideProgress = Visibility.Visible
              if (!this.loadDone) {
                this.loadDone = true

                try {
                  console.warn('set cookie')
                  let domain = '.mihoyo.com'
                  webview.WebCookieManager.putAcceptCookieEnabled(true)
                  webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(true)

                  this.setCookie('account_id', this.user.cookie.getByName('account_id'), domain)
                  this.setCookie('cookie_token', this.user.cookie.getByName('cookie_token'), domain)
                  this.setCookie('ltuid', this.user.cookie.getByName('ltuid'), domain)
                  this.setCookie('ltoken', this.user.cookie.getByName('ltoken'), domain)

                  console.warn('set cookie done')
                  console.warn('.mihoyo.com: ' + webview.WebCookieManager.getCookie('.mihoyo.com'))

                } catch (error) {
                  console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
                }

                console.warn('navigate to: ' + this.url)
                this.controller.loadUrl(this.url)
              }

              // 初始化Web客户端接口通信
              try {
                this.registerHtmlEtsMessagePorts()
              } catch (error) {
                console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
              }
            })
            .onPageEnd(() => {
              this.hideProgress = Visibility.None
              console.warn('.mihoyo.com: ' + webview.WebCookieManager.getCookie('.mihoyo.com'))
            })
          Progress({ value: this.progress, total: 100 })
            .color('#0000ff')
            .visibility(this.hideProgress)
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

      Text(this.url)
        .fontSize(16)
        .fontColor($r('app.color.text_color'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)

      Blank()
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .width('100%')
    .padding(8)
  }
}