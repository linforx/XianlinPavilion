import PageBackButton from '../../view/PageBackButton'
import router from '@ohos.router'
import common from '@ohos.app.ability.common'

@Entry
@Component
struct GI_WeaponWiki {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State titleHeight: number = 70
  @State title: string = '武器图鉴'
  private weaponMap: {} = router.getParams()['wikiMap'] ?? {}
  @State WEAPON_SWORD_ONE_HAND_List: MyDataSource = new MyDataSource()
  @State WEAPON_CLAYMORE_List: MyDataSource = new MyDataSource()
  @State WEAPON_POLE_List: MyDataSource = new MyDataSource()
  @State WEAPON_CATALYST_List: MyDataSource = new MyDataSource()
  @State WEAPON_BOW_List: MyDataSource = new MyDataSource()
  @State currentIndex: number = 0

  loadList() {
    let SOH_list = []
    let Cal_list = []
    let Pole_list = []
    let Cat_list = []
    let Bow_list = []

    for (let key in this.weaponMap['items']) {
      if (!this.weaponMap['items'][key].name) {
        delete this.weaponMap[key]
        continue
      }
      switch (this.weaponMap['items'][key].type) {
        case 'WEAPON_SWORD_ONE_HAND':
          SOH_list.push(this.weaponMap['items'][key])
          break
        case 'WEAPON_CLAYMORE':
          Cal_list.push(this.weaponMap['items'][key])
          break
        case 'WEAPON_POLE':
          Pole_list.push(this.weaponMap['items'][key])
          break
        case 'WEAPON_CATALYST':
          Cat_list.push(this.weaponMap['items'][key])
          break
        case 'WEAPON_BOW':
          Bow_list.push(this.weaponMap['items'][key])
          break
      }
    }

    SOH_list.sort((a, b) => {
      if (a.rank !== b.rank) return b.rank - a.rank;
      else return 1;
    })
    Cal_list.sort((a, b) => {
      if (a.rank !== b.rank) return b.rank - a.rank;
      else return 1;
    })
    Pole_list.sort((a, b) => {
      if (a.rank !== b.rank) return b.rank - a.rank;
      else return 1;
    })
    Cat_list.sort((a, b) => {
      if (a.rank !== b.rank) return b.rank - a.rank;
      else return 1;
    })
    Bow_list.sort((a, b) => {
      if (a.rank !== b.rank) return b.rank - a.rank;
      else return 1;
    })

    SOH_list.forEach((item) => { this.WEAPON_SWORD_ONE_HAND_List.pushData(item) })
    Cal_list.forEach((item) => { this.WEAPON_CLAYMORE_List.pushData(item) })
    Pole_list.forEach((item) => { this.WEAPON_POLE_List.pushData(item) })
    Cat_list.forEach((item) => { this.WEAPON_CATALYST_List.pushData(item) })
    Bow_list.forEach((item) => { this.WEAPON_BOW_List.pushData(item) })
  }

  aboutToAppear() {
    this.loadList()
  }

  build() {
    Column() {
      Navigation() {
        Tabs() {
          TabContent() {
            List() {
              ListItem() {
                GridRow({
                  columns: 12,
                  gutter: { x: 0, y: 0 },
                  direction: GridRowDirection.Row
                }) {
                  LazyForEach(this.WEAPON_SWORD_ONE_HAND_List, (item) => {
                    GridCol({ span: { xs: 6, sm: 3, md: 2, lg: 2 } }) {
                      Row() {
                        Button() {
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
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
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
                          }
                          .width(90)
                        }
                        .type(ButtonType.Normal)
                        .backgroundColor($r('app.color.card_background_color'))
                        .borderRadius(10)
                        .shadow({ color: '#4000001E', radius: 20 })
                        .margin({ top: 10, bottom: 10, left: 4, right: 4 })
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/GenshinImpact/WeaponWikiDetails',
                            params: {
                              weaponId: `${item.id}`
                            }
                          })
                        })
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
              .width('96%')
            }
            .height('100%')
            .alignListItem(ListItemAlign.Center)
          }
          .tabBar(this.tabBar('单手剑', 0))

          TabContent() {
            List() {
              ListItem() {
                GridRow({
                  columns: 12,
                  gutter: { x: 0, y: 0 },
                  direction: GridRowDirection.Row
                }) {
                  LazyForEach(this.WEAPON_CLAYMORE_List, (item) => {
                    GridCol({ span: { xs: 6, sm: 3, md: 2, lg: 2 } }) {
                      Row() {
                        Button() {
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
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
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
                          }
                          .width(90)
                        }
                        .type(ButtonType.Normal)
                        .backgroundColor($r('app.color.card_background_color'))
                        .borderRadius(10)
                        .shadow({ color: '#4000001E', radius: 20 })
                        .margin({ top: 10, bottom: 10, left: 4, right: 4 })
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/GenshinImpact/WeaponWikiDetails',
                            params: {
                              weaponId: `${item.id}`
                            }
                          })
                        })
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
              .width('96%')
            }
            .height('100%')
            .alignListItem(ListItemAlign.Center)
          }
          .tabBar(this.tabBar('双手剑', 1))

          TabContent() {
            List() {
              ListItem() {
                GridRow({
                  columns: 12,
                  gutter: { x: 0, y: 0 },
                  direction: GridRowDirection.Row
                }) {
                  LazyForEach(this.WEAPON_POLE_List, (item) => {
                    GridCol({ span: { xs: 6, sm: 3, md: 2, lg: 2 } }) {
                      Row() {
                        Button() {
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
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
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
                          }
                          .width(90)
                        }
                        .type(ButtonType.Normal)
                        .backgroundColor($r('app.color.card_background_color'))
                        .borderRadius(10)
                        .shadow({ color: '#4000001E', radius: 20 })
                        .margin({ top: 10, bottom: 10, left: 4, right: 4 })
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/GenshinImpact/WeaponWikiDetails',
                            params: {
                              weaponId: `${item.id}`
                            }
                          })
                        })
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
              .width('96%')
            }
            .height('100%')
            .alignListItem(ListItemAlign.Center)
          }
          .tabBar(this.tabBar('长柄武器', 2))

          TabContent() {
            List() {
              ListItem() {
                GridRow({
                  columns: 12,
                  gutter: { x: 0, y: 0 },
                  direction: GridRowDirection.Row
                }) {
                  LazyForEach(this.WEAPON_CATALYST_List, (item) => {
                    GridCol({ span: { xs: 6, sm: 3, md: 2, lg: 2 } }) {
                      Row() {
                        Button() {
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
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
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
                          }
                          .width(90)
                        }
                        .type(ButtonType.Normal)
                        .backgroundColor($r('app.color.card_background_color'))
                        .borderRadius(10)
                        .shadow({ color: '#4000001E', radius: 20 })
                        .margin({ top: 10, bottom: 10, left: 4, right: 4 })
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/GenshinImpact/WeaponWikiDetails',
                            params: {
                              weaponId: `${item.id}`
                            }
                          })
                        })
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
              .width('96%')
            }
            .height('100%')
            .alignListItem(ListItemAlign.Center)
          }
          .tabBar(this.tabBar('法器', 3))

          TabContent() {
            List() {
              ListItem() {
                GridRow({
                  columns: 12,
                  gutter: { x: 0, y: 0 },
                  direction: GridRowDirection.Row
                }) {
                  LazyForEach(this.WEAPON_BOW_List, (item) => {
                    GridCol({ span: { xs: 6, sm: 3, md: 2, lg: 2 } }) {
                      Row() {
                        Button() {
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
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
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
                          }
                          .width(90)
                        }
                        .type(ButtonType.Normal)
                        .backgroundColor($r('app.color.card_background_color'))
                        .borderRadius(10)
                        .shadow({ color: '#4000001E', radius: 20 })
                        .margin({ top: 10, bottom: 10, left: 4, right: 4 })
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/GenshinImpact/WeaponWikiDetails',
                            params: {
                              weaponId: `${item.id}`
                            }
                          })
                        })
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
              .width('96%')
            }
            .height('100%')
            .alignListItem(ListItemAlign.Center)
          }
          .tabBar(this.tabBar('弓', 4))
        }
        .width('100%')
        .barMode(BarMode.Scrollable)
        .onChange((index) => {
          this.currentIndex = index
        })
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
}

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): any {
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

class MyDataSource extends BasicDataSource {
  private dataArray: any[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): any {
    return this.dataArray[index];
  }

  public addData(index: number, data: any): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: any): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}