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
import ReliquaryInfo from '../viewmodel/page/GI_MyAvatarDetails/ReliquaryInfo'
import ReliquaryCard from '../view/page/GI_MyAvatarDetails/ReliquaryCard'

interface skill {
  id: number,
  name: string,
  currentLevel: number,
  maxLevel: number
}

const ElementDMGMap = {
  'Pyro': { id: 40, name: '火' },
  'Electro': { id: 41, name: '雷' },
  'Hydro': { id: 42, name: '水' },
  'Dendro': { id: 43, name: '草' },
  'Anemo': { id: 44, name: '风' },
  'Geo': { id: 45, name: '岩' },
  'Cryo': { id: 46, name: '冰' }
}

const AppendProp: Map<string, string> = new Map([
  ['FIGHT_PROP_BASE_ATTACK', '基础攻击力'],
  ['FIGHT_PROP_HP', '生命值'],
  ['FIGHT_PROP_ATTACK', '攻击力'],
  ['FIGHT_PROP_DEFENSE', '防御力'],
  ['FIGHT_PROP_HP_PERCENT', '生命加成'],
  ['FIGHT_PROP_ATTACK_PERCENT', '攻击加成'],
  ['FIGHT_PROP_DEFENSE_PERCENT', '防御加成'],
  ['FIGHT_PROP_CRITICAL', '暴击率'],
  ['FIGHT_PROP_CRITICAL_HURT', '暴击伤害'],
  ['FIGHT_PROP_CHARGE_EFFICIENCY', '元素充能'],
  ['FIGHT_PROP_HEAL_ADD', '治疗加成'],
  ['FIGHT_PROP_ELEMENT_MASTERY', '元素精通'],
  ['FIGHT_PROP_PHYSICAL_ADD_HURT', '物伤加成'],
  ['FIGHT_PROP_FIRE_ADD_HURT', '火伤加成'],
  ['FIGHT_PROP_ELEC_ADD_HURT', '雷伤加成'],
  ['FIGHT_PROP_WATER_ADD_HURT', '水伤加成'],
  ['FIGHT_PROP_WIND_ADD_HURT', '风伤加成'],
  ['FIGHT_PROP_ICE_ADD_HURT', '冰伤加成'],
  ['FIGHT_PROP_ROCK_ADD_HURT', '岩伤加成'],
  ['FIGHT_PROP_GRASS_ADD_HURT', '草伤加成']
])

const propUnit: Map<string, string> = new Map([
  ['FIGHT_PROP_BASE_ATTACK', ''],
  ['FIGHT_PROP_HP', ''],
  ['FIGHT_PROP_ATTACK', ''],
  ['FIGHT_PROP_DEFENSE', ''],
  ['FIGHT_PROP_HP_PERCENT', '%'],
  ['FIGHT_PROP_ATTACK_PERCENT', '%'],
  ['FIGHT_PROP_DEFENSE_PERCENT', '%'],
  ['FIGHT_PROP_CRITICAL', '%'],
  ['FIGHT_PROP_CRITICAL_HURT', '%'],
  ['FIGHT_PROP_CHARGE_EFFICIENCY', '%'],
  ['FIGHT_PROP_HEAL_ADD', '%'],
  ['FIGHT_PROP_ELEMENT_MASTERY', ''],
  ['FIGHT_PROP_PHYSICAL_ADD_HURT', '%'],
  ['FIGHT_PROP_FIRE_ADD_HURT', '%'],
  ['FIGHT_PROP_ELEC_ADD_HURT', '%'],
  ['FIGHT_PROP_WATER_ADD_HURT', '%'],
  ['FIGHT_PROP_WIND_ADD_HURT', '%'],
  ['FIGHT_PROP_ICE_ADD_HURT', '%'],
  ['FIGHT_PROP_ROCK_ADD_HURT', '%'],
  ['FIGHT_PROP_GRASS_ADD_HURT', '%']
])

@Entry
@Component
struct GI_MyAvatarDetails {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State titleHeight: number = 70
  private avatar: Avatar = router.getParams()['avatar']

  @State AvatarImage: string = ''
  @State WeaponImage: string = ''
  @State AvatarWikiInfo: Object = {}
  @State WeaponWikiInfo: Object = {}
  @State loadAvatarWikiInfoDone: boolean = false
  @State TalentInfoList: TalentInfo[] = []
  @State ConstellationInfoList: ConstellationInfo[] = []
  @State ReliquaryInfoList: ReliquaryInfo[] = []

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

  // 加载武器立绘
  async getWeaponImageAsync() {
    try {
      this.WeaponWikiInfo = Utils.losslessJSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/WeaponInfo/${this.avatar.weapon.id}.json`)) as any
      this.WeaponImage = `GI/resource/${this.avatar.weapon.id}/${this.WeaponWikiInfo['icon'].replace('EquipIcon', 'Gacha_WeaponImg')}.webp`
    } catch (err) {
      console.error('load weapon image failed: ' + err.message)
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

  pos2EquipType(pos: number) {
    switch(pos) {
      case 1: return 'EQUIP_BRACER'
      case 2: return 'EQUIP_NECKLACE'
      case 3: return 'EQUIP_SHOES'
      case 4: return 'EQUIP_RING'
      case 5: return 'EQUIP_DRESS'
      default: return ''
    }
  }

  async loadReliquaryList() {
    let reqList: ReliquaryInfo[] = []
    const reliquaries = this.avatar.reliquaries
    let setWikiMap = {}
    for (let req of reliquaries) {
      if (!setWikiMap.hasOwnProperty(req.set)) {
        setWikiMap[`${req.set}`] = Utils.losslessJSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/ReliquaryInfo/${req.set}.json`)) as any
      }
      if (!setWikiMap.hasOwnProperty(req.set)) {
        promptAction.showToast({
          message: '本地资源落后，请及时更新'
        })
        continue
      }
      reqList.push(new ReliquaryInfo(req, setWikiMap[`${req.set}`]['suit'][this.pos2EquipType(req.pos)]?.icon ?? ''))
    }

    this.ReliquaryInfoList = reqList
  }

  async aboutToAppear() {
    console.warn('about to appear')
    await this.getAvatarImageAsync(this.avatar.id, this.avatar.costumeId)
    await this.getWeaponImageAsync()
    await this.loadAvatarWikiInfoAsync()
    this.loadTalentList()
    this.loadConstellationList()
    await this.loadReliquaryList()
  }

  onPageShow() {
    console.warn('page show')
  }

  build() {
    Column() {
      Navigation() {
        Column() {
          List() {
            ListItem() {
              Column({ space: 10 }) {
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
                    .height(450)
                    .margin({ right: 20 })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .padding({ left: 10, right: 10 })

                  Row() {
                    Image($rawfile(`GI/resource/others/star${this.avatar.rarity}.png`))
                      .height(30)
                  }
                  .margin({ top: 470, right: 30 })
                }
                .alignContent(Alignment.TopEnd)
                .width('100%')

                Row() {
                  // 武器面板
                  Column() {
                    Stack() {
                      Image($rawfile(this.WeaponImage))
                        .width('100%')
                        .height(175)
                        .objectFit(ImageFit.Cover)
                      Row() {
                        Image($rawfile(`GI/resource/others/star${this.avatar.weapon.rarity}.png`))
                          .height(16)
                      }
                      .margin({ bottom: 5, right: 5 })
                    }
                    .width('100%')
                    .backgroundColor('#4D000000')
                    .shadow({ color: '#4000001E', radius: 55 })
                    .borderRadius(15)
                    .alignContent(Alignment.BottomEnd)

                    Row() {
                      Column() {
                        Text(this.avatar.weapon.name)
                          .fontSize(16)
                          .fontColor(Color.White)
                        Text(`Lv ${this.avatar.weapon.level}`)
                          .fontSize(16)
                          .fontColor('#B3FFFFFF')
                      }
                      .backgroundColor('#4D000000')
                      .shadow({ color: '#4000001E', radius: 55 })
                      .borderRadius(15)
                      .height('100%')
                      .width('48%')
                      .justifyContent(FlexAlign.SpaceEvenly)

                      Column() {
                        Text('基础攻击力')
                          .fontSize(16)
                          .fontColor('#B3FFFFFF')
                          .maxLines(1)
                        Text(`${this.avatar.weapon.mainStat?.value ?? '???'}`)
                          .fontSize(16)
                          .fontColor(Color.White)
                          .maxLines(1)
                        if (this.avatar.weapon.subStat) {
                          Text(`${AppendProp.get(this.avatar.weapon.subStat?.key) ?? '???'}`)
                            .fontSize(16)
                            .fontColor('#B3FFFFFF')
                            .maxLines(1)
                          Text(`${this.avatar.weapon.subStat?.value + propUnit.get(this.avatar.weapon.subStat.key) ?? '???'}`)
                            .fontSize(16)
                            .fontColor(Color.White)
                            .maxLines(1)
                        } else {
                          Text(`???\n???`)
                            .fontSize(16)
                            .fontColor(Color.White)
                            .maxLines(2)
                        }
                      }
                      .backgroundColor('#4D000000')
                      .shadow({ color: '#4000001E', radius: 55 })
                      .borderRadius(15)
                      .height('100%')
                      .width('48%')
                      .justifyContent(FlexAlign.SpaceEvenly)
                      .alignItems(HorizontalAlign.Start)
                      .padding(8)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .height(96)
                  }
                  .width('48%')
                  .height(280)
                  .justifyContent(FlexAlign.SpaceBetween)
                  // 角色属性面板
                  List() {
                    ListItem() {
                      Row() {
                        Image($rawfile('GI/resource/others/HP.svg'))
                          .width(15)
                          .height(15)
                          .margin({ right: 5 })
                        Text('生命值上限')
                          .fontColor(Color.White)
                          .fontSize(16)

                        Blank()

                        Column() {
                          Text(`${Math.round(this.avatar.prop['2000'])}`)
                            .fontSize(15)
                            .fontColor(Color.White)
                            .fontWeight(FontWeight.Bold)

                          Text() {
                            Span(`${Math.round(this.avatar.prop['1'])}`)
                              .fontSize(12)
                              .fontColor(Color.White)
                            Span(` +${Math.round(this.avatar.prop['2000'] - this.avatar.prop['1'])}`)
                              .fontSize(11)
                              .fontColor('#90e800')
                          }
                          .opacity(0.8)
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.End)
                      }
                      .width('100%')
                      .height(32)
                      .padding({ left: 10, right: 10 })
                    }

                    ListItem() {
                      Row() {
                        Image($rawfile('GI/resource/others/Attack.svg'))
                          .width(15)
                          .height(15)
                          .margin({ right: 5 })
                        Text('攻击力')
                          .fontColor(Color.White)
                          .fontSize(16)

                        Blank()

                        Column() {
                          Text(`${Math.round(this.avatar.prop['2001'])}`)
                            .fontSize(15)
                            .fontColor(Color.White)
                            .fontWeight(FontWeight.Bold)

                          Text() {
                            Span(`${Math.round(this.avatar.prop['4'])}`)
                              .fontSize(12)
                              .fontColor(Color.White)
                            Span(` +${Math.round(this.avatar.prop['2001'] - this.avatar.prop['4'])}`)
                              .fontSize(11)
                              .fontColor('#90e800')
                          }
                          .opacity(0.8)
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.End)
                      }
                      .width('100%')
                      .height(32)
                      .padding({ left: 10, right: 10 })
                    }

                    ListItem() {
                      Row() {
                        Image($rawfile('GI/resource/others/Defence.svg'))
                          .width(15)
                          .height(15)
                          .margin({ right: 5 })
                        Text('防御力')
                          .fontColor(Color.White)
                          .fontSize(16)

                        Blank()

                        Column() {
                          Text(`${Math.round(this.avatar.prop['2002'])}`)
                            .fontSize(15)
                            .fontColor(Color.White)
                            .fontWeight(FontWeight.Bold)

                          Text() {
                            Span(`${Math.round(this.avatar.prop['7'])}`)
                              .fontSize(12)
                              .fontColor(Color.White)
                            Span(` +${Math.round(this.avatar.prop['2002'] - this.avatar.prop['7'])}`)
                              .fontSize(11)
                              .fontColor('#90e800')
                          }
                          .opacity(0.8)
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.End)
                      }
                      .height(32)
                      .width('100%')
                      .padding({ left: 10, right: 10 })
                    }

                    ListItem() {
                      Row() {
                        Image($rawfile('GI/resource/others/EM.svg'))
                          .width(15)
                          .height(15)
                          .margin({ right: 5 })
                        Text('元素精通')
                          .fontColor(Color.White)
                          .fontSize(16)

                        Blank()

                        Column() {
                          Text(`${Math.round(this.avatar.prop['28'])} `)
                            .fontSize(15)
                            .fontColor(Color.White)
                            .fontWeight(FontWeight.Bold)
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.End)
                      }
                      .height(32)
                      .width('100%')
                      .padding({ left: 10, right: 10 })
                    }

                    ListItem() {
                      Row() {
                        Image($rawfile('GI/resource/others/CritRate.svg'))
                          .width(15)
                          .height(15)
                          .margin({ right: 5 })
                        Text('暴击率')
                          .fontColor(Color.White)
                          .fontSize(16)

                        Blank()

                        Column() {
                          Text(`${Math.round(this.avatar.prop['20'] * 1000) / 10}% `)
                            .fontSize(15)
                            .fontColor(Color.White)
                            .fontWeight(FontWeight.Bold)
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.End)
                      }
                      .height(32)
                      .width('100%')
                      .padding({ left: 10, right: 10 })
                    }

                    ListItem() {
                      Row() {
                        Image($rawfile('GI/resource/others/CritDMG.svg'))
                          .width(15)
                          .height(15)
                          .margin({ right: 5 })
                        Text('暴击伤害')
                          .fontColor(Color.White)
                          .fontSize(16)

                        Blank()

                        Column() {
                          Text(`${Math.round(this.avatar.prop['22'] * 1000) / 10}% `)
                            .fontSize(15)
                            .fontColor(Color.White)
                            .fontWeight(FontWeight.Bold)
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.End)
                      }
                      .height(32)
                      .width('100%')
                      .padding({ left: 10, right: 10 })
                    }

                    ListItem() {
                      Row() {
                        Image($rawfile('GI/resource/others/ER.svg'))
                          .width(15)
                          .height(15)
                          .margin({ right: 5 })
                        Text('元素充能效率')
                          .fontColor(Color.White)
                          .fontSize(16)

                        Blank()

                        Column() {
                          Text(`${Math.round(this.avatar.prop['23'] * 1000) / 10}% `)
                            .fontSize(15)
                            .fontColor(Color.White)
                            .fontWeight(FontWeight.Bold)
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.End)
                      }
                      .height(32)
                      .width('100%')
                      .padding({ left: 10, right: 10 })
                    }

                    if (Math.round(this.avatar.prop['30'] * 1000) > 0) {
                      ListItem() {
                        Row() {
                          Image($rawfile('GI/resource/others/Physics.svg'))
                            .width(15)
                            .height(15)
                            .margin({ right: 5 })
                          Text('物理伤害加成')
                            .fontColor(Color.White)
                            .fontSize(16)

                          Blank()

                          Column() {
                            Text(`${Math.round(Math.round(this.avatar.prop['30'] * 1000)) / 10 }% `)
                              .fontSize(15)
                              .fontColor(Color.White)
                              .fontWeight(FontWeight.Bold)
                          }
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.End)
                        }
                        .height(32)
                        .width('100%')
                        .padding({ left: 10, right: 10 })
                      }
                    } else {
                      ListItem() {
                        Row() {
                          Image($rawfile(`GI/resource/others/${this.avatar.element}.svg`))
                            .width(15)
                            .height(15)
                            .margin({ right: 5 })
                          Text(ElementDMGMap[this.avatar.element].name + '元素伤害加成')
                            .fontColor(Color.White)
                            .fontSize(16)

                          Blank()

                          Column() {
                            Text(`${Math.round(this.avatar.prop[`${ElementDMGMap[this.avatar.element].id}`] * 1000) / 10}% `)
                              .fontSize(15)
                              .fontColor(Color.White)
                              .fontWeight(FontWeight.Bold)
                          }
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.End)
                        }
                        .height(32)
                        .width('100%')
                        .padding({ left: 10, right: 10 })
                      }
                    }
                  }
                  .width('48%')
                  .divider({ startMargin: 10, endMargin: 10, strokeWidth: 2 })
                  .backgroundColor('#4D000000')
                  .shadow({ color: '#4000001E', radius: 55 })
                  .borderRadius(15)
                  .padding(5)
                }
                .justifyContent(FlexAlign.SpaceAround)
                .width('95%')

                // 圣遗物
                Row() {
                  GridRow({
                    columns: 15,
                    gutter: { x: 5, y: 5 },
                    direction: GridRowDirection.Row
                  }) {
                    ForEach(this.ReliquaryInfoList, (reliquary: ReliquaryInfo) => {
                      GridCol({ span: { xs: 5, sm: 5, md: 3, lg: 3 } }) {
                        Row() {
                          ReliquaryCard({ reliquary: reliquary })
                        }
                        .width('100%')
                        .padding(5)
                        .justifyContent(FlexAlign.Center)
                      }
                      .borderRadius(8)
                      .clip(true)
                    })
                  }
                  .width('100%')
                }
                .width('95%')
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Center)
            }
          }
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .width('100%')
          .height('100%')
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