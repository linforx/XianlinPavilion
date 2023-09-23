import TalentInfo from '../../../viewmodel/page/GI_MyAvatarDetails/TalentInfo'

@CustomDialog
export default struct TalentDetailsDialog {
  private info: TalentInfo
  private talentWiki: any
  @State level: number = 0

  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  aboutToAppear() {
    this.level = this.info.current_level + (this.info.extraUpgrade ? 3 : 0)
    console.log(this.info.name)
  }

  build() {
    Column({ space: 10 }) {
      Column() {
        Row({ space: 5 }) {
          Image($rawfile(this.info.icon))
            .width(45)
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)

          Text(this.info.name)
            .fontSize(25)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .copyOption(CopyOptions.LocalDevice)
        }
        .justifyContent(FlexAlign.Start)
        .alignSelf(ItemAlign.Start)


        Row() {
          Text(`Lv ${this.level}`)
            .lineHeight(25)
            .fontSize(21)
            .fontColor(this.info.extraUpgrade ? '#f7ce00' : Color.White)
            .fontWeight(this.info.extraUpgrade ? FontWeight.Medium : FontWeight.Normal)

          Slider({
            value: this.info.current_level + (this.info.extraUpgrade ? 3 : 0),
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
                playMode: PlayMode.Normal,
                onFinish: () => {
                  console.info('play end')
                }
              }, () => {
                this.level = value
              })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignSelf(ItemAlign.Start)
      .width('100%')


      Scroll() {
        Column() {
          // 技能描述
          Text() {
            ForEach(this.getColorfulTextArrayFromHtmlText(this.info.wiki['description']), item => {
              Span(item.content.replace(/\\n/g, '\n').replace(/\n\n/g, '\n \n'))
                .fontSize(18)
                .fontColor(item.color ? item.color : Color.White)
                .fontStyle(item.italic ? FontStyle.Italic : FontStyle.Normal)
            })
          }

          Divider()
            .width('90%')
            .strokeWidth(2)
            .color($r('app.color.stroke_line_color'))
            .margin({ top: 5, bottom: 5 })

          // 技能参数
          List({ space: 3  }) {
            ForEach(this.formatDescription(this.talentWiki[`${this.level}`]['description'], this.talentWiki[`${this.level}`]['params']), item => {
              ListItem() {
                Row() {
                  Text(item.title)
                    .fontSize(18)
                    .fontColor(Color.White)

                  Blank()

                  Text(item.params)
                    .fontSize(18)
                    .fontColor(item.title === '元素能量' ? Color.Yellow : '#B3FFFFFF')
                }
                .width('100%')
              }
            })
          }
          .alignListItem(ListItemAlign.Center)
        }
      }
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({ maxHeight: '50%' })
      .scrollBar(BarState.Off)
    }
    .backdropBlur(100)
    .width('88%')
    .constraintSize({ maxWidth: 460 })
    .padding({ top: 15, bottom: 15, left: 15, right: 15 })
    .borderRadius(20)
    .shadow({ radius: 50, color: '#4D00001E', offsetY: 10 })
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