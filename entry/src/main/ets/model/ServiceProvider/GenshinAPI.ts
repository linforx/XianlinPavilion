/**
 * @FileName: GenshinAPI
 * @Author: Administrator
 * @Date: 2023/5/22 21:28
 * Description: 原神接口封装
 */

import MihoyoAPI from './MihoyoAPI';
import apiMap from '../../common/service/GenshinImpact/APIMap'

class GenshinAPI extends MihoyoAPI {
    constructor() {
        super();
    }

    /*-------------------------------------接口定义------------------------------------*/
    // 获取游戏实时便笺的接口
    // 参数: role_id(string), server(string)
    // 返回: this
    public applyDailyNote(role_id: string, server: string) {
        let api = apiMap.dailyNote

        this.url = api['url']
        this.params = api['params']
        this.params['role_id'] = role_id
        this.params['server'] = server
        this.method = api['method']

        return this
    }

    // 获取简略的实时便笺的接口
    // 参数: void
    // 返回: this
    public applyWidgetData() {
        let api = apiMap.widgetData

        this.url = api['url']
        this.params = api['params']
        this.method = api['method']

        return this
    }

    // 获取旅行札记数据的接口
    // 参数: month(number), uid(string), region(string)
    // 返回: this
    public applyLedger(month: number, uid: string, region: string) {
        let api = apiMap.ledger

        this.url = api['url']
        this.params = api['params']
        this.params['month'] = month
        this.params['bind_uid'] = uid
        this.params['bind_region'] = region
        this.method = api['method']

        return this
    }

    // 获取 我的角色 数据的接口
    // 参数: uid(number), server(string)
    // 返回: this
    public applyCharacter(uid: string, server: string) {
        let api = apiMap.character

        this.url = api['url']
        this.params = api['params']
        this.method = api['method']
        this.data = api['body']
        this.data['role_id'] = uid
        this.data['server'] = server

        return this
    }

    // 获取角色详细数据(包含天赋等级)的接口
    // 参数: uid(string), region(string), avatar_id(number)
    // 返回: this
    public applyAvatarDetail(uid: string, region: string, avatar_id: number) {
        let api = apiMap.avatarDetail

        this.url = api['url']
        this.params = api['params']
        this.params['uid'] = uid
        this.params['region'] = region
        this.params['avatar_id'] = avatar_id
        this.method = api['method']

        return this
    }

    // 获取GameAuthkey的接口
    // 参数: game_biz(string), uid(string), region(string)
    // 返回: this
    public applyGenAuthKey(game_biz: string, uid: string, region: string) {
        let api = apiMap.genAuthKey

        this.url = api['url']
        this.params = api['params']
        this.method = api['method']
        this.data = api['body']
        this.data['game_biz'] = game_biz
        this.data['game_uid'] = uid
        this.data['region'] = region

        return this
    }

    // 获取抽卡记录(分页)的接口
    // 参数: region(string), authkey(string), game_biz(string), gacha_type(string), page(number), size(number), end_id(number)
    // 返回: this
    public applyGachaLog(region: string, authkey: string, game_biz: string, gacha_type: string, page: number, size: number, end_id: number) {
        let api = apiMap.gachaLog

        this.url = api['url']
        this.params = api['params']
        this.method = api['method']
        this.params['region'] = region
        this.params['authkey'] = authkey
        this.params['game_biz'] = game_biz
        this.params['gacha_type'] = gacha_type
        this.params['page'] = page
        this.params['size'] = size
        this.params['end_id'] = end_id

        return this
    }
    /*-------------------------------------接口定义------------------------------------*/
}

export default GenshinAPI