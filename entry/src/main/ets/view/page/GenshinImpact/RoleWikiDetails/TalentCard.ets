@Component
export default struct TalentCard {
  private talentWiki: any = null
  private avatarId: string
  @Consume materials: Object
  @State level: number = 0
  @State type: number = 0
  @State expand: boolean = false
  @State costList: {}[] = []

  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  aboutToAppear() {
    this.type = this.talentWiki['type']
    this.level = this.type === 0 || this.type === 1 ? 10 : 1
    this.calcCost()
  }

  calcCost() {
    if (this.type === 2) return;
    let i: number
    let costMap = { '202': 0 }
    for (i = 2; i <= this.level; ++i) {
      if (this.talentWiki['promote'][`${i}`].costItems) {
        for (let key in this.talentWiki['promote'][`${i}`].costItems) {
          costMap[key] = costMap[key] ?? 0
          costMap[key] += this.talentWiki['promote'][`${i}`].costItems[key]
        }
      }
      if (this.talentWiki['promote'][`${i}`].coinCost) {
        costMap['202'] += this.talentWiki['promote'][`${i}`].coinCost
      }
    }

    let costList: {}[] = []
    for (let key in costMap) {
      costList.push({
        id: key,
        count: costMap[key]
      })
    }
    this.costList = costList
  }

  build() {
    Column({ space: 10 }) {
      if (this.talentWiki != null) {
        Column() {
          Row({ space: 5 }) {
            Image($rawfile(`GI/resource/${this.avatarId}/${this.talentWiki.icon}.webp`))
              .width(45)
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)

            Text(this.talentWiki.name)
              .fontSize(25)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
            Text(this.type === 1 ? '（元素爆发）' : '')
              .fontSize(20)
              .fontColor('#4DFFFFFF')
          }
          .justifyContent(FlexAlign.Start)
          .alignSelf(ItemAlign.Start)
          .height(50)
          .width('100%')
          .onClick(() => {
            animateTo({
              duration: 400,
              curve: Curve.EaseInOut,
              iterations: 1,
              playMode: PlayMode.Normal,
              onFinish: () => {}
            }, () => {
              this.expand = !this.expand
            })
          })


          Row() {
            Text(`Lv ${this.level}`)
              .lineHeight(25)
              .fontSize(21)
              .fontColor(Color.White)

            if (this.type !== 2) {
              Slider({
                value: this.level,
                min: 1,
                max: 13,
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
                    this.level = value
                    this.calcCost()
                  })
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignSelf(ItemAlign.Start)
        .width('100%')

        if (this.type !== 2) {
          Flex({ wrap: FlexWrap.Wrap }) {
            Row() {
              Text('升级所需材料')
                .fontSize(20)
                .fontColor(Color.White)
            }
            .width('100%')
            .margin({ bottom: 5 })

            ForEach(this.costList, (item) => {
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
        }

        if (this.expand) {
          Column() {
            // 技能描述
            Text() {
              ForEach(this.getColorfulTextArrayFromHtmlText(this.talentWiki.description), item => {
                Span(item.content.replace(/\\n/g, '\n').replace(/\n\n/g, '\n \n'))
                  .fontSize(18)
                  .fontColor(item.color ? item.color : Color.White)
                  .fontStyle(item.italic ? FontStyle.Italic : FontStyle.Normal)
              })
            }
            .width('100%')
            .textAlign(TextAlign.Start)
            .copyOption(CopyOptions.LocalDevice)

            if (this.type !== 2) {
              Divider()
                .width('90%')
                .strokeWidth(2)
                .color($r('app.color.stroke_line_color'))
                .margin({ top: 5, bottom: 5 })

              // 技能参数
              List({ space: 3 }) {
                ForEach(this.formatDescription(this.talentWiki['promote'][`${this.level}`].description, this.talentWiki['promote'][`${this.level}`].params), item => {
                  ListItem() {
                    Row() {
                      Text(item.title)
                        .fontSize(18)
                        .fontColor(Color.White)
                        .copyOption(CopyOptions.LocalDevice)

                      Blank()

                      Text(item.params)
                        .fontSize(18)
                        .fontColor(item.title === '元素能量' ? Color.Yellow : '#B3FFFFFF')
                        .copyOption(CopyOptions.LocalDevice)
                    }
                    .width('100%')
                  }
                })
              }
              .alignListItem(ListItemAlign.Center)
            }
          }
          .width('100%')
        }
      }
    }
    .width('100%')
    .backdropBlur(100)
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

  formatDescription(descriptions: string[], params: number[]): { title: string, params: string }[] {
    descriptions = descriptions.filter(item => item !== "")

    let paramDict: { [key: string]: number } = {};
    params.forEach((param, index) => {
      paramDict[`param${index + 1}`] = param;
    });

    type pair = { title: string, params: string }

    let formattedDescriptionArray: Array<pair> = []

    const pattern = /\{(\w+):(\w+)\}/g

    const formattedDescription = descriptions.map(item => {
      return item.replace(pattern, (match, paramName: string, format: string) => {
        const paramValue: number = paramDict[paramName];

        switch (format) {
          case 'P':
          case 'F2P':
            return (Math.round(paramValue * 100 * 100) / 100).toString() + '%';
          case 'F1':
          case 'F':
            return (Math.round(paramValue * 10) / 10).toString();
          case 'F1P':
            return (Math.round(paramValue * 100 * 10) / 10).toString() + '%';
          case 'I':
            return Math.round(paramValue).toString();
          default:
            return (Math.round(paramValue * 100) / 100).toString(); // 保留两位小数
        }
      });
    });

    for (let desc of formattedDescription) {
      let [title, param] = desc.split('|')

      formattedDescriptionArray.push({ title: title, params: param })
    }

    return formattedDescriptionArray;
  }
}