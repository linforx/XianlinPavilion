import common from '@ohos.app.ability.common'
import FileManager from '../../common/utils/FileManager'
import PageBackButton from '../../view/PageBackButton'
import router from '@ohos.router'

@Entry
@Component
struct GI_WikiCatagory {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State titleHeight: number = 70
  @State title: string = '原神百科'
  private avatarMap: {} = {}
  @State AvatarWikiList: Array<{}> = []

  aboutToAppear() {
    this.loadAvatarList()
  }

  build() {
    Column() {
      Navigation() {
        List() {
          ListItem() {
            Column({ space: 12 }) {
              Row() {
                Text('角色图鉴')
                  .fontSize(22)
                  .fontColor($r('app.color.text_color'))

                Blank()

                Image($r('app.media.ic_public_arrow_right'))
                  .height(30)
                  .aspectRatio(1)
              }
              .width('100%')
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/GenshinImpact/RoleWiki',
                  params: {
                    wikiMap: this.avatarMap,
                    wikiList: this.AvatarWikiList
                  }
                })
              })

              Row() {
                List() {
                  ForEach(this.AvatarWikiList, item => {
                    ListItem() {
                      Button() {
                        Column() {
                          Stack({ alignContent: Alignment.Top }) {
                            Column() {
                              Column() {
                                Image($rawfile(`GI/resource/${item.id}/${item.icon}.webp`))
                                  .width('100%')
                                  .aspectRatio(1)
                                  .objectFit(ImageFit.Contain)
                              }
                              .width('100%')
                              .aspectRatio(1)
                              .backgroundImage($rawfile(`GI/resource/others/RarityBGI/bg${item.rank}.png`))
                              .backgroundImageSize(ImageSize.Contain)
                              .borderRadius({ topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 30 })
                              .clip(true)

                              Column() {
                                Text(item.name)
                                  .fontSize(15)
                              }
                              .width('100%')
                              .height(26)
                              .justifyContent(FlexAlign.Center)
                              .borderRadius(10)
                              .clip(true)
                            }

                            Row() {
                              Image($rawfile(`GI/resource/others/star${item.rank}.png`))
                                .height(16)
                            }
                            .width('100%')
                            .justifyContent(FlexAlign.Center)
                            .margin({ top: 78 })

                            Row() {
                              Image($rawfile(`GI/resource/others/ElementIcon/${this.elementTrans(item.element.toLowerCase())}.png`))
                                .height(20)
                                .aspectRatio(1)
                            }
                            .width(20)
                            .borderRadius(10)
                            .justifyContent(FlexAlign.Center)
                            .margin({ right: 60, top: 7 })
                          }
                          .width(90)
                        }
                      }
                      .type(ButtonType.Normal)
                      .backgroundColor($r('app.color.card_background_color'))
                      .borderRadius(10)
                      .shadow({ color: '#4000001E', radius: 20 })
                      .margin({ top: 10, bottom: 10, left: 8, right: 8 })
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/GenshinImpact/RoleWikiDetails',
                          params: {
                            avatarId: `${item.id}`,
                            weaponType: this.avatarMap['types'][item.weaponType]
                          }
                        })
                      })
                    }
                  })
                }
                .listDirection(Axis.Horizontal)
                .cachedCount(3)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .width('95%')
            .borderRadius(16)
            .backgroundColor($r('app.color.card_background_color'))
            .padding(12)

          }
        }
        .width('100%')
        .height('100%')
        .alignListItem(ListItemAlign.Center)
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

      Text('我的角色')
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

  async loadAvatarList() {
    let avatarMap = JSON.parse(await new FileManager(this.context).getRawFileTextAsync('GI/avatar_list.json')) as any
    this.avatarMap = avatarMap

    let avatarList: any[] = []
    for (let key in avatarMap['items']) {
      avatarList.push(avatarMap['items'][key])
    }

    this.AvatarWikiList = avatarList.sort((a, b) => {
      if (a.name === "旅行者" && !a.release) {
        return 1
      } else if (b.name === "旅行者" && !b.release) {
        return -1
      }
      if (a.release && b.release) {
        return b.release - a.release
      }
      else {
        if (!a.release) return -1
        else return 1
      }
    })
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