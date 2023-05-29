/**
 * @FileName: PageBackButton
 * @Author: Administrator
 * @Date: 2023/5/26 16:59
 * Description:
 */

import router from '@ohos.router'

@Component
export default struct PageBackButton {
  build() {
    Button() {
      Column() {
        Image($r('app.media.ic_public_back'))
          .height('64%')
          .aspectRatio(1)
          .onClick(() => {
            router.back()
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .type(ButtonType.Normal)
    .backgroundColor('#00000000')
    .height('100%')
    .aspectRatio(1)
    .borderRadius(8)
    .clip(true)
  }
}