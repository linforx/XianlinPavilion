import SaltType from '../../../common/service/SaltType';
import DynamicSecretVersion from '../../../common/service/DynamicSecretVersion';
import Cookie from '../../../model/User/Cookie'
import CookieType from '../../../common/service/CookieType';
import MihoyoAPI from '../../ServiceProvider/MihoyoAPI'
import CoreEnvironment from '../../../common/service/CoreEnvironment';
import User from '../../User/User';
import deviceInfo from '@ohos.deviceInfo';
import DynamicSecretGenerator from '../../../common/service/DynamicSecretGenerator';
import Utils from '../../../common/utils/Utils';
import Host from '../../../common/service/Host';

class SignInJSInterface {
    public static getHttpRequestHeader() {
        return {
            data: {
                'x-rpc-client_type': '2',
                'x-rpc-device_id': (globalThis.SelUser as User).cookie.getByName('_MHYUUID'),
                'x-rpc-app_version': CoreEnvironment.miHoYoBBSXrpcVersion
            }
        }
    }
    public static async getActionTicketAsync(action_type: string) {
        let response = await new MihoyoAPI()
            .applyActionTicket(action_type, (globalThis.SelUser as User).cookie.getByName('stoken'), (globalThis.SelUser as User).cookie.getByName('account_id'))
            .setCookie((globalThis.SelUser as User).cookie.getByType(CookieType.SToken))
            .useDynamicSecret(DynamicSecretVersion.V1, SaltType.K2)
            .getResponseAsync()
        return { retcode: response.code, data: JSON.parse(response.data) }
    }
    public static getCookieInfo() {
        let ck = (globalThis.SelUser as User).cookie
        return {
            data: {
                'ltuid': ck.getByName('ltuid'),
                'ltoken': ck.getByName('ltoken'),
                'login_ticket': ''
            }
        }
    }
    public static getCookieToken() {
        let ck = (globalThis.SelUser as User).cookie
        return {
            retcode: 0,
            data: {
                'cookie_token': ck.getByName('cookie_token')
            }
        }
    }
    public static getDS() {
        let DS = ''
        DS = new DynamicSecretGenerator(DynamicSecretVersion.V1)
            .useSalt(SaltType.LK2)
            .create();

        return {
            data: {
                'DS': DS
            }
        }
    }
    public static getDS2(query: string, body: string) {
        let DS =  new DynamicSecretGenerator(DynamicSecretVersion.V2)
            .withParams(query)
            .withBody(body)
            .useSalt(SaltType.X4)
            .create();

        return {
            retcode: 0,
            data: {
                'DS': DS
            }
        }
    }
    public static async getUserInfoAsync() {
        let response = await new MihoyoAPI()
            .applyUserInfo()
            .setCookie((globalThis.SelUser as User).cookie.getByType(CookieType.BothCLToken))
            .setOrigin(Host.AppMihoyoReferer)
            .setReferer(Host.AppMihoyoReferer)
            .getResponseAsync()

        let json = JSON.parse(response.data)
        return {
            retcode: response.code,
            data: {
                uid: json.user_info.uid,
                nickname: json.user_info.nickname,
                introduce: json.user_info.introduce,
                gender: json.user_info.gender,
                avatar_url: json.user_info.avatar_url,
            }
        }
    }
    public static async getJsResultFromJsParamAsync(param) {
        switch (param.method) {
            case 'getHTTPRequestHeaders': return this.getHttpRequestHeader()
            case 'getActionTicket': return await this.getActionTicketAsync(param.payload.action_type)
            case 'configure_share': return null
            case 'getCookieInfo': return this.getCookieInfo()
            case 'getCookieToken': return this.getCookieToken()
            case 'getStatusBarHeight': return { data: { 'statusBarHeight': 0 } }
            case 'login': return null
            case 'getDS': return this.getDS()
            case 'getDS2': return this.getDS2(Utils.joinParams2Url('', param.payload.query).replace('?', ''), param.payload.body)
            case 'getUserInfo': return await this.getUserInfoAsync()
            default: console.error('unhandled method: ' + param.method)
        }
        return null
    }
}


export default SignInJSInterface