import ConstellationInfo from '../../../viewmodel/page/GI_MyAvatarDetails/ConstellationInfo'

@CustomDialog
export default struct ConstellationDetailsDialog {
  private info: ConstellationInfo
  @State level: number = 0

  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  build() {
    Column({ space: 10 }) {
      Row({ space: 5 }) {
        Image($rawfile(this.info.icon))
          .width(45)
          .aspectRatio(1)
          .objectFit(ImageFit.Contain)

        Text(this.info.name)
          .fontSize(25)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_inversion'))
          .copyOption(CopyOptions.LocalDevice)
      }
      .justifyContent(FlexAlign.Start)
      .alignSelf(ItemAlign.Start)


      Scroll() {
        Column() {
          // 命座描述
          Text() {
            ForEach(this.getColorfulTextArrayFromHtmlText(this.info.wiki), item => {
              Span(item.content.replace(/\\n/g, '\n').replace(/\n\n/g, '\n \n'))
                .fontSize(18)
                .fontColor(item.color ? item.color : $r('app.color.primary_text_inversion'))
                .fontStyle(item.italic ? FontStyle.Italic : FontStyle.Normal)
            })
          }
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