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

    public constructor(json_data: Object, cookie: string) {
        this.cookie = new Cookie(cookie)
        this.uid = json_data['user_info']['uid'] ?? ''
        this.nickname = json_data['user_info']['nickname'] ?? ''
        this.introduce = json_data['user_info']['introduce'] ?? ''
        this.accountHeadImg = json_data['user_info']['avatar_url'] ?? ''
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

    public static createDefaultAccount() {
        return new User({
            user_info: {
                'uid': '154114645',
                'nickname': '测试账户',
                'introduce': '',
                'avatar_url': 'https://img-static.mihoyo.com/communityweb/upload/ca38485367778c82961deea9b4fcfe8a.png'
            }
        }, 'YourSToken')
    }
}