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
struct GI_RoleWikiDetails {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private avatarCurve: Object = null
  private manualWeapon: Object = null
  @Provide materials: Object = null
  private promote: boolean = true
  @State avatarWiki: Object = { id: null }
  @State loadWikiDone: boolean = false
  @State titleHeight: number = 70
  @State title: string = '角色图鉴'
  @State avatarId: string = router.getParams()['avatarId']
  @State weaponType: string = router.getParams()['weaponType']
  @State currentIndex: number = 0
  @State level: number = 90
  @State propList: {}[] = []
  @State cost: {}[] = []

  async loadAvatarWikiInfo() {
    this.avatarWiki = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/AvatarInfo/${this.avatarId}.json`)) as any
  }

  async loadAvatarCurve() {
    this.avatarCurve = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/avatar_curve.json`)) as any
  }

  async loadManualWeapon() {
    this.manualWeapon = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/manual_weapon.json`)) as any
  }

  async loadMaterials() {
    this.materials = JSON.parse(await new FileManager(this.context).getRawFileTextAsync(`GI/material_list.json`)) as any
  }

  calcProp() {
    let result = { prop: {}, cost: {} }
    let level: number = this.level      // 暂存level
    let isPromoted: boolean = this.promote

    for (let index = 0; index < this.avatarWiki['upgrade']['promote'].length; ++index) {
      let item = this.avatarWiki['upgrade']['promote'][index]
      // 等级不够上限、不选择突破、已经突破到了最后一个阶段，退出计算
      if (item.unlockMaxLevel > level || item.unlockMaxLevel === level && !isPromoted || index === this.avatarWiki['upgrade']['promote'].length - 1) break;
      if (item.unlockMaxLevel === level && isPromoted) {
        // 计算突破后的数值
        let nextItem = this.avatarWiki['upgrade']['promote'][index + 1]
        for (let key in nextItem.addProps) {
          result.prop[key] = nextItem.addProps[key]
        }
        for (let key in nextItem.costItems) {
          result.cost[key] = result.cost[key] ?? 0
          result.cost[key] += nextItem.costItems[key]
        }

        break
      }
      if (item.unlockMaxLevel < level) {
        let nextItem = this.avatarWiki['upgrade']['promote'][index + 1]
        for (let key in nextItem.addProps) {
          result.prop[key] = nextItem.addProps[key]
        }
        for (let key in nextItem.costItems) {
          result.cost[key] = result.cost[key] ?? 0
          result.cost[key] += nextItem.costItems[key]
        }
      }
    }

    let propList: {}[] = []
    for (let item of this.avatarWiki['upgrade']['prop']) {
      result.prop[item.propType] = result.prop[item.propType] ?? 0
      result.prop[item.propType] += item.initValue * this.avatarCurve[`${level}`]['curveInfos'][item.type]
      propList.push({
        key: item.propType,
        value: result.prop[item.propType]
      })
      delete result.prop[item.propType]
    }
    if (result.prop.hasOwnProperty('FIGHT_PROP_CRITICAL_HURT')) {
      // 基础暴击伤害50%
      result.prop['FIGHT_PROP_CRITICAL_HURT'] += 0.5
    }
    if (result.prop.hasOwnProperty('FIGHT_PROP_CRITICAL')) {
      // 基础暴击率5%
      result.prop['FIGHT_PROP_CRITICAL'] += 0.05
    }
    if (result.prop.hasOwnProperty('FIGHT_PROP_CHARGE_EFFICIENCY')) {
      // 基础充能效率100%
      result.prop['FIGHT_PROP_CHARGE_EFFICIENCY'] += 1
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
      await this.loadAvatarCurve()
      await this.loadMaterials()
      await this.loadAvatarWikiInfo()
    } catch (err) {
      console.error(JSON.stringify(err))
    }
    this.calcProp()
    this.loadWikiDone = true
  }

  build() {
    Column() {
      Navigation() {
        if (this.loadWikiDone) {
          Tabs() {
            TabContent() {
              List() {
                // 立绘
                ListItem() {
                  Row() {
                    Column() {
                      Stack() {
                        Image($rawfile(`GI/resource/${this.avatarId}/${this.avatarWiki['icon'].replace('AvatarIcon', 'Gacha_AvatarImg')}.webp`))
                          .width('100%')
                          .height(380)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(10)
                        Image($rawfile(`GI/resource/others/star${this.avatarWiki['rank']}.png`))
                          .height(30)
                          .objectFit(ImageFit.Contain)
                          .margin({ bottom: 8, right: 8 })
                      }
                      .alignContent(Alignment.BottomEnd)
                      .height(380)
                      .width('100%')
                      .backgroundImage($rawfile(`GI/resource/others/ElementalBGI/bg-${this.elementTrans(this.avatarWiki['element'].toLowerCase())}.png`))
                      .backgroundImageSize(ImageSize.Cover)
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
                // 信息
                ListItem() {
                  Row() {
                    Column({ space: 10 }) {
                      Column({ space: 5 }) {
                        Text(this.avatarWiki['fetter'].title)
                          .fontColor($r('app.color.text_color'))
                          .fontSize(16)
                          .copyOption(CopyOptions.LocalDevice)
                        Text(`——${this.avatarWiki['fetter'].detail}`)
                          .fontColor($r('app.color.sub_text_color'))
                          .fontSize(14)
                          .copyOption(CopyOptions.LocalDevice)
                      }
                      .width('100%')
                      .alignItems(HorizontalAlign.Start)

                      GridRow({
                        columns: 12,
                        gutter: { x: 5, y: 5 },
                        direction: GridRowDirection.Row
                      }) {
                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('上线时间')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(this.avatarWiki['release'] ? `${new Date(this.avatarWiki['release'] * 1000).getFullYear()} 年 ${new Date(this.avatarWiki['release'] * 1000).getMonth() + 1} 月 ${new Date(this.avatarWiki['release'] * 1000).getDate()} 日` : 'Beta')
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)

                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('所属')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(this.avatarWiki['fetter']['native'])
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)

                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('命之座')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(this.avatarWiki['fetter']['constellation'])
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)

                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('生日')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(`${this.avatarWiki['birthday'][0]} 月 ${this.avatarWiki['birthday'][1]} 日`)
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)
                      }
                      .width('100%')

                      GridRow({
                        columns: 12,
                        gutter: { x: 5, y: 5 },
                        direction: GridRowDirection.Row
                      }) {
                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('汉语 CV')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(this.avatarWiki['fetter']['cv']['CHS'])
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)

                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('日语 CV')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(this.avatarWiki['fetter']['cv']['JP'])
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)

                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('英语 CV')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(this.avatarWiki['fetter']['cv']['EN'])
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)

                        GridCol({ span: { xs: 6, sm: 4, md: 3, lg: 3 } }) {
                          Column({ space: 5 }) {
                            Text('韩语 CV')
                              .fontSize(16)
                              .fontColor($r('app.color.text_color'))
                            Text(this.avatarWiki['fetter']['cv']['KR'])
                              .fontSize(14)
                              .fontColor($r('app.color.sub_text_color'))
                              .copyOption(CopyOptions.LocalDevice)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .borderRadius(8)
                        .clip(true)
                      }
                      .width('100%')
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
                // 名片
                if (this.avatarWiki['other'] && this.avatarWiki['other']['nameCard']) {
                  ListItem() {
                    Row() {
                      Column({ space: 5 }) {
                        Image($rawfile(`GI/resource/${this.avatarId}/${this.avatarWiki['other']['nameCard']['icon'].replace('Icon', 'Pic')}_P.webp`))
                        Column() {
                          Text(this.avatarWiki['other']['nameCard']['name'])
                            .fontSize(16)
                            .fontColor($r('app.color.text_color'))
                            .copyOption(CopyOptions.LocalDevice)
                          Text(`——${this.avatarWiki['other']['nameCard']['description'].replace(/\\n/g, '\n')}`)
                            .fontSize(14)
                            .fontColor($r('app.color.sub_text_color'))
                            .copyOption(CopyOptions.LocalDevice)
                        }
                        .padding(10)
                        .width('100%')
                        .alignItems(HorizontalAlign.Start)
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
                }
                // 料理
                if (this.avatarWiki['other'] && this.avatarWiki['other']['specialFood']) {
                  ListItem() {
                    Row() {
                      Column({ space: 10 }) {
                        Text('特殊料理')
                          .fontSize(16)
                          .fontColor($r('app.color.text_color'))

                        Row() {
                          Column() {
                            Stack() {
                              Image($rawfile(`GI/resource/${this.avatarId}/${this.avatarWiki['other']['specialFood']['icon']}.webp`))
                                .width('100%')
                                .aspectRatio(1)
                              Image($rawfile(`GI/resource//${this.avatarId}/${this.avatarWiki['other']['specialFood']['effectIcon']}.webp`))
                                .width('30%')
                                .aspectRatio(1)
                                .margin({ right: 5, bottom: 5 })
                            }
                            .width(80)
                            .aspectRatio(1)
                            .borderRadius(10)
                            .backgroundImage($rawfile(`GI/resource/others/RarityBGI/bg${this.avatarWiki['other']['specialFood']['rank']}.png`))
                            .backgroundImageSize(ImageSize.Cover)
                            .alignContent(Alignment.BottomEnd)
                            .clip(true)

                            Row() {
                              Text(this.avatarWiki['other']['specialFood']['name'])
                                .fontSize(13)
                                .fontColor($r('app.color.sub_text_color'))
                                .height(20)
                            }
                          }
                          .width(80)
                          .borderRadius(10)
                          .shadow({ color: '#4000001E', radius: 20 })
                        }
                        .width('100%')
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
              }
              .height('100%')
            }
            .tabBar(this.tabBar('基本信息', 0))

            TabContent() {
              List() {
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
                ListItem() {
                  Row() {
                    GridRow({
                      columns: 2,
                      gutter: { x: 5, y: 5 },
                      direction: GridRowDirection.Row
                    }) {
                      GridCol({ span: { xs: 2, sm: 2, md: 1, lg: 1 } }) {
                        List({ space: 5 }) {
                          ForEach(this.propList, item => {
                            ListItem() {
                              Row() {
                                Text(this.manualWeapon[item.key])
                                  .fontSize(16)
                                  .fontColor($r('app.color.text_color'))
                                Text(propUnit.get(item.key) === '%' ? `${Math.round(item.value * 1000) / 10}%` : `${Math.round(item.value)}`)
                                  .fontSize(16)
                                  .fontColor($r('app.color.text_color'))
                              }
                              .width('100%')
                              .justifyContent(FlexAlign.SpaceBetween)
                            }
                          })
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
              }
              .width('100%')
              .height('100%')
              .alignListItem(ListItemAlign.Center)
            }
            .tabBar(this.tabBar('成长', 1))

            TabContent() {
              List() {
                ListItem() {
                  Column() {
                    ForEach(Object.values(this.avatarWiki['talent']), item => {
                      Row() {
                        Column({ space: 5 }) {
                          TalentCard({ talentWiki: item, avatarId: this.avatarId })
                        }
                        .width('94%')
                        .alignItems(HorizontalAlign.Center)
                        .borderRadius(10)
                        .shadow({ color: '#4D00001E', radius: 10, offsetY: 5 })
                        .margin({ top: 10, bottom: 10 })
                        .padding(15)
                        .clip(true)
                        .backgroundImage($rawfile(`GI/resource/others/ElementalBGI/bg-${this.elementTrans(this.avatarWiki['element'].toLowerCase())}.png`))
                        .backgroundImageSize(ImageSize.Cover)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.Center)
                    })
                  }
                  .animation({
                    duration: 600,
                    curve: Curve.EaseInOut,
                    iterations: 1,
                    playMode: PlayMode.Normal
                  })
                }
              }
              .width('100%')
              .height('100%')
              .alignListItem(ListItemAlign.Center)
            }
            .tabBar(this.tabBar('天赋', 2))

            TabContent() {
              List() {
                ForEach(Object.values(this.avatarWiki['constellation']), item => {
                  ListItem() {
                    Column() {
                      Column({ space: 10 }) {
                        Row() {
                          Image($rawfile(`GI/resource/${this.avatarId}/${item.icon}.webp`))
                            .width(45)
                            .aspectRatio(1)
                            .objectFit(ImageFit.Contain)

                          Text(item.name)
                            .fontSize(25)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(Color.White)
                            .copyOption(CopyOptions.LocalDevice)
                        }
                        .justifyContent(FlexAlign.SpaceBetween)
                        .alignSelf(ItemAlign.Start)

                        Row() {
                          // 命座描述
                          Text() {
                            ForEach(this.getColorfulTextArrayFromHtmlText(item.description), item => {
                              Span(item.content.replace(/\\n/g, '\n').replace(/\n\n/g, '\n \n'))
                                .fontSize(18)
                                .fontColor(item.color ? item.color : Color.White)
                                .fontStyle(item.italic ? FontStyle.Italic : FontStyle.Normal)
                            })
                          }
                        }
                        .width('100%')
                      }
                      .backdropBlur(100)
                    }
                    .width('94%')
                    .alignItems(HorizontalAlign.Center)
                    .borderRadius(10)
                    .shadow({ color: '#4D00001E', radius: 10, offsetY: 5 })
                    .margin({ top: 10, bottom: 10 })
                    .padding(12)
                    .clip(true)
                    .backgroundImage($rawfile(`GI/resource/others/ElementalBGI/bg-${this.elementTrans(this.avatarWiki['element'].toLowerCase())}.png`))
                    .backgroundImageSize(ImageSize.Cover)
                  }
                })
              }
              .width('100%')
              .height('100%')
              .alignListItem(ListItemAlign.Center)
            }
            .tabBar(this.tabBar('命之座', 3))
          }
          .width('100%')
          .barMode(BarMode.Scrollable)
          .onChange((index) => {
            this.currentIndex = index
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
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background_color'))
    .padding({ top: `${globalThis?.avoidArea?.topRect?.height ?? 120}px`, left: 8, right: 8 })
  }

  @Builder tabBar(content: string, index: number) {
    Row() {
      Text(content)
        .fontColor(index == this.currentIndex ? $r('app.color.text_color') : $r('app.color.sub_text_color'))
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.None })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding(6)
    .height(22)
  }

  @Builder
  NavigationTitle() {
    Row() {
      PageBackButton()

      if (this.avatarWiki['id']) {
        Image($rawfile(`GI/resource/${this.avatarId}/${this.avatarWiki['icon']}.webp`))
          .height('100%')
          .aspectRatio(1)
          .borderRadius(10)
      }

      Text(this.avatarWiki['name'] + '  ')
        .fontSize(24)
        .fontColor($r('app.color.text_color'))
        .fontWeight(FontWeight.Bold)
      Text(this.weaponType)
        .fontSize(24)
        .fontColor($r('app.color.sub_text_color'))
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