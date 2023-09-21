/**
 * @FileName: GI_DailyNoteCard
 * @Author: Administrator
 * @Date: 2023/5/31 17:26
 * Description: 原神体力卡片
 */

import GI_DailyNoteInfo from '../../../viewmodel/page/Index/GI_DailyNoteInfo'
import promptAction from '@ohos.promptAction'
import router from '@ohos.router'

@Component
export default struct GI_DailyNoteCard {
  @Link data: GI_DailyNoteInfo
  @Link isUpdating: boolean


  getUpdateTime() {
    if (this.data.updateTime == 0) return ''
    let date = new Date(this.data.updateTime);

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
    if (this.data.finishedTaskNum == this.data.totalTaskNum) {
      if (this.data.isExtraTaskRewardReceived) return '今日委托任务已全部完成'
      else return '今日委托额外奖励未领取'
    } else {
      return '今日完成的委托数量不足'
    }
  }

  getHomeCoinTip() {
    if (this.data.currentHomeCoin == this.data.maxHomeCoin) return '洞天宝钱已存满'
    let dayArray = ['日', '一', '二', '三', '四', '五', '六']
    let timeNow = Date.now()
    let today = new Date()
    let timeFinish = timeNow + this.data.homeCoinRecoveryTime * 1000
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
    return this.data.transformer.recoveryTime.Day * 24 * 60 * 60 + this.data.transformer.recoveryTime.Hour * 60 * 60 + this.data.transformer.recoveryTime.Minute * 60 + this.data.transformer.recoveryTime.Second
  }

  getTransformerRecoveryTip() {
    if (this.data.transformer.recoveryTime.reached) return '已准备完成'
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
    for (let exp of this.data.expeditionsList) {
      exp.remainedTime = exp.remainedTime < time ? time : exp.remainedTime
    }
    return time
  }

  getExpeditionTip() {
    if (this.getExpeditionLongestTime() == 0) return `共${this.data.expeditionsList.length}个，已全部完成`
    return `${this.data.expeditionsList.length}派遣任务个进行中`
  }

  build() {
    Column() {
      Row() {
        Text('实时便笺')
          .height(20)
        LoadingProgress()
          .color($r('app.color.text_color'))
          .height(20)
          .aspectRatio(1)
          .visibility(this.isUpdating ? Visibility.Visible : Visibility.Hidden)

        Blank()

        Text(`上次更新时间: ${this.getUpdateTime()}`)
          .height(20)
          .fontSize(10)
          .fontColor($r('app.color.sub_text_color'))
          .margin({ right: 10 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignSelf(ItemAlign.Center)
      .margin({ left: 10, bottom: 10 })

      Flex({ direction: FlexDirection.Row }) {
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Progress({ value: this.data.currentResin, total: this.data.maxResin, type: ProgressType.Ring })
              .color($r('app.color.purple_color'))
              .height(130)
              .aspectRatio(1)
              .borderRadius(65)
              .style({ strokeWidth: 13, scaleCount: 160, scaleWidth: 18 })
              .opacity(0.8)
              .blur(40)
            Column() {
              Text() {
                Span(`${this.data.currentResin}`)
                  .fontSize(40)
                  .fontColor($r('app.color.high_light_text_color'))
                Span('/')
                  .fontSize(12)
                  .fontColor($r('app.color.stroke_line_color'))
                Span(`${this.data.maxResin}`)
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
          Row() {
            Text() {
              Span(`${Math.floor(this.data.resinRecoveryTime / 3600)}`)
                .fontColor($r('app.color.high_light_text_color'))
              Span(' 小时 ')
                .fontColor($r('app.color.sub_text_color'))
                .fontSize(12)
              Span(`${Math.floor(this.data.resinRecoveryTime / 60) % 60}`)
                .fontColor($r('app.color.call_color'))
              Span(' 分钟 ')
                .fontColor($r('app.color.sub_text_color'))
                .fontSize(12)
            }
            Text('后完全恢复')
              .fontSize(12)
          }
          .alignItems(VerticalAlign.Bottom)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width(150)
        .flexShrink(0)

        List({ space: 8 }) {
          ListItem() {
            Row({ space: 5 }) {
              Stack({ alignContent: Alignment.Center }) {
                Progress({ value: this.data.finishedTaskNum, total: this.data.totalTaskNum, type: ProgressType.Ring })
                  .color($r('app.color.call_color'))
                  .height(30)
                  .borderRadius(15)
                Image($rawfile('GI/resource/others/Task_Icon.png'))
                  .height(20)
                  .aspectRatio(1)
              }

              Column() {
                Text() {
                  Span(`${this.data.finishedTaskNum}`)
                    .fontColor($r('app.color.text_color'))
                    .fontSize(12)
                  Span('/')
                    .fontColor($r('app.color.stroke_line_color'))
                    .fontSize(12)
                  Span(`${this.data.totalTaskNum}`)
                    .fontColor($r('app.color.sub_text_color'))
                    .fontSize(12)
                }
                Text(this.data ? this.getTaskTip() : '')
                  .fontColor($r('app.color.text_color'))
                  .fontSize(11)
                  .maxLines(1)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                promptAction.showToast({
                  message: this.getTaskTip()
                })
              })
            }
          }
          if (this.data.obtainedHome) {
            ListItem() {
              Row({ space: 5 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Progress({ value: this.data.currentHomeCoin, total: this.data.maxHomeCoin, type: ProgressType.Ring })
                    .color($r('app.color.call_color'))
                    .height(30)
                    .borderRadius(15)
                  Image($rawfile('GI/resource/204/UI_ItemIcon_204.webp'))
                    .height(25)
                    .aspectRatio(1)
                }

                Column() {
                  Text() {
                    Span(`${this.data.currentHomeCoin}`)
                      .fontColor($r('app.color.text_color'))
                      .fontSize(12)
                    Span('/')
                      .fontColor($r('app.color.stroke_line_color'))
                      .fontSize(12)
                    Span(`${this.data.maxHomeCoin}`)
                      .fontColor($r('app.color.sub_text_color'))
                      .fontSize(12)
                  }
                  Text(this.data ? this.getHomeCoinTip() : '')
                    .fontColor($r('app.color.text_color'))
                    .fontSize(11)
                    .maxLines(1)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start)
                .onClick(() => {
                  promptAction.showToast({
                    message: this.getHomeCoinTip()
                  })
                })
              }
            }
          }
          ListItem() {
            Row({ space: 5 }) {
              Stack({ alignContent: Alignment.Center }) {
                Progress({ value: this.data.resinDiscountNumLimit - this.data.remainResinDiscountNum, total: this.data.resinDiscountNumLimit, type: ProgressType.Ring })
                  .color($r('app.color.call_color'))
                  .height(30)
                  .borderRadius(15)
                Image($rawfile('GI/resource/others/征讨领域.png'))
                  .height(20)
                  .aspectRatio(1)
              }

              Column() {
                Text() {
                  Span(`${this.data.resinDiscountNumLimit - this.data.remainResinDiscountNum}`)
                    .fontColor($r('app.color.text_color'))
                    .fontSize(12)
                  Span('/')
                    .fontColor($r('app.color.stroke_line_color'))
                    .fontSize(12)
                  Span(`${this.data.resinDiscountNumLimit}`)
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
              .onClick(() => {
                promptAction.showToast({
                  message: '本周树脂减半已使用次数'
                })
              })
            }
          }
          if (this.data.transformer.obtained) {
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
                    Span(`${this.data.transformer.recoveryTime.Day}`)
                      .fontColor($r('app.color.text_color'))
                      .fontSize(12)
                    Span('天')
                      .fontColor($r('app.color.sub_text_color'))
                      .fontSize(12)
                    Span(`${this.data.transformer.recoveryTime.Hour}`)
                      .fontColor($r('app.color.text_color'))
                      .fontSize(12)
                    Span('小时')
                      .fontColor($r('app.color.sub_text_color'))
                      .fontSize(12)
                    Span(`${this.data.transformer.recoveryTime.Minute}`)
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
                .onClick(() => {
                  promptAction.showToast({
                    message: this.getTransformerRecoveryTip()
                  })
                })
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
              .onClick(() => {
                promptAction.showToast({
                  message: this.getExpeditionTip()
                })
              })
            }
          }
        }
        .height(150)
        .borderRadius(10)
        .flexShrink(1)
        .clip(true)
        .margin({ left: 10 })
      }
      .width('100%')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(16)
    .clip(true)
    .backdropBlur(40)
    .padding(10)
    .onClick(() => {
      if (globalThis.SelUser && globalThis.SelGIRole) {
        router.pushUrl({
          url: 'pages/GI_DailyNote'
        })
      }
    })
  }
}