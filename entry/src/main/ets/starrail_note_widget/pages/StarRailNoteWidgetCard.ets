let HSR_storage = new LocalStorage();

@Entry(HSR_storage)
@Component
struct StarRailNoteWidgetCard {
  @LocalStorageProp('dimension') dimension: number = 3
  @LocalStorageProp('uid') uid: string = '角色未绑定'
  @LocalStorageProp('loaded') loaded: boolean = false
  @LocalStorageProp('message') message: string = '点击卡片刷新'
  @LocalStorageProp('updateTime') updateTime: number = 0
  @LocalStorageProp('current_stamina') current_stamina: number = 0
  @LocalStorageProp('max_stamina') max_stamina: number = 240
  @LocalStorageProp('stamina_recover_time') stamina_recover_time: number = 0
  @LocalStorageProp('accepted_epedition_num') accepted_epedition_num: number = 0
  @LocalStorageProp('total_expedition_num') total_expedition_num: number = 4
  @LocalStorageProp('current_train_score') current_train_score: number = 0
  @LocalStorageProp('max_train_score') max_train_score: number = 500
  @LocalStorageProp('current_rogue_score') current_rogue_score: number = 0
  @LocalStorageProp('max_rogue_score') max_rogue_score: number = 14000
  @LocalStorageProp('weekly_cocoon_cnt') weekly_cocoon_cnt: number = 3
  @LocalStorageProp('weekly_cocoon_limit') weekly_cocoon_limit: number = 3
  @LocalStorageProp('current_reserve_stamina') current_reserve_stamina: number = 0
  @LocalStorageProp('is_reserve_stamina_full') is_reserve_stamina_full: boolean = false

  getUpdateTime() {
    if (this.updateTime == 0) return ''
    let date = new Date(this.updateTime);

    let year = date.getFullYear(); // 获取年份
    let month = date.getMonth() + 1; // 获取月份，注意要加上 1
    let day = date.getDate(); // 获取日期
    let hour = date.getHours(); // 获取小时
    let minute = date.getMinutes(); // 获取分钟
    let second = date.getSeconds(); // 获取秒数

    let localTime: string = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')} ${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}:${second.toString().padStart(2, '0')}`;

    return localTime
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Row() {
        if (this.dimension === 2) {
          Row() {
            Text(`HSR·实时便笺`)
              .height(15)
              .fontSize(12)

            Text(`${this.uid}`)
              .height(15)
              .fontSize(12)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        if (this.dimension > 2) {
          Text(`HSR·实时便笺·${this.uid}`)
            .height(15)
            .fontSize(12)

          Blank()

          Text(`上次更新时间: ${this.getUpdateTime()}`)
            .height(20)
            .fontSize(10)
            .fontColor($r('app.color.sub_text_color'))
            .margin({ right: 10 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignSelf(ItemAlign.Center)
      .flexShrink(0)

      Flex({ direction: FlexDirection.Row, justifyContent: this.dimension === 2 ? FlexAlign.Center: FlexAlign.Start }) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Stack() {
            Row()
              .height('100%')
              .width(`${this.current_stamina / this.max_stamina * 100}%`)
              .backgroundColor($r('app.color.purple_color'))
              .opacity(0.7)
            Row({ space: 10 }) {
              Column() {
                Image($rawfile('HSR/resource/others/开拓力.png'))
                  .height(40)
                  .aspectRatio(1)
                Text('开拓力')
                  .fontSize(15)
                  .fontColor($r('app.color.text_color'))
                  .fontWeight(FontWeight.Bold)
              }
              .margin({ left: 5 })

              Text() {
                Span(`${this.current_stamina}`)
                  .fontSize(25)
                  .fontColor($r('app.color.high_light_text_color'))
                Span(`/${this.max_stamina}`)
                  .fontSize(12)
                  .fontColor($r('app.color.sub_text_color'))
              }
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height(65)
          .borderRadius(10)
          .clip(true)
          .alignContent(Alignment.Start)
          .flexShrink(0)
          .borderWidth(1)
          .borderColor($r('app.color.stroke_line_color'))

          Row() {
            if (this.current_stamina !== this.max_stamina) {
              Column() {
                Text() {
                  Span(`${Math.floor(this.stamina_recover_time / 3600)}`)
                    .fontColor($r('app.color.sub_text_color'))
                    .fontSize(12)
                  Span(' 小时 ')
                    .fontColor($r('app.color.sub_text_color'))
                    .fontSize(12)
                  Span(`${Math.floor(this.stamina_recover_time / 60) % 60}`)
                    .fontColor($r('app.color.sub_text_color'))
                    .fontSize(12)
                  Span(' 分钟 ')
                    .fontColor($r('app.color.sub_text_color'))
                    .fontSize(12)
                }
                Text('后完全恢复')
                  .fontSize(12)
                  .fontColor($r('app.color.sub_text_color'))
              }
              .width('100%')
            } else {
              Row() {
                Text('已全部恢复')
                  .fontSize(12)
                  .fontColor($r('app.color.sub_text_color'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
          }
          .height(36)
          .width('100%')
          .alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.SpaceBetween)
          .flexShrink(0)

          Row() {
            Row() {
              Image($rawfile('HSR/resource/others/后备开拓力.png'))
                .height(15)
                .aspectRatio(1)
              Text('后备开拓力')
                .fontSize(13)
                .fontColor($r('app.color.text_color'))
            }

            Text(`${this.current_reserve_stamina}${this.is_reserve_stamina_full ? '(已达上限)' : ''}`)
              .fontSize(13)
              .fontColor($r('app.color.sub_text_color'))
          }
          .height('100%')
          .width('100%')
          .alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.SpaceAround)
          .flexShrink(1)
        }
        .height('100%')
        .aspectRatio(1)
        .flexShrink(0)
        .borderRadius(10)
        .clip(true)

        if (this.dimension === 3) {
          Column() {
            Row() {
              Text('每日实训')
                .fontSize(13)
                .fontColor($r('app.color.text_color'))
                .fontWeight(FontWeight.Bold)
              Text() {
                Span(`${this.current_train_score}`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_color'))
                Span('/')
                  .fontSize(13)
                  .fontColor($r('app.color.stroke_line_color'))
                Span(`${this.max_train_score}`)
                  .fontSize(13)
                  .fontColor($r('app.color.sub_text_color'))
              }
            }
            .width('100%')
            .height('25%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('委托任务')
                .fontSize(13)
                .fontColor($r('app.color.text_color'))
                .fontWeight(FontWeight.Bold)
              Text() {
                Span(`${this.accepted_epedition_num}`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_color'))
                Span('/')
                  .fontSize(13)
                  .fontColor($r('app.color.stroke_line_color'))
                Span(`${this.total_expedition_num}`)
                  .fontSize(13)
                  .fontColor($r('app.color.sub_text_color'))
              }
            }
            .width('100%')
            .height('25%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('模拟宇宙')
                .fontSize(13)
                .fontColor($r('app.color.text_color'))
                .fontWeight(FontWeight.Bold)
              Text() {
                Span(`${this.current_rogue_score}`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_color'))
                Span('/')
                  .fontSize(13)
                  .fontColor($r('app.color.stroke_line_color'))
                Span(`${this.max_rogue_score}`)
                  .fontSize(13)
                  .fontColor($r('app.color.sub_text_color'))
              }
            }
            .width('100%')
            .height('25%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('历战余响')
                .fontSize(13)
                .fontColor($r('app.color.text_color'))
                .fontWeight(FontWeight.Bold)
              Text() {
                Span(`${3 - this.weekly_cocoon_cnt}`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_color'))
                Span('/')
                  .fontSize(13)
                  .fontColor($r('app.color.stroke_line_color'))
                Span(`${this.weekly_cocoon_limit}`)
                  .fontSize(13)
                  .fontColor($r('app.color.sub_text_color'))
              }
            }
            .width('100%')
            .height('25%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .height('100%')
          .borderRadius(10)
          .flexShrink(1)
          .clip(true)
          .padding(5)
          .margin({ left: 10 })
        }
      }
      .width('100%')
      .height('100%')
      .margin({ top: 6 })
      .flexShrink(1)
    }
    .width('100%')
    .height('100%')
    .borderRadius(16)
    .clip(true)
    .padding(10)
    .onClick(() => {
      console.warn('card clicked')
      postCardAction(this, {
        'action': 'message',
        'params': {
          'name': 'StarRailNote',
          'update': true
        }
      });
    })
  }
}