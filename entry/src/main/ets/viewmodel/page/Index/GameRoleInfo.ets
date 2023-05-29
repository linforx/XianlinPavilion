/**
 * @FileName: GameRoleInfo
 * @Author: Administrator
 * @Date: 2023/5/28 14:02
 * Description:
 */

import GameRole from '../../../model/User/GameRole'

@Observed
export default class GameRoleInfo {
  constructor(game_role: GameRole, account_head_img?: string | Resource) {
    this.headImg = account_head_img ?? ''
    this.nickname = game_role?.nickname
    this.gameUid = game_role?.gameUid
  }

  public headImg: string | Resource = ''
  public nickname: string = ''
  public gameUid: string = ''
}