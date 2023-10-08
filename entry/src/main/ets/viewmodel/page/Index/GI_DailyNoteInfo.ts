/**
 * @FileName: GI_DailyNoteInfo
 * @Author: Administrator
 * @Date: 2023/5/31 17:28
 * Description:
 */

export default class GI_DailyNoteInfo {
  public currentResin: number = 0                       // 当前原脆树脂
  public maxResin: number = 160                         // 原脆树脂最大值
  public resinRecoveryTime: number = 0                  // 原脆树脂距离恢复到最大值还需要的时间(s)
  public finishedTaskNum: number = 0                    // 完成的每日委托数量
  public totalTaskNum: number = 4                       // 全部每日委托的数量
  public isExtraTaskRewardReceived: boolean = false     // 是否领取完成全部每日委托的额外奖励
  public remainResinDiscountNum: number = 3             // 剩余的征讨领域奖励领取树脂消耗减半的次数
  public resinDiscountNumLimit: number = 3              // 征讨领域奖励领取树脂消耗次数限制
  public currentExpeditionNum: number = 0               // 正在进行的派遣探索任务
  public maxExpeditionNum: number = 0                   // 可同时进行的派遣探索任务的最大数量
  public expeditionsList: Expedition[] = []             // 正在进行的派遣探索任务的列表
  public obtainedHome: boolean                          // 标识是否得到尘歌壶
  public currentHomeCoin: number = 0                    // 当前洞天宝钱数量
  public maxHomeCoin: number = 0                        // 洞天宝钱可以积攒到的最大数量
  public homeCoinRecoveryTime: number = 0               // 洞天宝钱恢复到最大值还需要的时间(s)
  public transformer: Transformer = new Transformer()   // 参变质量仪相关数据

  public updateTime: number = 0                         // 数据更新的时间戳

  public constructor(data?: Object) {
    if (data) {
      this.currentResin = data['current_resin'] ?? 0
      this.maxResin = data['max_resin'] ?? 160
      this.resinRecoveryTime = parseInt(data['resin_recovery_time'] ?? '0')

      this.finishedTaskNum = data['finished_task_num'] ?? 0
      this.totalTaskNum = data['total_task_num'] ?? 4
      this.isExtraTaskRewardReceived = data['is_extra_task_reward_received'] ?? false

      this.remainResinDiscountNum = data['remain_resin_discount_num'] ?? 3
      this.resinDiscountNumLimit = data['resin_discount_num_limit'] ?? 3

      this.currentExpeditionNum = data['current_expedition_num'] ?? 0
      this.maxExpeditionNum = data['max_expedition_num'] ?? 0
      for (let e of data['expeditions']) {
        this.expeditionsList.push(new Expedition(e))
      }

      if (data['max_home_coin']) {
        this.obtainedHome = true
        this.currentHomeCoin = data['current_home_coin'] ?? 0
        this.maxHomeCoin = data['max_home_coin'] ?? 0
        this.homeCoinRecoveryTime = parseInt(data['home_coin_recovery_time'] ?? '0')
      }

      this.transformer = new Transformer(data['transformer'])

      this.updateTime = Date.now()
    }
  }

  public toJSON(): any {
    return {
      currentResin: this.currentResin,
      maxResin: this.maxResin,
      resinRecoveryTime: this.resinRecoveryTime,
      finishedTaskNum: this.finishedTaskNum,
      totalTaskNum: this.totalTaskNum,
      isExtraTaskRewardReceived: this.isExtraTaskRewardReceived,
      remainResinDiscountNum: this.remainResinDiscountNum,
      resinDiscountNumLimit: this.resinDiscountNumLimit,
      currentExpeditionNum: this.currentExpeditionNum,
      maxExpeditionNum: this.maxExpeditionNum,
      expeditions: this.expeditionsList.map(expedition => expedition.toJSON()),
      obtainedHome: this.obtainedHome,
      currentHomeCoin: this.currentHomeCoin,
      maxHomeCoin: this.maxHomeCoin,
      homeCoinRecoveryTime: this.homeCoinRecoveryTime,
      transformer: this.transformer.toJSON(),
      updateTime: this.updateTime
    }
  }
}


// 派遣探索任务类
class Expedition {
  public avatarSideIcon: string = ''            // 执行派遣探索的角色的侧面头像Url
  public status: string = ''                    // 派遣探索任务的状态
  public remainedTime: number = 0               // 距离派遣探索任务完成还需要的时间(s)

  constructor(data: any) {
    this.avatarSideIcon = data['avatar_side_icon'] ?? ''
    this.status = data['status'] ?? ''
    this.remainedTime = parseInt(data['remained_time'] ?? '0')
  }

  public toJSON(): any {
    return {
      avatarSideIcon: this.avatarSideIcon,
      status: this.status,
      remainedTime: this.remainedTime
    }
  }
}

// 参变质量仪类
class Transformer {
  public obtained: boolean = false        // 是否获取参变质量仪
  public recoveryTime: { Day: number, Hour: number, Minute: number, Second: number, reached: boolean }
    = { Day: 0, Hour: 0, Minute: 0, Second: 0, reached: true }
  public noticed: boolean = false         // 意义未知
  public latestJobId: string = '0'        // 意义未知

  public constructor(data?: any) {
    if (data) {
      this.obtained = data['obtained'] ?? false
      if (this.obtained) {
        this.recoveryTime = data['recovery_time'] ?? { Day: 0, Hour: 0, Minute: 0, Second: 0, reached: true }
        this.noticed = data['noticed'] ?? false
        this.latestJobId = data['latest_job_id'] ?? '0'
      }
    }
  }

  public toJSON(): any {
    return {
      obtained: this.obtained,
      recoveryTime: this.recoveryTime,
      noticed: this.noticed,
      latestJobId: this.latestJobId
    }
  }
}