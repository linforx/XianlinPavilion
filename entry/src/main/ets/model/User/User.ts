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
import GenshinAPI from '../ServiceProvider/GenshinAPI'
import DynamicSecretVersion from '../../common/service/DynamicSecretVersion'
import SaltType from '../../common/service/SaltType'
import deviceInfo from '@ohos.deviceInfo'
import { DatabaseHelper, getDBHelper } from '../../common/database/DatabaseHelper'
import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import StarRailAPI from '../ServiceProvider/StarRailAPI'

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
    public deviceFP: string = ''
    public deviceId: string = ''

    public constructor(cookie: string, uid?: string) {
        this.cookie = new Cookie(cookie)
        this.uid = uid ?? ''

        this.deviceId = '5f3b6eec-58a4-3a6d-b544-51566d011b42'
        this.deviceFP = '38d7ee834d1e9'
    }

    private async registerDeviceAsync() {
        let deviceId = this.deviceId
        let deviceFP = this.deviceFP
        let RegId = this.genRegistrationId()
        let response = await new MihoyoAPI()
            .applyDeviceLogin(deviceId, deviceFP, RegId)
            .HeadersAddWith('x-rpc-client_type', '5')
            .HeadersAddWith('x-rpc-sys_version', '12')
            .HeadersAddWith('x-rpc-channel', 'release')
            .HeadersAddWith('x-rpc-device_id', deviceId)
            .HeadersAddWith('x-rpc-device_fp', deviceFP)
            .HeadersAddWith('x-rpc-device_name', `${deviceInfo.brand} ${deviceInfo.productModel}`)
            .HeadersAddWith('x-rpc-device_model', `${deviceInfo.productModel}`)
            .setReferer(Host.AppMihoyoReferer)
            .setCookie(this.cookie.getByType(CookieType.SToken))
            .getResponseAsync()
        if (response.success) {
            response = await new MihoyoAPI()
                .applySaveDevice(deviceId, deviceFP, RegId)
                .HeadersAddWith('x-rpc-client_type', '5')
                .HeadersAddWith('x-rpc-sys_version', '12')
                .HeadersAddWith('x-rpc-channel', 'release')
                .HeadersAddWith('x-rpc-device_id', deviceId)
                .HeadersAddWith('x-rpc-device_fp', deviceFP)
                .HeadersAddWith('x-rpc-device_name', `${deviceInfo.brand} ${deviceInfo.productModel}`)
                .HeadersAddWith('x-rpc-device_model', `${deviceInfo.productModel}`)
                .setReferer(Host.AppMihoyoReferer)
                .setCookie(this.cookie.getByType(CookieType.SToken))
                .getResponseAsync()

            if (response.success) {
                console.warn(`register device(id:${deviceId},fp:${deviceFP}) success`)
            } else {
                console.warn(`register device(id:${deviceId},fp:${deviceFP}) failed`)
            }
        }
    }

    private genRegistrationId() {
        function S1 () {
            return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(5)
        }
        let id = ''
        for (let i = 0; i < 19; ++i) {
            id += S1()
        }
        return id
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

    public async getGIGameRoleListAsync() {
        let response = await new GenshinAPI()
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

    public async getHSRGameRoleListAsync() {
        let response = await new StarRailAPI()
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
/*
        const seedId: string = getRandomString(16)
        const seedTime: string = new Date().getTime().toString()
        let FPData = await new MihoyoAPI()
            .applyGetFP(seedId, seedTime, this.deviceId, this.deviceFP)
            .setCookie(this.cookie.getByType(CookieType.BothCLToken))
            .setReferer('https://webstatic.mihoyo.com/')
            .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
            .getResponseAsync()
        console.warn('FPData: ' + FPData.data)
        const deviceFP: string = JSON.parse(FPData.data).device_fp
*/

        let response = await new GenshinAPI()
            .applyDailyNote(role.gameUid, role.region)
            .setCookie(this.cookie.getByType(CookieType.BothCLToken))
            .setReferer('https://webstatic.mihoyo.com/')
            .HeadersAddWith('x-rpc-device_fp', this.deviceFP)
            .HeadersAddWith('x-rpc-device_id', this.deviceId)
            .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
            .getResponseAsync()
        if (!response.success) {
            promptAction.showToast({
                message: '获取原神体力数据失败: ' + response.message
            })
            console.error('获取原神体力数据失败: ' + response.message)
            return null
        }

        console.warn('获取原神体力数据成功')

        return JSON.parse(response.data)
    }

    public async getHSRNoteDateAsync() {
        let role = globalThis.SelHSRRole as GameRole

        if (!role) {
            promptAction.showToast({
                message: '请绑定崩坏·星穹铁道角色'
            })
            return
        }

        let response = await new StarRailAPI()
            .applyNote(role.gameUid, role.region)
            .setCookie(this.cookie.getByType(CookieType.BothCLToken))
            .setReferer('https://webstatic.mihoyo.com/')
            .HeadersAddWith('x-rpc-device_fp', this.deviceFP)
            .HeadersAddWith('x-rpc-device_id', this.deviceId)
            .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
            .getResponseAsync()
        if (!response.success) {
            promptAction.showToast({
                message: '获取星穹铁道体力数据失败: ' + response.message
            })
            console.error('获取星穹铁道体力数据失败: ' + response.message)
            return null
        }

        console.warn('获取星穹铁道体力数据成功')

        return JSON.parse(response.data)
    }

    public static createDefaultAccount() {
        return new User('YourSToken', '253237280')
    }

    // 将帐户信息持久化保持在数据库中
    public async flush(context: common.Context) {
        let DBHelper: DatabaseHelper = getDBHelper(context)
        if (await DBHelper.initStorageAsync()) {
            let predicates = new relationalStore.RdbPredicates('account')
            predicates.equalTo('account_id', this.uid)
            let id: number = 0;
            let valueBucket = {
                account_id: this.uid,
                cookies: this.cookie.toString()
            }
            try {
                if (await DBHelper.existInTableAsync(predicates)) {
                    id = await DBHelper.updateInTableAsync(predicates, valueBucket)
                }
                else {
                    id = await DBHelper.insertToTableAsync('account', valueBucket)
                }
            } catch(err) {
                console.error(JSON.stringify(err))
            }

            if (id > 0) {
                promptAction.showToast({
                    message: '帐户信息持久化成功'
                })
            }
            else {
                promptAction.showToast({
                    message: '帐户信息持久化失败'
                })
            }
        }
        else {
            promptAction.showToast({
                message: '数据库初始化失败'
            })
        }
    }
}