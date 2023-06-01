/**
 * @FileName: User
 * @Author: Administrator
 * @Date: 2023/5/22 21:16
 * Description:
 */

import Cookie from './Cookie'
import MihoyoAPI from '../ServiceProvider/MihoyoAPI'
import CookieType from '../../common/service/CookieType'
import promptAction from '@ohos.promptAction'
import GameRole from './GameRole'
import Host from '../../common/service/Host'
import http from '@ohos.net.http'
import CoreEnvironment from '../../common/service/CoreEnvironment'
import GenshinAPI from '../ServiceProvider/GenshinAPI'
import DynamicSecretVersion from '../../common/service/DynamicSecretVersion'
import SaltType from '../../common/service/SaltType'
import deviceInfo from '@ohos.deviceInfo'

export default class User {
    public cookie: Cookie = null
    public uid: string = ''                     // 账号UID
    public nickname: string = ''                // 昵称
    public introduce: string = ''               // 简介
    public accountHeadImg: string = ''          // 账号头像图片URL
    public gameRoleChosen = {
        Genshin: {
            uid: ''
        },
        StarRail: {
            uid: ''
        }
    }

    public constructor(cookie: string, uid?: string) {
        this.cookie = new Cookie(cookie)
        this.uid = uid ?? ''
    }

    public async updateMultiCookieAsync() {
        let response = await new MihoyoAPI()
            .applyMultiCookie(this.cookie.getByName('login_ticket'), this.cookie.getByName('login_uid'))
            .getResponseAsync()

        if (!response.success) {
            promptAction.showToast({
                message: '更新SToken失败：' + response.message
            })
            return false
        }
        let data = JSON.parse(response.data)
        let cookie = Cookie.stringifyCookie({
            stuid: this.cookie.getByName('login_uid'),
            stoken: data.list[0].token,
            ltoken: data.list[1].token
        })
        this.cookie.join(cookie)

        return true
    }

    public async updateBBSCookieAsync() {
        let response = await new MihoyoAPI()
            .applyBBSCookie(this.cookie.getByName('stuid'), this.cookie.getByName('stoken'))
            .getResponseAsync()

        if (!response.success) {
            promptAction.showToast({
                message: '更新米游社Cookie失败：' + response.message
            })
            return false
        }
        let data = JSON.parse(response.data)
        let cookie = Cookie.stringifyCookie({
            ltuid: data['uid'],
            cookie_token: data['cookie_token'],
            account_id: data['uid']
        })
        this.cookie.join(cookie)

        return true
    }

    public async updateUserInfoAsync() {
        let response = await new MihoyoAPI()
            .applyUserInfo()
            .setCookie(this.cookie.getByType(CookieType.BothCLToken))
            .setOrigin(Host.AppMihoyoReferer)
            .setReferer(Host.AppMihoyoReferer)
            .getResponseAsync()

        if (!response.success) {
            promptAction.showToast({
                message: '更新账号信息失败：' + response.message
            })
            return false
        }
        let json_data = JSON.parse(response.data)
        this.uid = json_data['user_info']['uid'] ?? ''
        this.nickname = json_data['user_info']['nickname'] ?? ''
        this.introduce = json_data['user_info']['introduce'] ?? ''
        this.accountHeadImg = json_data['user_info']['avatar_url'] ?? ''

        return true
    }

    public async getGameRoleListAsync() {
        let response = await new MihoyoAPI()
            .applyGameRoleInfo()
            .setCookie(this.cookie.getByType(CookieType.CookieToken))
            .getResponseAsync()

        let roleList: GameRole[] = []
        if (!response.success) {
            promptAction.showToast({
                message: '获取游戏角色信息失败：' + response.message
            })
            return roleList
        }
        let json_data = JSON.parse(response.data)
        for (let role of json_data['list']) {
            roleList.push(new GameRole(role))
        }

        return roleList
    }

    public async getGIDailyNoteDateAsync() {
        let role = globalThis.SelGIRole as GameRole
        if (!role) {
            promptAction.showToast({
                message: '请绑定原神角色'
            })
            return
        }
        let httpClient = http.createHttp()
        await httpClient.request(`https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/dailyNote?server=${role.region}&role_id=${role.gameUid}`,{
            header: {
                'Accept': '*/*',
                'Access-Control-Request-Method': 'GET',
                'Access-Control-Request-Headers': 'ds,x-rpc-app_version,x-rpc-client_type,x-rpc-device_fp,x-rpc-device_id,x-rpc-device_name,x-rpc-page,x-rpc-sys_version,x-rpc-tool_verison',
                'Origin': 'https://webstatic.mihoyo.com',
                'Referer': 'https://webstatic.mihoyo.com',
                'User-Agent': CoreEnvironment.miHoYoBBSUserAgent,
                'X-Requested-With': 'com.mihoyo.hyperion',
                'Sec-Fetch-Mode': 'cors',
                'Sec-Fetch-Site': 'same-site',
                'Sec-Fetch-Dest': 'empty'
            },
            method: http.RequestMethod.OPTIONS
        })
        let response = await new GenshinAPI()
            .applyDailyNote(role.gameUid, role.region)
            .setCookie(this.cookie.getByType(CookieType.BothCLToken))
            .setReferer('https://webstatic.mihoyo.com')
            .setOrigin('https://webstatic.mihoyo.com')
            .HeadersAddWith('x-rpc-sys_version', '7.1.2')
            .HeadersAddWith('x-rpc-device_id', '5f3b6eec-58a4-3a6d-b544-51566d011b42')
            .HeadersAddWith('x-rpc-device_fp', '38d7ee6529d18')
            .HeadersAddWith('x-rpc-device_name', 'Samsung%20SM-G9810')
            .HeadersAddWith('x-rpc-page', `v${CoreEnvironment.miHoYoBBSGIToolVersion}-ys_#/ys`)
            .HeadersAddWith('X-Requested-With', 'com.mihoyo.hyperion')
            .HeadersAddWith('x-rpc-tool_verison', `v${CoreEnvironment.miHoYoBBSGIToolVersion}-ys`)
            .HeadersAddWith('Sec-Fetch-Mode', 'cors')
            .HeadersAddWith('Sec-Fetch-Site', 'same-site')
            .HeadersAddWith('Sec-Fetch-Dest', 'empty')
            .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
            .getResponseAsync()
        if (!response.success) {
            promptAction.showToast({
                message: '获取体力数据失败: ' + response.message
            })
            return null
        }

        return JSON.parse(response.data)
    }

    public static createDefaultAccount() {
        return new User('YourSToken', '253237280')
    }
}