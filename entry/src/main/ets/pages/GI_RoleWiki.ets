import common from '@ohos.app.ability.common'
import FileManager from '../common/utils/FileManager'
import PageBackButton from '../view/PageBackButton'
import router from '@ohos.router'

@Entry
@Component
struct GI_RoleWiki {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State titleHeight: number = 70
  @State title: string = '角色图鉴'
  private avatarMap: {} = router.getParams()['wikiMap'] ?? {}
  private AvatarWikiList: Array<{}> = router.getParams()['wikiList'] ?? []
  @State data: MyDataSource = new MyDataSource()

  loadList() {
    for (let item of this.AvatarWikiList) {
      this.data.pushData(item)
    }
  }

  aboutToAppear() {
    this.loadList()
  }

  build() {
    Column() {
      Navigation() {
        List() {
          ListItem() {
            GridRow({
              columns: 12,
              gutter: { x: 5, y: 20 },
              direction: GridRowDirection.Row
            }) {
              LazyForEach(this.data, (item) => {
                GridCol({ span: { xs: 4, sm: 3, md: 2, lg: 2 } }) {
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
                    .type(ButtonType.Normal)
                    .backgroundColor($r('app.color.card_background_color'))
                    .borderRadius(10)
                    .shadow({ color: '#4000001E', radius: 20 })
                    .margin({ top: 10, bottom: 10, left: 8, right: 8 })
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/GI_RoleWikiDetails',
                        params: {
                          avatarId: `${item.id}`,
                          weaponType: this.avatarMap['types'][item.weaponType]
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
        }
        .height('100%')
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

      Text('角色图鉴')
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