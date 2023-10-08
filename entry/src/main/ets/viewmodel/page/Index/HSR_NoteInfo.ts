export default class HSR_NoteInfo {
  public current_stamina: number = 0 // 当前开拓力
  public max_stamina: number = 240 // 开拓力上限
  public stamina_recover_time: number = 0 // 开拓力距离恢复到最大值还需要的时间(s)
  public accepted_epedition_num: number = 0 // 接取的委托数量
  public total_expedition_num: number = 4 // 委托任务接取上限
  public current_train_score: number = 0 // 当前每日实训进度
  public max_train_score: number = 500 // 每日实训上限
  public current_rogue_score: number = 0 // 本周模拟宇宙积分
  public max_rogue_score: number = 14000 // 模拟宇宙积分上限
  public weekly_cocoon_cnt: number = 3 // 历战余响剩余次数
  public weekly_cocoon_limit: number = 3 // 历战余响次数上限
  public current_reserve_stamina: number = 0 // 当前后备开拓力
  public is_reserve_stamina_full: boolean = false // 后备开拓力是否达到上限
  public expeditions: Array<Expedition> = [] // 委托列表

  public updateTime: number = 0 // 数据更新的时间戳

  constructor(data?: Object) {
    if (data) {
      this.current_stamina = data['current_stamina'] ?? 0
      this.max_stamina = data['max_stamina'] ?? 240
      this.stamina_recover_time = data['stamina_recover_time'] ?? 0

      this.accepted_epedition_num = data['accepted_epedition_num'] ?? 0
      this.total_expedition_num = data['total_expedition_num'] ?? 4

      this.current_train_score = data['current_train_score'] ?? 0
      this.max_train_score = data['max_train_score'] ?? 500

      this.current_rogue_score = data['current_rogue_score'] ?? 0
      this.max_rogue_score = data['max_rogue_score'] ?? 1400

      this.weekly_cocoon_cnt = data['weekly_cocoon_cnt'] ?? 3
      this.weekly_cocoon_limit = data['weekly_cocoon_limit'] ?? 3

      this.current_reserve_stamina = data['current_reserve_stamina'] ?? 3
      this.is_reserve_stamina_full = data['is_reserve_stamina_full'] ?? false

      for (let e of data['expeditions']) {
        this.expeditions.push(new Expedition(e))
      }

      this.updateTime = Date.now()
    }
  }

  public toJSON(): any {
    return {
      current_stamina: this.current_stamina,
      max_stamina: this.max_stamina,
      stamina_recover_time: this.stamina_recover_time,
      accepted_epedition_num: this.accepted_epedition_num,
      total_expedition_num: this.total_expedition_num,
      current_train_score: this.current_train_score,
      max_train_score: this.max_train_score,
      current_rogue_score: this.current_rogue_score,
      max_rogue_score: this.max_rogue_score,
      weekly_cocoon_cnt: this.weekly_cocoon_cnt,
      weekly_cocoon_limit: this.weekly_cocoon_limit,
      current_reserve_stamina: this.current_reserve_stamina,
      is_reserve_stamina_full: this.is_reserve_stamina_full,
      expeditions: this.expeditions.map(expedition => expedition.toJSON()),
      updateTime: this.updateTime
    };
  }
}

// 委托任务类
class Expedition {
  public name: string = ''                      // 委托任务的名称
  public avatars: Array<string> = []            // 执行委托任务的角色的头像Url
  public status: string = ''                    // 委托任务的状态
  public remaining_time: number = 0             // 距离委托任务完成还需要的时间(s)

  constructor(data: any) {
    this.name = data['name']
    this.avatars = data['avatars'] ?? []
    this.status = data['status'] ?? ''
    this.remaining_time = data['remaining_time'] ?? 0
  }

  public toJSON(): any {
    return {
      name: this.name,
      avatars: this.avatars,
      status: this.status,
      remaining_time: this.remaining_time
    };
  }
}