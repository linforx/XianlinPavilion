/**
 * @FileName: GameRoleInfo
 * @Author: Administrator
 * @Date: 2023/5/28 14:02
 * Description: 游戏角色信息UI类
 */

import GameRole from '../../../model/User/GameRole'

@Observed
export default class GameRoleInfo {
  constructor(game_role: GameRole, account_head_img?: string | Resource) {
    this.headImg = account_head_img ?? ''
    this.nickname = game_role?.nickname
    this.gameUid = game_role?.gameUid
    this.regionName = game_role.regionName
  }

  public headImg: string | Resource = ''
  public nickname: string = ''
  public gameUid: string = ''
  public regionName: string = ''
}