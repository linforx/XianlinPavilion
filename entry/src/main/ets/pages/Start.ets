import bundleManager from '@ohos.bundle.bundleManager';
import router from '@ohos.router';
import User from '../model/User/User';
import appSetting from '../common/preference/appSetting'
import { DatabaseHelper, getDBHelper } from '../common/database/DatabaseHelper'
import common from '@ohos.app.ability.common';
import FileManager from '../common/utils/FileManager'
import font from '@ohos.font';

@Entry
@Component
struct Page {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State message: string = 'Hello World'
  private fileManager: FileManager = new FileManager(this.context)

  async aboutToAppear() {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    globalThis.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleFlags)
    this.message = '初始化应用沙箱...'
    try {
      this.fileManager.mkdir(`/config`)
      console.info('success make /config')
    } catch (err) {
      if (err.code != 13900015) {
        console.error('code: ' + err.code)
      }
    }

    try {
      this.fileManager.mkdir('/data')
      console.info('success make /data')
    } catch (err) {
      if (err.code != 13900015) {
        console.error('code: ' + err.code)
      }
    }

    try {
      this.fileManager.mkdir('/data/GI')
      console.info('success make /data/GI')
    } catch (err) {
      if (err.code != 13900015) {
        console.error('code: ' + err.code)
      }
    }

    try {
      this.fileManager.mkdir('/data/HSR')
      console.info('success make /data/HSR')
    } catch (err) {
      if (err.code != 13900015) {
        console.error('code: ' + err.code)
      }
    }


    this.message = '初始化字体...'
    try {
      console.warn('注册HarmonyOS_Sans_Medium.ttf')
      font.registerFont({
        familyName: 'Medium',
        familySrc: '/font/HarmonyOS_Sans_Medium.ttf'
      })
      console.warn('注册HYWenHei-55W.ttf')
      font.registerFont({
        familyName: 'HYWenHei',
        familySrc: '/font/HYWenHei-55W.ttf'
      })
      console.warn('注册tttgbnumber.ttf')
      font.registerFont({
        familyName: 'GBNumber',
        familySrc: '/font/tttgbnumber.ttf'
      })
    } catch (err) {
      console.error('register font failed with err: ' + err.message)
    }


    let DBHelper = getDBHelper(this.context)
    this.message = '初始化数据库...'
    await DBHelper.initStorageAsync()
    this.message = '初始化配置...'
    await appSetting.initAsync(this.context)
    globalThis.selAccountUid = ''
    if (await appSetting.hasAsync('selAccountUid')) {
      globalThis.selAccountUid = await appSetting.getAsync('selAccountUid')
    }
    console.warn('selAccountUid: ' + globalThis.selAccountUid)
    if (await appSetting.hasAsync('selGIRoleUid')) {
      globalThis.selGIRoleUid = await appSetting.getAsync('selGIRoleUid')
    }
    if (await appSetting.hasAsync('selHSRRoleUid')) {
      globalThis.selHSRRoleUid = await appSetting.getAsync('selHSRRoleUid')
    }

    router.pushUrl({
      url: 'pages/Index'
    })

    let userList: User[] = []

    globalThis.userList = userList
    router.pushUrl({
      url: 'pages/Index'
    })
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(24)
          .fontColor($r('app.color.text_color'))
      }
      .width('100%')
    }
    .height('100%')
  }
}