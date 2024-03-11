import router from '@ohos.router'
@Entry
@Component
struct Index {
  @State message: string = '点击进入任务列表'

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(25)
          .width('70%')
          .textAlign(TextAlign.Center)
          .padding(5)
          .borderColor('#36D')
          .borderWidth(1)
          .borderRadius(10)
          .onClick(() => {
            router.pushUrl(
              {url:'pages/TaskManagerPage'},
              router.RouterMode.Single,
              err => {
                if (err) {
                  console.log(`跳转失败，errCode: ${err.code} errMsg:${err.message}`)
                }
              })
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}