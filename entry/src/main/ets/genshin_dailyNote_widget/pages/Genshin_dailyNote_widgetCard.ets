type Expedition = {
  avatarSideIcon: string,
  status: string,
  remainedTime: number
}

type recoveryTime = {
  Day: number,
  Hour: number,
  Minute: number,
  Second: number,
  reached: boolean
}

type transformer = {
  obtained: boolean,
  recoveryTime: recoveryTime,
  noticed: boolean,
  latestJobId: string
}

let storage = new LocalStorage();

@Entry(storage)
@Component
struct Genshin_dailyNote_widgetCard {
  @LocalStorageProp('dimension') dimension: number = 3
  @LocalStorageProp('uid') uid: string = '角色未绑定'
  @LocalStorageProp('loaded') loaded: boolean = false
  @LocalStorageProp('message') message: string = '点击卡片刷新'
  @LocalStorageProp('updateTime') updateTime: number = 0
  @LocalStorageProp('currentResin') currentResin: number = 0
  @LocalStorageProp('maxResin') maxResin: number = 160
  @LocalStorageProp('resinRecoveryTime') resinRecoveryTime: number = 0
  @LocalStorageProp('finishedTaskNum') finishedTaskNum: number = 0
  @LocalStorageProp('totalTaskNum') totalTaskNum: number = 4
  @LocalStorageProp('isExtraTaskRewardReceived') isExtraTaskRewardReceived: boolean = false
  @LocalStorageProp('remainResinDiscountNum') remainResinDiscountNum: number = 3
  @LocalStorageProp('resinDiscountNumLimit') resinDiscountNumLimit: number = 3
  @LocalStorageProp('currentExpeditionNum') currentExpeditionNum: number = 0
  @LocalStorageProp('maxExpeditionNum') maxExpeditionNum: number = 0
  @LocalStorageProp('expeditionsList') expeditionsList: Expedition[] = []
  @LocalStorageProp('obtainedHome') obtainedHome: boolean = false
  @LocalStorageProp('currentHomeCoin') currentHomeCoin: number = 0
  @LocalStorageProp('maxHomeCoin') maxHomeCoin: number = 0
  @LocalStorageProp('homeCoinRecoveryTime') homeCoinRecoveryTime: number = 0
  @LocalStorageProp('transformer') transformer: transformer = null

  aboutToAppear() {
    console.warn(this.dimension.toString())
  }

  getUpdateTime() {
    if (this.updateTime == 0) return '尚未刷新'
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

  getTaskTip() {
    if (this.finishedTaskNum == this.totalTaskNum) {
      if (this.isExtraTaskRewardReceived) return '今日委托任务已全部完成'
      else return '今日委托额外奖励未领取'
    } else {
      return '今日完成的委托数量不足'
    }
  }

  getHomeCoinTip() {
    if (this.currentHomeCoin == this.maxHomeCoin) return '洞天宝钱已存满'
    let dayArray = ['日', '一', '二', '三', '四', '五', '六']
    let timeNow = Date.now()
    let today = new Date()
    let timeFinish = timeNow + this.homeCoinRecoveryTime * 1000
    let finishDate = new Date(timeFinish)
    let thisSunday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (7 - (today.getDay() + 6) % 7 + 1))
    thisSunday.setHours(23, 59, 59, 999)
    if (finishDate.getTime() > thisSunday.getTime()) {
      return '下周' + dayArray[finishDate.getDay()] + '存满'
    }
    if (finishDate.getDay() == today.getDay()) {
      return '今日' + `${finishDate.getHours()}点${finishDate.getMinutes()}分存满`
    }
    return '本周' + dayArray[finishDate.getDay()] + '存满'
  }

  getTransformerRecoveryTotalTime() {
    return this.transformer.recoveryTime.Day * 24 * 60 * 60 + this.transformer.recoveryTime.Hour * 60 * 60 + this.transformer.recoveryTime.Minute * 60 + this.transformer.recoveryTime.Second
  }

  getTransformerRecoveryTip() {
    if (this.transformer.recoveryTime.reached) return '已准备完成'
    let dayArray = ['日', '一', '二', '三', '四', '五', '六']
    let today = new Date()
    let finishDate = new Date(Date.now() + this.getTransformerRecoveryTotalTime() * 1000)
    let thisSunday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (7 - (today.getDay() + 6) % 7 + 1))
    thisSunday.setHours(23, 59, 59, 999)
    if (finishDate.getTime() > thisSunday.getTime()) {
      return '下周' + dayArray[finishDate.getDay()] + '存满'
    }
    if (finishDate.getDay() == today.getDay()) {
      return '今日' + `${finishDate.getHours()}点${finishDate.getMinutes()}分存满`
    }
    return '本周' + dayArray[finishDate.getDay()] + '存满'
  }

  getExpeditionLongestTime() {
    let time: number = 0
    for (let exp of this.expeditionsList) {
      exp.remainedTime = exp.remainedTime < time ? time : exp.remainedTime
    }
    return time
  }

  getExpeditionTip() {
    if (this.getExpeditionLongestTime() == 0) return `共${this.expeditionsList.length}个，已全部完成`
    return `${this.expeditionsList.length}派遣任务个进行中`
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Row() {
        if (this.dimension == 2) {
          Row() {
            Text(`实时便笺`)
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
          Text(`实时便笺·${this.uid}`)
            .height(15)
            .fontSize(12)

          Blank()

          Text(this.loaded ? `上次更新时间: ${this.getUpdateTime()}` : this.message)
            .height(15)
            .fontSize(10)
            .fontColor($r('app.color.sub_text_color'))
            .maxLines(1)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignSelf(ItemAlign.Center)

      Flex({ direction: FlexDirection.Row, justifyContent: this.dimension === 2 ? FlexAlign.Center: FlexAlign.Start }) {
        Flex({ direction: FlexDirection.Column }) {
          Stack() {
            Progress({ value: this.currentResin, total: this.maxResin, type: ProgressType.Ring })
              .style({ strokeWidth: 14, scaleCount: 160, scaleWidth: 18 })
              .color('#8A2BE2')
              .opacity(0.6)
              .blur(40)
              .height('100%')
              .aspectRatio(1)
              .borderRadius(200)
              .clip(true)
            Column() {
              Text() {
                Span(`${this.currentResin}`)
                  .fontSize(30)
                  .fontColor($r('app.color.high_light_text_color'))
                Span('/')
                  .fontSize(12)
                  .fontColor($r('app.color.stroke_line_color'))
                Span(`${this.maxResin}`)
                  .fontSize(12)
                  .fontColor($r('app.color.sub_text_color'))
              }
              Row() {
                Image($rawfile('GI/resource/106/UI_ItemIcon_210.webp'))
                  .height(18)
                  .aspectRatio(1)
                Text('原脆树脂')
                  .fontColor($r('app.color.call_color'))
                  .fontSize(12)
              }
              .alignItems(VerticalAlign.Center)
            }
          }
          .height('100%')
          .width('100%')
          .alignContent(Alignment.Center)
          .flexShrink(1)

          Row() {
            if (this.currentResin !== this.maxResin) {
              Text() {
                Span(`${Math.floor(this.resinRecoveryTime / 3600)}`)
                  .fontColor($r('app.color.high_light_text_color'))
                Span(' 小时 ')
                  .fontColor($r('app.color.sub_text_color'))
                  .fontSize(12)
                Span(`${Math.floor(this.resinRecoveryTime / 60) % 60}`)
                  .fontColor($r('app.color.call_color'))
                Span(' 分钟 ')
                  .fontColor($r('app.color.sub_text_color'))
                  .fontSize(12)
              }
              Text('后完全恢复')
                .fontSize(12)
                .fontColor($r('app.color.sub_text_color'))
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
          .height(18)
          .width('100%')
          .alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.SpaceBetween)
          .flexShrink(0)
        }
        .height('100%')
        .aspectRatio(1)
        .flexShrink(0)

        if (this.dimension > 2) {
          List({ space: 6 }) {
            ListItem() {
              Row({ space: 5 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Progress({ value: this.finishedTaskNum, total: this.totalTaskNum, type: ProgressType.Ring })
                    .color($r('app.color.call_color'))
                    .height(30)
                    .borderRadius(15)
                  Image($rawfile('GI/resource/others/Task_Icon.png'))
                    .height(20)
                    .aspectRatio(1)
                }

                Column() {
                  Text() {
                    Span(`${this.finishedTaskNum}`)
                      .fontColor($r('app.color.text_color'))
                      .fontSize(12)
                    Span('/')
                      .fontColor($r('app.color.stroke_line_color'))
                      .fontSize(12)
                    Span(`${this.totalTaskNum}`)
                      .fontColor($r('app.color.sub_text_color'))
                      .fontSize(12)
                  }
                  Text(this.loaded ? this.getTaskTip() : '')
                    .fontColor($r('app.color.text_color'))
                    .fontSize(11)
                    .maxLines(1)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start)
              }
            }
            if (this.obtainedHome) {
              ListItem() {
                Row({ space: 5 }) {
                  Stack({ alignContent: Alignment.Center }) {
                    Progress({ value: this.currentHomeCoin, total: this.maxHomeCoin, type: ProgressType.Ring })
                      .color($r('app.color.call_color'))
                      .height(30)
                      .borderRadius(15)
                    Image($rawfile('GI/resource/204/UI_ItemIcon_204.webp'))
                      .height(25)
                      .aspectRatio(1)
                  }

                  Column() {
                    Text() {
                      Span(`${this.currentHomeCoin}`)
                        .fontColor($r('app.color.text_color'))
                        .fontSize(12)
                      Span('/')
                        .fontColor($r('app.color.stroke_line_color'))
                        .fontSize(12)
                      Span(`${this.maxHomeCoin}`)
                        .fontColor($r('app.color.sub_text_color'))
                        .fontSize(12)
                    }
                    Text(this.loaded ? this.getHomeCoinTip() : '')
                      .fontColor($r('app.color.text_color'))
                      .fontSize(11)
                      .maxLines(1)
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(HorizontalAlign.Start)
                }
              }
            }
            ListItem() {
              Row({ space: 5 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Progress({ value: this.resinDiscountNumLimit - this.remainResinDiscountNum, total: this.resinDiscountNumLimit, type: ProgressType.Ring })
                    .color($r('app.color.call_color'))
                    .height(30)
                    .borderRadius(15)
                  Image($rawfile('GI/resource/others/征讨领域.png'))
                    .height(20)
                    .aspectRatio(1)
                }

                Column() {
                  Text() {
                    Span(`${this.resinDiscountNumLimit - this.remainResinDiscountNum}`)
                      .fontColor($r('app.color.text_color'))
                      .fontSize(12)
                    Span('/')
                      .fontColor($r('app.color.stroke_line_color'))
                      .fontSize(12)
                    Span(`${this.resinDiscountNumLimit}`)
                      .fontColor($r('app.color.sub_text_color'))
                      .fontSize(12)
                  }
                  Text('本周树脂减半已使用次数')
                    .fontColor($r('app.color.text_color'))
                    .fontSize(11)
                    .maxLines(1)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start)
              }
            }
            if (this.transformer.obtained) {
              ListItem() {
                Row({ space: 5 }) {
                  Stack({ alignContent: Alignment.Center }) {
                    Progress({ value: 7 * 24 * 60 * 60 - this.getTransformerRecoveryTotalTime(), total: 7 * 24 * 60 * 60, type: ProgressType.Ring })
                      .color($r('app.color.call_color'))
                      .height(30)
                      .borderRadius(15)
                    Image($rawfile('GI/resource/220021/UI_ItemIcon_220021.webp'))
                      .height(25)
                      .aspectRatio(1)
                  }

                  Column() {
                    Text() {
                      Span(`${this.transformer.recoveryTime.Day}`)
                        .fontColor($r('app.color.text_color'))
                        .fontSize(12)
                      Span('天')
                        .fontColor($r('app.color.sub_text_color'))
                        .fontSize(12)
                      Span(`${this.transformer.recoveryTime.Hour}`)
                        .fontColor($r('app.color.text_color'))
                        .fontSize(12)
                      Span('小时')
                        .fontColor($r('app.color.sub_text_color'))
                        .fontSize(12)
                      Span(`${this.transformer.recoveryTime.Minute}`)
                        .fontColor($r('app.color.text_color'))
                        .fontSize(12)
                      Span('分钟 后完全恢复')
                        .fontColor($r('app.color.sub_text_color'))
                        .fontSize(12)
                    }
                    Text(this.getTransformerRecoveryTip())
                      .fontColor($r('app.color.text_color'))
                      .fontSize(11)
                      .maxLines(1)
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(HorizontalAlign.Start)
                }
              }
            }
            ListItem() {
              Row({ space: 5 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Progress({ value: 20 * 60 * 60 - this.getExpeditionLongestTime(), total: 20 * 60 * 60, type: ProgressType.Ring })
                    .color($r('app.color.call_color'))
                    .height(30)
                    .borderRadius(15)
                  Image($rawfile('GI/resource/others/派遣.png'))
                    .height(20)
                    .aspectRatio(1)
                }

                Column() {
                  Text() {
                    Span(`${this.getExpeditionLongestTime() / 60 / 60}`)
                      .fontColor($r('app.color.text_color'))
                      .fontSize(12)
                    Span('小时')
                      .fontColor($r('app.color.sub_text_color'))
                      .fontSize(12)
                    Span(`${this.getExpeditionLongestTime() / 60 % 60}`)
                      .fontColor($r('app.color.text_color'))
                      .fontSize(12)
                    Span('分钟 后全部完成')
                      .fontColor($r('app.color.sub_text_color'))
                      .fontSize(12)
                  }
                  Text(this.getExpeditionTip())
                    .fontColor($r('app.color.text_color'))
                    .fontSize(11)
                    .maxLines(1)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start)
              }
            }
          }
          .height(140)
          .borderRadius(10)
          .flexShrink(1)
          .clip(true)
          .margin({ left: 10 })
        }
      }
      .width('100%')
      .height('100%')
      .margin({ top: 6 })
      .flexShrink(1)

      if (this.dimension > 3) {
        Text('暂不支持查看派遣详情')
          .fontSize(20)
          .margin({ top: 20 })
      }
    }
    .height('100%')
    .width('100%')
    .clip(true)
    .padding(10)
    .backdropBlur(100)
    .onClick(() => {
      console.warn('card clicked')
      postCardAction(this, {
        'action': 'message',
        'params': {
          'update': true
        }
      });
    })
  }
}