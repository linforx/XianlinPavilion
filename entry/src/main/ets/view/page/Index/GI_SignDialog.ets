// 签到弹窗

import GameRole from '../../../model/User/GameRole'
import User from '../../../model/User/User'
import webview from '@ohos.web.webview'
import CoreEnvironment from '../../../common/service/CoreEnvironment'
import SignInJSInterface from '../../../model/Web/Bridge/SignInJSInterface'

class Queue {
  private tasks: any[];
  private processing: boolean;

  constructor() {
    this.tasks = [];
    this.processing = false;
  }

  public enqueue(task: Promise<any>, callback): void {
    this.tasks.push({ task: task, callback: callback });
    if (!this.processing) {
      this.processing = true;
      this.processQueue();
    }
  }

  private async processQueue(): Promise<void> {
    while (this.tasks.length > 0) {
      const task = this.tasks.shift();
      if (task) {
        let res = await task.task
        task.callback(res)
      }
    }
    this.processing = false;
  }
}

@CustomDialog
export default struct GI_SignDialog {
  @Link role: GameRole
  @Link user: User
  @State url: string = ''
  @State progress: number = 0;
  @State hideProgress: Visibility = Visibility.None;
  webview_controller: WebviewController = new webview.WebviewController()
  ports: webview.WebMessagePort[]
  private loadDone: boolean = false
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  taskQueue: Queue = new Queue()

  aboutToAppear() {
    this.url = `https://webstatic.mihoyo.com/bbs/event/signin-ys/index.html?act_id=e202009291139501`
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
    this.webview_controller.runJavaScript(script)
  }

  isLastDigitGreaterThanTwo(input: string): boolean {
    const regex = /\d+$/; // 匹配字符串末尾的数字
    const lastDigit = input.match(regex)?.[0]; // 获取匹配到的数字
    if (lastDigit) {
      const lastNumber = parseInt(lastDigit); // 转换为数字类型
      return lastNumber > 2;
    }
    return false;
  }

  registerHtmlEtsMessagePorts() {
    this.webview_controller.runJavaScript(htmlScripts)
      .then(() => {
        this.webview_controller.runJavaScript(`window.MiHoYoJSInterface = { postMessage: function(data) { if (h5Port) { h5Port.postMessage(data); } else { console.error('h5Port is null, Please initialize first'); } },closePage: function() { this.postMessage('{"method":"closePage"}') } };`)
      })
    // 1、创建两个消息端口。
    this.ports = this.webview_controller.createWebMessagePorts();
    // 2、在应用侧的消息端口(如端口1)上注册回调事件。
    this.ports[1].onMessageEvent((result: webview.WebMessage) => {
      let msg = 'Got msg from HTML:';
      if (typeof(result) === 'string') {
        console.info(`received string message from html5, string is: ${result}`);
        msg = msg + result;
        let jsParams = JSON.parse(result.trim())
        this.taskQueue.enqueue(SignInJSInterface.getJsResultFromJsParamAsync(jsParams), result => {
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
    this.webview_controller.postMessage('__init_port__', [this.ports[0]], '*');
  }

  executeCallbackScript(callback: string, payload?: string) {
    if (!callback) return ''
    let js = payload ? `mhyWebBridge("${callback}",${payload})` : `mhyWebBridge("${callback}")`
    console.warn('ExecuteScript: ' + js)
    this.webview_controller.runJavaScript(js)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Web({ src: this.url, controller: this.webview_controller })
          .height(415)
          .zoomAccess(true)
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .geolocationAccess(true)
          .userAgent(CoreEnvironment.miHoYoBBSUserAgent)
          .onConsole(event => {
            console.warn('web console: ' + event.message.getMessage())
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
                // 初始化Web客户端Cookie
                console.warn('set cookie')
                let domain = '.mihoyo.com'
                webview.WebCookieManager.putAcceptCookieEnabled(true)
                webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(true)

                this.setCookie('account_id', this.user.cookie.getByName('account_id'), domain)
                this.setCookie('cookie_token', this.user.cookie.getByName('cookie_token'), domain)
                this.setCookie('ltuid', this.user.cookie.getByName('ltuid'), domain)
                this.setCookie('ltoken', this.user.cookie.getByName('ltoken'), domain)

                console.warn('set cookie done')
              } catch (error) {
                console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
              }

              console.warn('navigate to: ' + this.url)
              this.webview_controller.loadUrl(this.url)
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
    .backgroundColor($r('app.color.page_background_color'))
    .width('88%')
    .constraintSize({ maxWidth: 350, maxHeight: 415 })
    .borderRadius(20)
    .clip(true)
  }
}

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