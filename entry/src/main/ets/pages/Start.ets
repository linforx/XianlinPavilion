import bundleManager from '@ohos.bundle.bundleManager';
import router from '@ohos.router';
import MihoyoAPI from '../model/ServiceProvider/MihoyoAPI';
import User from '../model/User/User';

@Entry
@Component
struct Page {
  @State message: string = 'Hello World'

  async getSelUserAsync() {
    return User.createDefaultAccount()
  }

  async aboutToAppear() {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    globalThis.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleFlags)
    router.pushUrl({
      url: 'pages/Index'
    })

    let userList: User[] = [User.createDefaultAccount()]

    globalThis.selAccountUid = '253237280'
    globalThis.userList = userList
    router.pushUrl({
      url: 'pages/Index'
    })
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}