import router from '@ohos.router'
import PageBackButton from '../../view/PageBackButton'
import common from '@ohos.app.ability.common'
import FileManager from '../../common/utils/FileManager'
import TalentCard from '../../view/page/GenshinImpact/RoleWikiDetails/TalentCard'

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
struct GI_WeaponWikiDetails {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private weaponCurve: Object = null
  private manualWeapon: Object = null
  private weaponStory: string = ''
  private materials: Object = null
  private promote: boolean = true
  @State weaponWiki: Object = {}
  @State loadWikiDone: boolean = false
  @State titleHeight: number = 70
  @State title: string = '武器图鉴'
  @State weaponId: string = router.getParams()['weaponId']
  @State currentIndex: number = 0
  @State level: number = 90
  @State affixLevel: number = 1
  @State propList: {}[] = []
  @State cost: {}[] = []

  async loadWeaponWikiInfo() {
    this.weaponWiki = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/WeaponInfo/${this.weaponId}.json`)) as any
  }

  async loadWeaponCurve() {
    this.weaponCurve = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/weapon_curve.json`)) as any
  }

  async loadManualWeapon() {
    this.manualWeapon = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/manual_weapon.json`)) as any
  }

  async loadMaterials() {
    this.materials = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/material_list.json`)) as any
  }

  async loadWeaponStory() {
    this.weaponStory = await new FileManager(this.context).getRawFileTextAsync(`GI/WeaponStory/${this.weaponId}.txt`)
  }

  calcProp() {
    let result = { prop: {}, cost: {} }
    let level: number = this.level      // 暂存level
    let isPromoted: boolean = this.promote

    for (let index = 0; index < this.weaponWiki['upgrade']['promote'].length; ++index) {
      let item = this.weaponWiki['upgrade']['promote'][index]
      // 等级不够上限、不选择突破、已经突破到了最后一个阶段，退出计算
      if (item.unlockMaxLevel > level || item.unlockMaxLevel === level && !isPromoted || index === this.weaponWiki['upgrade']['promote'].length - 1) break;
      if (item.unlockMaxLevel === level && isPromoted) {
        // 计算突破后的数值
        let nextItem = this.weaponWiki['upgrade']['promote'][index + 1]
        for (let key in nextItem.addProps) {
          if (nextItem.addProps[key]) result.prop[key] = nextItem.addProps[key]
        }
        for (let key in nextItem.costItems) {
          result.cost[key] = result.cost[key] ?? 0
          result.cost[key] += nextItem.costItems[key]
        }

        break
      }
      if (item.unlockMaxLevel < level) {
        let nextItem = this.weaponWiki['upgrade']['promote'][index + 1]
        for (let key in nextItem.addProps) {
          if (nextItem.addProps[key]) result.prop[key] = nextItem.addProps[key]
        }
        for (let key in nextItem.costItems) {
          result.cost[key] = result.cost[key] ?? 0
          result.cost[key] += nextItem.costItems[key]
        }
      }
    }

    let propList: {}[] = []
    for (let item of this.weaponWiki['upgrade']['prop']) {
      result.prop[item.propType] = result.prop[item.propType] ?? 0
      result.prop[item.propType] += item.initValue * this.weaponCurve[`${level}`]['curveInfos'][item.type]
      propList.push({
        key: item.propType,
        value: result.prop[item.propType]
      })
      delete result.prop[item.propType]
    }
    for (let key in result.prop) {
      propList.push({
        key: key,
        value: result.prop[key]
      })
    }

    let costList: {}[] = []
    for (let key in result.cost) {
      costList.push({
        id: key,
        count: result.cost[key]
      })
    }

    this.propList = propList
    this.cost = costList
  }

  async aboutToAppear() {
    this.loadWikiDone = false
    try {
      await this.loadManualWeapon()
      await this.loadWeaponCurve()
      await this.loadMaterials()
      await this.loadWeaponWikiInfo()
      await this.loadWeaponStory()
      this.title = this.weaponWiki['name']
      this.calcProp()
    } catch (err) {
      console.error(JSON.stringify(err))
    }
    this.loadWikiDone = true
  }

  build() {
    Column() {
      Navigation() {
        if (this.loadWikiDone) {
          List() {
            // 立绘
            ListItem() {
              Row() {
                Column() {
                  Stack() {
                    Image($rawfile(`GI/resource/${this.weaponId}/${this.weaponWiki['icon'].replace('EquipIcon', 'Gacha_WeaponImg')}.webp`))
                      .width('100%')
                      .height(380)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(10)
                    Image($rawfile(`GI/resource/others/star${this.weaponWiki['rank']}.png`))
                      .height(30)
                      .objectFit(ImageFit.Contain)
                      .margin({ bottom: 8, right: 8 })
                  }
                  .alignContent(Alignment.BottomEnd)
                  .height(380)
                  .width('100%')
                }
                .width('94%')
                .alignItems(HorizontalAlign.Center)
                .borderRadius(10)
                .shadow({ color: '#4D00001E', radius: 10, offsetY: 5 })
                .margin({ top: 10, bottom: 10 })
                .clip(true)
                .backgroundColor($r('app.color.card_background_color'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            // 等级
            ListItem() {
              Row() {
                Column({ space: 5 }) {
                  Row() {
                    Text(`Lv ${this.level}`)
                      .fontSize(20)
                      .fontColor($r('app.color.text_color'))

                    Slider({
                      value: this.level,
                      min: 1,
                      max: 90,
                      step: 1,
                      style: SliderStyle.InSet,
                    })
                      .width('61.8%')
                      .alignSelf(ItemAlign.End)
                      .onChange((value: number, mode: SliderChangeMode) => {
                        animateTo({
                          duration: 300,
                          curve: Curve.EaseInOut,
                          iterations: 1,
                          playMode: PlayMode.Normal
                        }, () => {
                          this.level = Math.round(value)
                          this.calcProp()
                        })
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .padding(12)
                }
                .width('94%')
                .alignItems(HorizontalAlign.Center)
                .borderRadius(10)
                .shadow({ color: '#4D00001E', radius: 10, offsetY: 5 })
                .margin({ top: 10, bottom: 10 })
                .clip(true)
                .backgroundColor($r('app.color.card_background_color'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            // 属性
            ListItem() {
              Row() {
                GridRow({
                  columns: 2,
                  gutter: { x: 5, y: 5 },
                  direction: GridRowDirection.Row
                }) {
                  GridCol({ span: { xs: 2, sm: 2, md: 1, lg: 1 } }) {
                    List({ space: 10 }) {
                      ForEach(this.propList, item => {
                        ListItem() {
                          Row() {
                            Text(this.manualWeapon[item.key])
                              .fontSize(18)
                              .fontColor($r('app.color.text_color'))
                            Text(propUnit.get(item.key) === '%' ? `${Math.round(item.value * 1000) / 10}%` : `${Math.round(item.value)}`)
                              .fontSize(18)
                              .fontColor($r('app.color.text_color'))
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.SpaceBetween)
                        }
                      })
                      // 精炼效果
                      if (this.weaponWiki['affix']) {
                        ListItem() {
                          Row() {
                            Column({ space: 5 }) {
                              Row() {
                                Text(this.weaponWiki['affix'][`1${this.weaponId}`].name)
                                  .fontSize(16)
                                  .fontColor($r('app.color.text_color'))
                                Row() {
                                  Text('精炼')
                                    .fontSize(16)
                                    .fontColor($r('app.color.text_color'))
                                  Counter() {
                                    Text(`${this.affixLevel}`)
                                      .fontSize(16)
                                      .fontColor($r('app.color.text_color'))
                                  }
                                  .onInc(() => {
                                    if (this.affixLevel < 5) this.affixLevel++
                                  })
                                  .onDec(() => {
                                    if (this.affixLevel > 1) this.affixLevel--
                                  })
                                  Text('阶')
                                    .fontSize(16)
                                    .fontColor($r('app.color.text_color'))
                                }
                              }
                              .width('100%')
                              .height(40)
                              .justifyContent(FlexAlign.SpaceBetween)

                              Column({ space: 5 }) {
                                Text() {
                                  Span('——')
                                    .fontColor($r('app.color.sub_text_color'))
                                    .fontSize(16)
                                  ForEach(this.getColorfulTextArrayFromHtmlText(this.weaponWiki['affix'][`1${this.weaponId}`].upgrade[`${this.affixLevel - 1}`]), (item) => {
                                    Span(item.content.replace(/\\n/g, '\n').replace(/\n\n/g, '\n \n'))
                                      .fontSize(18)
                                      .fontColor(item.color ? '#3299CC' : $r('app.color.text_color'))
                                      .fontStyle(item.italic ? FontStyle.Italic : FontStyle.Normal)
                                  })
                                }
                                .copyOption(CopyOptions.LocalDevice)
                              }
                              .width('100%')
                              .alignItems(HorizontalAlign.Start)
                            }
                            .width('100%')
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                        }
                      }
                      // 描述
                      ListItem() {
                        Row() {
                          Column({ space: 5 }) {
                            Text(`——${this.weaponWiki['description']}`)
                              .fontColor($r('app.color.sub_text_color'))
                              .fontSize(14)
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .alignItems(HorizontalAlign.Start)
                        }
                        .width('100%')
                        .justifyContent(FlexAlign.Center)
                      }
                    }
                    .padding(12)
                  }
                  .width('100%')
                  .backgroundColor($r('app.color.card_background_color'))
                  .clip(true)

                  GridCol({ span: { xs: 2, sm: 2, md: 1, lg: 1 } }) {
                    Flex({ wrap: FlexWrap.Wrap }) {
                      Row() {
                        Text('突破所需材料')
                          .fontSize(20)
                          .fontColor($r('app.color.text_color'))
                      }
                      .width('100%')
                      .margin({ bottom: 5 })

                      ForEach(this.cost, (item) => {
                        Column() {
                          Column() {
                            Image($rawfile(`GI/resource/${item.id}/${this.materials['items'][`${item.id}`].icon}.webp`))
                              .width('100%')
                              .aspectRatio(1)
                          }
                          .width(80)
                          .aspectRatio(1)
                          .borderRadius(10)
                          .backgroundImage($rawfile(`GI/resource/others/RarityBGI/bg${this.materials['items'][`${item.id}`].rank}.png`))
                          .backgroundImageSize(ImageSize.Cover)
                          .clip(true)

                          Column() {
                            Text(this.materials['items'][`${item.id}`].name)
                              .fontSize(13)
                              .fontColor($r('app.color.sub_text_color'))
                              .height(18)
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                              .copyOption(CopyOptions.LocalDevice)
                            Text(`${item.count}`)
                              .fontSize(13)
                              .fontColor($r('app.color.text_color'))
                              .height(15)
                          }
                        }
                        .width(80)
                        .borderRadius(10)
                        .shadow({ color: '#4000001E', radius: 20 })
                        .clip(true)
                        .backgroundColor($r('app.color.card_background_color'))
                        .margin(5)
                      })
                    }
                    .padding(12)
                  }
                  .width('100%')
                  .backgroundColor($r('app.color.card_background_color'))
                  .clip(true)
                }
                .width('94%')
                .borderRadius(10)
                .shadow({ color: '#4D00001E', radius: 10, offsetY: 5 })
                .margin({ top: 10, bottom: 10 })
                .clip(true)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            // 故事
            ListItem() {
              Row() {
                Column({ space: 10 }) {
                  Column() {
                    Text(this.weaponStory.replace(/\n\n/g, '\n \n'))
                      .fontSize(16)
                      .fontColor($r('app.color.text_color'))
                      .copyOption(CopyOptions.LocalDevice)
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }
                .width('94%')
                .alignItems(HorizontalAlign.Center)
                .borderRadius(10)
                .shadow({ color: '#4D00001E', radius: 10, offsetY: 5 })
                .margin({ top: 10, bottom: 10 })
                .padding(12)
                .clip(true)
                .backgroundColor($r('app.color.card_background_color'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
          }
          .height('100%')
          .width('100%')
        }
      }
      .mode(NavigationMode.Stack)
      .title({
        builder: this.NavigationTitle,
        height: this.titleHeight
      })
      .margin({ bottom: `${globalThis?.avoidArea?.bottomRect?.height ?? 120}px` })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background_color'))
    .padding({ top: `${globalThis?.avoidArea?.topRect?.height ?? 120}px`, left: 8, right: 8 })
  }

  @Builder
  NavigationTitle() {
    Row() {
      PageBackButton()

      if (this.loadWikiDone) {
        Image($rawfile(`GI/resource/${this.weaponId}/${this.weaponWiki['icon']}.webp`))
          .height('100%')
          .aspectRatio(1)
          .borderRadius(10)
      }

      Text(this.title)
        .fontSize(24)
        .fontColor($r('app.color.text_color'))
        .fontWeight(FontWeight.Bold)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .width('100%')
    .padding(8)
  }

  getColorfulTextArrayFromHtmlText(htmlText: string): Array<{ content: string, color: string, italic: boolean }> {
    const regex = /(?:<color=(#[A-Fa-f0-9]{8})>(.*?)<\/color>)|<(i)>(.*?)<\/\3>|([^<]+)/g;
    let result: { content: string, color: string, italic: boolean }[] = []
    let match
    while ((match = regex.exec(htmlText)) !== null) {
      const [, color, content, tag, innerContent, plainText] = match;

      if (color && content) {
        let rgbaColor = color;
        const rgb = rgbaColor.slice(1, 7);
        const alpha = rgbaColor.slice(7);
        const argbColor = `#${alpha}${rgb}`;
        console.log(argbColor)
        result.push({ content: content, color: argbColor, italic: false });
      } else if (tag && innerContent) {
        result.push({ content: innerContent, color: '', italic: true });
      } else if (plainText) {
        result.push({ content: plainText, color: '', italic: false });
      }
    }

    return result
  }

  elementTrans(name: string) {
    switch(name) {
      case 'ice': return 'Cryo'
      case 'wind': return 'Anemo'
      case 'electric': return 'Electro'
      case 'water': return 'Hydro'
      case 'fire': return 'Pyro'
      case 'rock': return 'Geo'
      case 'grass': return 'Dendro'
      default: return ''
    }
  }
}