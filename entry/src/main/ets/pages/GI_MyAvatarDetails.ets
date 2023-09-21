import router from '@ohos.router'
import Avatar from '../model/Game/GenshinImpact/Avatar'
import PageBackButton from '../view/PageBackButton'
import AvatarBriefInfo from '../viewmodel/page/GI_MyAvatars/AvatarBriefInfo'
import common from '@ohos.app.ability.common'
import Reliquary from '../model/Game/GenshinImpact/Reliquary'
import EnkaAPI from '../model/ServiceProvider/EnkaAPI'
import promptAction from '@ohos.promptAction'
import FileManager from '../common/utils/FileManager'
import Utils from '../common/utils/Utils'
import TalentInfoViewer from '../view/page/GI_MyAvatarDetails/TalentInfoViewer'
import TalentInfo from '../viewmodel/page/GI_MyAvatarDetails/TalentInfo'
import ConstellationInfo from '../viewmodel/page/GI_MyAvatarDetails/ConstellationInfo'
import ConstellationInfoViewer from '../view/page/GI_MyAvatarDetails/ContellationInfoViewer'

interface skill {
  id: number,
  name: string,
  currentLevel: number,
  maxLevel: number
}

@Entry
@Component
struct GI_MyAvatarDetails {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State titleHeight: number = 70
  private avatar: Avatar = router.getParams()['avatar']

  @State AvatarImage: string = ''
  @State AvatarWikiInfo: Object = {}
  @State loadAvatarWikiInfoDone: boolean = false
  @State TalentInfoList: TalentInfo[] = []
  @State ConstellationInfoList: ConstellationInfo[] = []

  // 加载角色/皮肤立绘
  async getAvatarImageAsync(avatarId: number, costumeId: number) {
    console.warn(`avatarId: ${avatarId}`)
    try {
      if (costumeId) {
        let characters = await EnkaAPI.getCharactersMapAsync(this.context)
        console.warn('read characters done')
        if (!characters[`${avatarId}`]['Costumes'] || !characters[`${avatarId}`]['Costumes'][`${costumeId}`]) {
          promptAction.showToast({
            message: '本地资源版本落后，请及时更新'
          })
          console.error('本地资源版本落后，请及时更新')
        }
        this.AvatarImage = `costumes/${this.avatar.costumeId}/${characters[`${avatarId}`]['Costumes'][`${costumeId}`]['art']}.webp`
      }
      else {
        let avatarInfo = Utils.losslessJSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/AvatarInfo/${(this.avatar.id == 10000005 || this.avatar.id == 10000007) ? this.avatar.id + '-' + this.avatar.element.toLowerCase() : this.avatar.id}.json`)) as any
        this.AvatarImage = avatarInfo.icon.replace('AvatarIcon', 'Gacha_AvatarImg') + '.webp'
      }
      console.warn(this.AvatarImage)
    } catch (err) {
      console.error('load avatar image failed: ' + err.message)
    }
  }

  // 加载角色百科信息
  async loadAvatarWikiInfoAsync() {
    this.AvatarWikiInfo = Utils.losslessJSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/AvatarInfo/${(this.avatar.id == 10000005 || this.avatar.id == 10000007) ? this.avatar.id + '-' + this.avatar.element.toLowerCase() : this.avatar.id}.json`)) as any
  }

  // 根据角色激活的命座来调整技能的等级
  judgeSkillLevelByConstellationNum(talents: Array<TalentInfo>) {
    for (let index in this.AvatarWikiInfo['constellation']) {
      if (parseInt(index) >= this.avatar.actived_constellation_num) break

      if ((this.AvatarWikiInfo['constellation'][index]['description'] as string).includes('技能等级提高3级')) {
        for (let i = 0; i < talents.length; ++i) {
          if ((this.AvatarWikiInfo['constellation'][index]['description'] as string).includes(talents[i].name)) {
            talents[i].extraUpgrade = true
          }
        }
      }
    }

    return talents
  }

  getUpgradableSkill() {
    let duplicatedTalentList = []
    for (let skill of this.avatar.skillList) {
      for (let index in this.AvatarWikiInfo['talent']) {
        let talent = this.AvatarWikiInfo['talent'][index]
        if (skill.name == talent.name) {
          duplicatedTalentList.push({
            skill: skill,
            wiki: talent
          })
        }
      }
    }

    return duplicatedTalentList
  }

  // 获取不可升级的技能
  getNonUpgradableSkill() {
    let nonDuplicatedTalentList = []
    for (let skill of this.avatar.skillList) {
      for (let index in this.AvatarWikiInfo['talent']) {
        let talent = this.AvatarWikiInfo['talent'][index]
        if (skill.name == talent.name) {
          continue
        }
        nonDuplicatedTalentList.push(talent)
      }
    }

    return nonDuplicatedTalentList
  }

  loadTalentList() {
    let talentList: TalentInfo[] = []
    let skills = this.getUpgradableSkill()
    for (let item of skills) {
      talentList.push(new TalentInfo(item.skill.name,
        `GI/resource/${(this.avatar.id == 10000005 || this.avatar.id == 10000007) ? this.avatar.id + '-' + this.avatar.element.toLowerCase() : this.avatar.id}/${item.wiki.icon}.webp`,
        item.skill.currentLevel,
        item.skill.maxLevel,
        item.wiki
      ))
    }

    this.TalentInfoList = this.judgeSkillLevelByConstellationNum(talentList)
  }

  loadConstellationList() {
    let conList: ConstellationInfo[] = []
    let cons = this.AvatarWikiInfo['constellation']
    for (let key in cons) {
      let con = cons[key]
      conList.push(new ConstellationInfo(con.name,
        `GI/resource/${(this.avatar.id == 10000005 || this.avatar.id == 10000007) ? this.avatar.id + '-' + this.avatar.element.toLowerCase() : this.avatar.id}/${con.icon}.webp`,
        con.description,
        parseInt(key) + 1
      ))
    }

    this.ConstellationInfoList = conList.sort((a, b) => { return a.index - b.index })
  }

  async aboutToAppear() {
    console.warn('about to appear')
    await this.getAvatarImageAsync(this.avatar.id, this.avatar.costumeId)
    await this.loadAvatarWikiInfoAsync()
    this.loadTalentList()
    this.loadConstellationList()
  }

  onPageShow() {
    console.warn('page show')
  }

  build() {
    Column() {
      Navigation() {
        Column() {
          Scroll() {
            Column() {
              Stack() {
                Image($rawfile(`GI/resource/${(this.avatar.id == 10000005 || this.avatar.id == 10000007) ? this.avatar.id + '-' + this.avatar.element.toLowerCase() : this.avatar.id}/${this.AvatarImage}`))
                  .width('100%')
                  .height(500)
                  .objectFit(ImageFit.Cover)
                  .alt($r('app.media.ic_gallery_list_damage'))


                Row() {
                  // 天赋展示
                  Column() {
                    ForEach(this.TalentInfoList, talentInfo => {
                      TalentInfoViewer({ info: talentInfo, element: this.avatar.element })
                    })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.SpaceEvenly)
                  .height(300)
                  .margin({ left: 20 })

                  // 命座展示
                  Column() {
                    ForEach(this.ConstellationInfoList, (con: ConstellationInfo) => {
                      ConstellationInfoViewer({ info: con, element: this.avatar.element })
                        .opacity(con.index <= this.avatar.actived_constellation_num ? 1 : 0.3)
                    })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.SpaceEvenly)
                  .height(500)
                  .margin({ right: 20 })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)
                .padding({ left: 10, right: 10 })
              }
              .alignContent(Alignment.TopStart)
              .width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)
          }
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .width('100%')
          .constraintSize({ maxHeight: '100%' })
        }
        .height('100%')
        .width('100%')
        .backgroundImage($rawfile(`GI/resource/others/ElementalBGI/bg-${this.avatar.element}.png`))
        .backgroundImageSize(ImageSize.Cover)
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

      Text(this.avatar.name)
        .fontSize(24)
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