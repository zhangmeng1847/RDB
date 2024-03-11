import router from '@ohos.router'
import TaskStatistics from '../views/TaskStatistics'
import TaskList from '../views/TaskList'

@Entry
@Component
struct TaskManagerPage {
  // 总任务数
  @State totalTask: number = 0
  // 已完成任务数
  @State finishTask: number = 0

  build() {
    Column({space: 10}){
      // 1. 头部视图
      this.Header()
      // 2. 任务进度视图
      TaskStatistics({totalTask: this.totalTask, finishTask: this.finishTask})
      // 3. 任务列表
      TaskList({totalTask: $totalTask, finishTask: $finishTask})
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F2F3')
  }


  @Builder Header(){
    // 标题部分
    Row({space: 5}){
      Image($r('app.media.back'))
        .width(30)
        .onClick(() => {
          // 返回上一页
          router.back()
        })
      Text('任务列表管理')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(30)
  }
}