/**
 * @FileName: StarRailAPI
 * @Author: Administrator
 * @Date: 2023/5/22 21:28
 * Description:
 */
import MihoyoAPI from './MihoyoAPI';

export default class StarRailAPI extends MihoyoAPI {
    constructor() {
        super();
    }

    // 获取账户关联的游戏角色信息的接口
    // 参数: void
    // 返回: this
    public applyGameRoleInfo() {
        super.applyGameRoleInfo()

        this.params['game_biz'] = 'hkrpg_cn'

        return this;
    }
}