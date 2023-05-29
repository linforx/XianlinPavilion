/**
 * @FileName: AccountInfo
 * @Author: Administrator
 * @Date: 2023/5/28 16:38
 * Description:
 */

import User from '../../../model/User/User'

@Observed
export default class AccountInfo {
  public uid: string = ''                     // 账号UID
  public nickname: string = ''                // 昵称
  public introduce: string = ''               // 简介
  public accountHeadImg: string = ''          // 账号头像图片URL

  constructor(user: User) {
    if (user) {
      this.uid = user.uid
      this.nickname = user.nickname
      this.introduce = user.introduce
      this.accountHeadImg = user.accountHeadImg
    }
  }
}