HarmonyOS标准系统支持典型的存储数据形态，其中关系型数据库是比较常见的一种复杂数据结构存储的方式。HarmonyOS中关系型数据库基于SQLite组件，适用于存储包含复杂关系数据的场景，比如一个班级的学生信息，需要包括姓名、学号、各科成绩等。
### 一、关系型数据库运行机制介绍
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e4b9d4c2649744368c459f24f709c6b8~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=311&h=381&s=74391&e=png&b=eae9e9)

在HarmonyOS中对关系型数据库的使用封装好了通用的操作接口，底层使用SQLite作为持久化存储引擎，支持SQLite具有的数据库特性，包括但不限于事务、索引、视图、触发器、外键、参数化查询和预编译SQL语句。
###### ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/20ca95e499f545d28ee488b9460c9320~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1164&h=746&s=329343&e=png&b=1f1f1f)

一个应用中可以有多个关系型数据库，存储在应用沙箱中，通过数据数据库框架进行数据库文件的操作，HarmonyOS通过封装ArkTS接口供上层应用进行调用。
### 二、关系型数据库常用API
#### 1. 初始化数据库
##### 1.1 导入关系型数据库模块
```ts
import relationalStore from '@ohos.data.relationalStore'; // 导入模块 
```
##### 1.2 初始化数据库表
```ts
// 1. rdb相关配置
const config = {
  name: 'MyRdb.db', // 数据库文件名
  securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
};

// 2. 初始化表的SQL(以学员表举例，包含：id、姓名、年龄、分数)
const sql = 'CREATE TABLE IF NOT EXISTS STUDENT (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, AGE INTEGER, SCORE REAL)'; // 建表Sql语句

// 3. 获取rdb
relationalStore.getRdbStore(this.context, config, (err, store) => {
  //获取失败
  if (err) {
    console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
    return;
  }
  //获取成功
  console.info(`Succeeded in getting RdbStore.`);
  // 创建数据表，executeSql执行sql语句的方法
  store.executeSql(sql); 
  
  // 这里执行数据库的增、删、改、查等操作
  
});
```
上述代码是建立数据库后，通过执行Sql语句的形式进行建表操作。其实在HarmonyOS中提供了一系列封装好的方法进行数据库的操作，接下来的其他示例，将通过HarmonyOS自带的操作方法进行
#### 2. 实现数据的增、删、改操作
##### 2.1 新增数据
```ts
// 1. 准备要新增的数据
let student = {id: 1, name: '学生1', age: '18', score: 100.0}
// 2. 新增
this.rdbStore.insert(this.tableName, student)
```
##### 2.2 修改数据
```ts
// 1. 查询条件
let predicates = new reationalStore.RdbPredicates(this.tableName)
//匹配要修改记录的id
predicates.equalTo('ID', id)
// 2. 执行删除
this.rdbStore.delete(predicates)
```
#### 3. 实现数据的查询
##### 3.1 查询数据
```ts
// 1. 查询条件
let predicates = new reationalStore.RdbPredicates(this.tableName)
// 2. 执行查询
let result = await this.rdbStore.query(predicates, ['ID', 'NAME', 'AGE'])
```
##### 3.2 解析数据
```
// 1. 准备集合存放查询到的数据
let resultData: any[] = []
// 2. 循环遍历结果集
while(!result.isAtLastRow) {
  result.goToNextRow()
  let id = result.getLong(result.getColumnIndex('ID'))
  let name = result.getString(result.getColumnIndex('Name'))
  let age = result.getLong(result.getColumnIndex('AGE'))
  resultData.push({id,name,age})
}
```
### 三、关系型数据库使用案例
该案例实现效果如下：
[jvideo](https://www.ixigua.com/7344914695632977974)
具体实现步骤如下：
#### UI布局搭建
![www.alltoall.net_qq20240311-133556-hd_o8Q2_PZmsC.gif](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7e027d3e59b34ca0bc1de6408c5327f1~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=664&h=1392&s=381827&e=gif&f=24&b=fffefd)
##### 1. 第一个界面具体代码如下：
```ts
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
          //页面路由跳转，跳转至任务管理界面，需要引入@ohos.router
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
```
#### 2. 实现任务任务管理界面代码TaskManagerPage

```ts
import router from '@ohos.router'
import TaskStatistics from '../views/TaskStatistics'  //自定义任务数据统计界面
import TaskList from '../views/TaskList' //自定义任务列表页面

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

  //头部视图，@Builder表示自定义构建函数，所装饰的函数遵循build()函数语法规则
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
```
##### 2.1 实现自定义视图任务统计组件代码TaskStatistics

```ts
// 统一的卡片样式,@Styles装饰器可以快速定义并复用自定义样式,用于快速定义并复用自定义样式。
@Styles function card(){
  .width('95%')
  .padding(20)
  .backgroundColor(Color.White)
  .borderRadius(15)
  .shadow({radius: 6, color: '#1F000000', offsetX: 2, offsetY: 4})
}

@Component
export default struct TaskStatistics {
  //@Prop修饰符表示单向同步、父组件中修改数据，会同步到子组件，但是子组件修改数据，父组件中不会同步，底层实现的是传递的父组件中的变量的拷贝。不能在@entry修饰的组件中定义
  @Prop totalTask: number  //展示父视图传递过来的总任务数据，数据变化影响当前视图
  @Prop finishTask: number //展示父视图传递过来的已完成任务数据，，数据变化影响当前视图

  build() {
    Row(){
      Text('任务进度：')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      Stack(){
        Progress({
          value: this.finishTask,
          total: this.totalTask,
          type: ProgressType.Ring
        })
          .width(100)
        Row(){
          Text(this.finishTask.toString())
            .fontSize(24)
            .fontColor('#36D')
          Text(' / ' + this.totalTask.toString())
            .fontSize(24)
        }
      }
    }
    .card()
    .margin({top: 5, bottom: 10})
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}
```
##### 2.2 实现任务列表UI

```ts
import TaskDataModel from '../models/TaskDataModel'
import TaskItem from './TaskItem'

@Component
export default struct TaskList {
  // 总任务数量，@Link表示与父组件双向同步状态，子组件修改值之后父组件的值也会响应修改
  @Link totalTask: number
  // 已完成任务数量
  @Link finishTask: number
  // 任务数组
  @State tasks: TaskDataModel[] = []

  idx: number = 1
  // 任务信息弹窗
  dialogController: CustomDialogController = new CustomDialogController({
    builder: TaskInfoDialog({onTaskConfirm: this.handleAddTask.bind(this)}),
  })

  aboutToAppear(){
    // 查询任务列表
    console.log('testTag', '初始化组件，查询任务列表')
    // 查询数据库任务列表，从数据库中取出任务数据展示在界面上
    TaskHandle.getTaskList()
       .then(tasks => {
         this.tasks = tasks
         // 更新任务状态
         this.handleTaskChange()
       })
  }

  handleTaskChange(){
    // 1.更新任务总数量
    this.totalTask = this.tasks.length
    // 2.更新已完成任务数量
    this.finishTask = this.tasks.filter(item => item.finished).length
  }

  handleAddTask(name: string){
    // 1. 新增任务
    TaskHandle.addTask(name)
      .then(id => {
        console.log('testTag', '处理新增任务: ', name)
        // 回显到数组页面
        this.tasks.push(new TaskDataModel(id, name))
        // 2.更新任务完成状态
        this.handleTaskChange()
        // 3.关闭对话框
        this.dialogController.close()
      })
      .catch(error => console.log('testTag', '新增任务失败：', name, JSON.stringify(error)))

    // 1.新增任务
    // 回显到数组页面
    this.tasks.push(new TaskDataModel(this.idx++, name))
    // 2.更新任务完成状态
    this.handleTaskChange()
    // 3.关闭对话框
    this.dialogController.close()
  }

  build() {
    Column(){
      // 1.新增任务按钮
      Button('新增任务')
        .width(200)
        .margin({bottom: 10})
        .onClick(() => {
          // 打开新增表单对话框
          this.dialogController.open()
        })

      // 2.任务列表
      List({space: 10}){
        ForEach(
          this.tasks,
          (item: TaskDataModel, index) => {
            ListItem(){
              TaskItem({item: item, onTaskChange: this.handleTaskChange.bind(this)})
            }
            .swipeAction({end: this.DeleteButton(index, item.id)})
          }
        )
      }
      .width('100%')
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
    }
  }

  @Builder DeleteButton(index: number, id: number){
    Button(){
      Image($r('app.media.delete'))
        .fillColor(Color.White)
        .width(20)
    }
    .width(40)
    .height(40)
    .type(ButtonType.Circle)
    .backgroundColor(Color.Red)
    .margin(5)
    .onClick(() => {
      // 删除任务同步到数据库
      TaskHandle.deleteTaskById(id)
        .then(() => {
          this.tasks.splice(index, 1)
          console.log('testTag', `尝试删除任务，index: ${index}`)
          this.handleTaskChange()
        })
        .catch(error => console.log('testTag', '删除任务失败，id = ', id, JSON.stringify(error)))
    })
  }
}
//自定义弹窗使用@CustomDialog修饰
@CustomDialog
struct TaskInfoDialog{
  name: string = ''
  onTaskConfirm : (name: string) => void
  controller: CustomDialogController

  build(){
    Column({space: 20}){
      TextInput({placeholder: '输入任务名'})
        .onChange(val => this.name = val)
      Row(){
        Button('确定')
          .onClick(() => {
            this.onTaskConfirm(this.name)
          })
        Button('取消')
          .backgroundColor(Color.Grey)
          .onClick(() => {
            this.controller.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(20)
  }
}
```
##### 2.3 任务数据模型类实现TaskDataModel

```ts
// 被@Observed装饰的类，可以被观察到属性的变化
// 单独使用@Observed是没有任何作用的，需要搭配@ObjectLink或者@Prop使用
@Observed
export default class TaskDataModel{
  id: number
  // 任务名称
  name: string
  // 任务状态：是否完成
  finished: boolean

  constructor(id: number, name: string) {
    this.id = id
    this.name = name
    this.finished = false
  }
}
```
##### 2.4 任务列表中单个任务组件TaskItem

```ts
import TaskHandle from '../viewmodels/TaskHandle'
import TaskDataModel from '../models/TaskDataModel'

@Component
export default struct TaskItem {
  // 子组件中@ObjectLink装饰器装饰的状态变量用于接收@Observed装饰的类的实例，和父组件中对应的状态变量建立双向数据绑定
  @ObjectLink item: TaskDataModel
  onTaskChange: (item: TaskDataModel) => void

  build() {
    Row(){
      if(this.item.finished){
        Text(this.item.name)
          .finishedTask()
      }else{
        Text(this.item.name)
      }
      Checkbox()
        .select(this.item.finished)
        .onChange(async val => {
          // 1.更新当前任务状态
          this.item.finished = val
          // 2.更新已完成任务数量,更新任务状态到数据库
          TaskHandle.updateTaskStatus(this.item.id, val)
            .then(() => {
              this.item.finished = val
              // 2.更新已完成任务数量
              this.onTaskChange(this.item)
            })
            .catch(error => console.log('testTag', '更新任务状态失败, id = ', this.item.id, JSON.stringify(error)))
        })
    }
    .card()
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

// 任务完成样式
@Extend(Text) function finishedTask(){
  .decoration({type:TextDecorationType.LineThrough})
  .fontColor('#B1B2B1')
}

// 统一的卡片样式
@Styles function card(){
  .width('95%')
  .padding(20)
  .backgroundColor(Color.White)
  .borderRadius(15)
  .shadow({radius: 6, color: '#1F000000', offsetX: 2, offsetY: 4})
}
```
##### 2.5 任务管理的关系型数据库操作类TaskHandle
```ts
import relationalStore from '@ohos.data.relationalStore';
import TaskDataModel from '../models/TaskDataModel';

class TaskHandle {

  private rdbStore: relationalStore.RdbStore
  private tableName: string = 'TASK'

  /**
   * 初始化任务表
   */
  initTaskDB(context){
    // 1.rdb配置
    const config = {
      name: 'MyApplication.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    // 2.初始化SQL语句
    const sql = `CREATE TABLE IF NOT EXISTS TASK (
                  ID INTEGER PRIMARY KEY AUTOINCREMENT,
                  NAME TEXT NOT NULL,
                  FINISHED bit
                 )`
    // 3.获取rdb
    relationalStore.getRdbStore(context, config, (err, rdbStore) => {
      if(err){
        console.log('testTag', '获取rdbStore失败！')
        return
      }
      // 执行Sql
      rdbStore.executeSql(sql)
      console.log('testTag', '创建task表成功！')
      // 保存rdbStore
      this.rdbStore = rdbStore
    })
  }

  /**
   * 查询任务列表
   */
  async getTaskList(){
    // 1.构建查询条件
    let predicates = new relationalStore.RdbPredicates(this.tableName)
    // 2.查询
    let result = await this.rdbStore.query(predicates, ['ID', 'NAME', 'FINISHED'])
    // 3.解析查询结果
    // 3.1.定义一个数组，组装最终的查询结果
    let tasks: TaskDataModel[] = []
    // 3.2.遍历封装
    while(!result.isAtLastRow){
      // 3.3.指针移动到下一行
      result.goToNextRow()
      // 3.4.获取数据
      let id = result.getLong(result.getColumnIndex('ID'))
      let name = result.getString(result.getColumnIndex('NAME'))
      let finished = result.getLong(result.getColumnIndex('FINISHED'))
      // 3.5.封装到数组
      tasks.push({id, name, finished: !!finished})
    }
    console.log('testTag', '查询到数据：', JSON.stringify(tasks))
    return tasks
  }

  /**
   * 添加一个新的任务
   * @param name 任务名称
   * @returns 任务id
   */
  addTask(name: string): Promise<number>{
    return this.rdbStore.insert(this.tableName, {name, finished: false})
  }

  /**
   * 根据id更新任务状态
   * @param id 任务id
   * @param finished 任务是否完成
   */
  updateTaskStatus(id: number, finished: boolean) {
    // 1.要更新的数据
    let data = {finished}
    // 2.更新的条件
    let predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('ID', id)
    // 3.更新操作
    return this.rdbStore.update(data, predicates)
  }

  /**
   * 根据id删除任务
   * @param id 任务id
   */
  deleteTaskById(id: number){
    // 1.删除的条件
    let predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('ID', id)
    // 2.删除操作
    return this.rdbStore.delete(predicates)
  }
}

let taskHandle = new TaskHandle();

export default taskHandle as TaskHandle;
```












