/**
 * @FileName: StarRailAPI
 * @Author: Administrator
 * @Date: 2023/5/22 21:28
 * Description: 星穹铁道接口封装
 */
import MihoyoAPI from './MihoyoAPI';
import apiMap from '../../common/service/Honkai_StarRail/APIMap'

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

    /*-------------------------------------接口定义------------------------------------*/
    // 获取游戏实时便笺的接口
    // 参数: role_id(string), server(string)
    // 返回: this
    public applyNote(role_id: string, server: string) {
        let api = apiMap.note

        this.url = api['url']
        this.params = api['params']
        this.params['role_id'] = role_id
        this.params['server'] = server
        this.method = api['method']

        return this
    }
    /*-------------------------------------接口定义------------------------------------*/
}