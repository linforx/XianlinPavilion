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
import FileManager from '../common/utils/FileManager'
import Avatar from '../model/Game/GenshinImpact/Avatar'
import Weapon from '../model/Game/GenshinImpact/Weapon'
import Reliquary from '../model/Game/GenshinImpact/Reliquary'
import Utils, { losslessJSON } from '../common/utils/Utils'
import fs from '@ohos.file.fs'
import WeaponBriefInfo from '../viewmodel/page/GI_MyAvatars/WeaponBriefInfo'

@Entry
@Component
struct GI_MyAvatars {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private user: User = null
  private role: GameRole = null
  private fileManager: FileManager = new FileManager(this.context)
  @State isRefreshing: boolean = false
  @State titleHeight: number = 70
  @State avatarList: AvatarBriefInfo[] = []
  private avatarMap: {} = {}

  @State totalNum: number = 0
  @State loadedNum: number = 0
  @State isLoadingData: boolean = false

  aboutToAppear() {
    this.user = globalThis.SelUser as User
    this.role = globalThis.SelGIRole as GameRole
    if (!this.role || !this.user) {
      promptAction.showToast({
        message: '请绑定角色'
      })
      router.back()
    }

    try {
      this.fileManager.mkdir(`/data/GI/${this.user.uid}`)
    } catch (err) {
      if (err.code != 13900015) {
        console.error('code: ' + err.code)
      }
    }
    try {
      this.fileManager.mkdir(`/data/GI/${this.user.uid}/${this.role.gameUid}`)
    } catch (err) {
      if (err.code != 13900015) {
        console.error('code: ' + err.code)
      }
    }
    try {
      this.fileManager.mkdir(`/data/GI/${this.user.uid}/${this.role.gameUid}/avatars`)
    } catch (err) {
      if (err.code != 13900015) {
        console.error('code: ' + err.code)
      }
    }

    this.getDataFromLocalFileAsync()
      .then(async (avatarList) => {
        console.warn('read file done')
        await this.bindingDataAsync(avatarList)
      })
  }

  // 将获取的角色信息数据格式化并绑定到UI类
  async bindingDataAsync(avatarList: Avatar[]) {
    console.warn('binding data')
    let newAvatarInfoList: AvatarBriefInfo[] = []
    for (let avatar of avatarList) {
      try {
        this.avatarMap[`${avatar.id}`] = avatar
        let weaponInfo = Utils.losslessJSON.parse(await this.fileManager.getRawFileTextAsync(`GI/WeaponInfo/${avatar.weapon.id}.json`)) as any
        let avatarInfo = Utils.losslessJSON.parse(await this.fileManager.getRawFileTextAsync(`GI/AvatarInfo/${(avatar.id == 10000005 || avatar.id == 10000007) ? avatar.id + '-' + avatar.element.toLowerCase() : avatar.id}.json`)) as any
        let weaponBriefInfo = new WeaponBriefInfo(
          avatar.weapon.id,
          avatar.weapon.name,
          weaponInfo.type,
          avatar.weapon.rarity,
          weaponInfo.icon,
          avatar.weapon.level,
          avatar.weapon.affixLevel
        )
        newAvatarInfoList.push(new AvatarBriefInfo(
          avatar.id,
          avatar.name,
          avatar.element,
          avatar.rarity,
          avatarInfo.icon,
          avatar.level,
          avatar.actived_constellation_num,
          weaponBriefInfo
        ))
      } catch (err) {
        console.error(err)
        promptAction.showToast({
          message: err
        })
      }
      this.loadedNum++
    }
    this.isLoadingData = false
    console.warn('binding data done')
    this.avatarList = newAvatarInfoList
  }

  // 从云端同步数据并保存
  async updateAndSaveDataAsync() {
    this.isRefreshing = true
    let mihoyoData = await this.getDataFromMihoyoServerAsync()
    let avatarList = await this.localizeDataAsync(mihoyoData, null)

    console.log(`共${avatarList.length}个角色`)

    this.saveData(avatarList)
    this.isRefreshing = false

    avatarList = await this.getDataFromLocalFileAsync()
    console.warn('read file done')
    await this.bindingDataAsync(avatarList)
  }

  // 从米哈游服务器获取角色信息
  async getDataFromMihoyoServerAsync() {
    console.warn('getDataFromMihoyoServerAsync')
    try {
      var res = await new GenshinAPI()
        .applyCharacter(this.role.gameUid, this.role.region)
        .setCookie(this.user.cookie.getByType(CookieType.BothCLToken))
        .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
        .getResponseAsync()
    } catch (err) {
      promptAction.showToast({
        message: '碰到了一些错误: ' + res.message
      })
      return null
    }
    console.warn('getDataFromMihoyoServerAsync done')

    return res.data ? JSON.parse(res.data) : null
  }

  // 从恩卡服务获取角色展柜公布的角色信息
  async getDataFromEnkaServerAsync() {}

  // 从本地文件读取角色信息
  async getDataFromLocalFileAsync() {
    let options = {
      recursion: false,
      listNum: 0,
      filter: {
        suffix: ['.json'],                        // 匹配文件后缀名为'.json'
        fileSizeOver: 0,                           // 匹配文件大小大于等于0
        lastModifiedAfter: new Date(0).getTime(),  // 匹配文件最近修改时间在1970年1月1日之后
      },
    }
    let path = `/data/GI/${this.user.uid}/${this.role.gameUid}/avatars`
    let fileList = this.fileManager.getFileList(path, options)
    console.warn('共' + fileList.length + '个数据文件')
    this.totalNum = fileList.length
    this.loadedNum = 0
    this.isLoadingData = true

    let avatarList: Avatar[] = []

    for (let name of fileList) {
      try {
        let text = this.fileManager.readText(`${path}/${name}`)
        let json = losslessJSON.parse(text) as any

        let reliquaries: Reliquary[] = []
        for (let reliquary of json.reliquaries) {
          reliquaries.push(new Reliquary(
            reliquary.id,
            reliquary.name,
            reliquary.pos,
            reliquary.rarity,
            reliquary.level,
            reliquary.set,
            reliquary.mainStat,
            reliquary.subStats
          ))
        }

        let weapon = new Weapon(
          json.weapon.id,
          json.weapon.name,
          json.weapon.rarity,
          json.weapon.level,
          json.weapon.affixLevel,
          json.weapon.mainStat,
          json.weapon.subStat
        )

        let avatar = new Avatar(
          json.id,
          json.name,
          json.rarity,
          json.element,
          json.level,
          json.fetter,
          json.actived_constellation_num,
          json.costumeId,
          weapon,
          json.prop,
          reliquaries
        )
        avatarList.push(avatar)
      } catch (err) {
        console.error('读取数据文件' + name + '错误: ' + err.message)
        promptAction.showToast({
          message: '读取数据文件' + name + '错误: ' + err.message
        })
      }
    }

    return avatarList
  }

  // 将网络数据本地化
  async localizeDataAsync(mihoyoData?, enkaData?) {
    let avatars: Avatar[] = []

    if (enkaData) {}
    if (mihoyoData) {
      for (let item of mihoyoData['avatars']) {
        let reliquaryList: Reliquary[] = []
        for (let reliquary of item.reliquaries) {
          let { id, name, pos, rarity, level } = reliquary
          let setName = reliquary.set.name
          let setId = 0
          let reliquaryWikiMap = Utils.losslessJSON.parse(await this.fileManager.getRawFileTextAsync('GI/reliquary_list.json'))['items']
          for (let key in reliquaryWikiMap) {
            if (reliquaryWikiMap[key].name == setName) {
              setId = reliquaryWikiMap[key].id
            }
          }
          if (!setId) {
            promptAction.showToast({
              message: '本地资源版本滞后'
            })
            continue
          }

          let reliquaryWikiInfo = Utils.losslessJSON.parse(await this.fileManager.getRawFileTextAsync(`GI/ReliquaryInfo/${setId}.json`)) as any
          id = reliquaryWikiInfo.id

          reliquaryList.push(new Reliquary(id, name, pos, rarity, level, setId))
        }

        avatars.push(new Avatar(
          item.id,
          item.name,
          item.rarity,
          item.element,
          item.level,
          item.fetter,
          item.actived_constellation_num,
          0,
          new Weapon(item.weapon.id, item.weapon.name, item.weapon.rarity, item.weapon.level, item.weapon.affix_level),
          null,
          reliquaryList
        ))
      }
    }

    return avatars
  }

  // 保存角色信息
  saveData(avatarList: Avatar[]) {
    for (let avatar of avatarList) {
      try {
        let path = `/data/GI/${this.user.uid}/${this.role.gameUid}/avatars/${avatar.id}.json`
        this.fileManager.createFile(path)
        let file = this.fileManager.openFile(path, fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC)

        let content = Utils.losslessJSON.stringify(avatar.toJSON())
        this.fileManager.writeText(file, content)

        this.fileManager.closeFile(file)
      } catch (err) {
        if (err.code != 13900015) {
          console.error('code: ' + err.code)
          promptAction.showToast({
            message: '保存角色时碰到错误: ' + err
          })
          return
        }
      }
    }
  }

  build() {
    Column() {
      Navigation() {
        if (this.isLoadingData) {
          Column({ space: 10 }) {
            Text('数据加载中')
              .fontSize(18)
              .fontColor($r('app.color.text_color'))
            Progress({ value: this.loadedNum, total: this.totalNum, type: ProgressType.Linear })
              .value(this.loadedNum)
              .width(200)
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        else {
          Refresh({ refreshing: $$this.isRefreshing, offset: 16 }) {
            Scroll() {
              Column() {
                GridRow({
                  columns: 12,
                  gutter: { x: 5, y: 20 },
                  direction: GridRowDirection.Row
                }) {
                  ForEach(this.avatarList, (avatar: AvatarBriefInfo) => {
                    GridCol({ span: { xs: 6, sm: 4, md: 2, lg: 2 } }) {
                      Row() {
                        AvatarCard({ avatar: avatar })
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.Center)
                    }
                    .borderRadius(8)
                    .clip(true)
                  })
                }
                .width('100%')
              }
              .justifyContent(FlexAlign.Start)
              .padding(8)
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
          }
          .onRefreshing(() => {
            this.updateAndSaveDataAsync()
          })
        }
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

      if (this.isRefreshing) {
        Text('（正在同步）`')
          .fontSize(24)
          .fontColor($r('app.color.sub_text_color'))
      }

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