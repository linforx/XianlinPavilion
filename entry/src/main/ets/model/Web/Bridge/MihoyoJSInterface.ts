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


class MihoyoJSInterface {
    private static getHttpRequestHeader() {
        return {
            data: {
                'x-rpc-client_type': '5',
                'x-rpc-device_id': (globalThis.SelUser as User).cookie.getByName('_MHYUUID'),
                'x-rpc-app_version': CoreEnvironment.miHoYoBBSXrpcVersion,
                'x-rpc-sys_version': '7.1.2',
                'x-rpc-device_model': `Huawei ${deviceInfo.productModel}`,
                'x-rpc-channel': 'mihoyo',
                'x-rpc-device_fp': (globalThis.SelUser as User).cookie.getByName('DEVICEFP')
            }
        }
    }
    private static async getActionTicketAsync(action_type: string) {
        let response = await new MihoyoAPI()
            .applyActionTicket(action_type, (globalThis.SelUser as User).cookie.getByName('stoken'), (globalThis.SelUser as User).cookie.getByName('account_id'))
            .setCookie((globalThis.SelUser as User).cookie.getByType(CookieType.SToken))
            .useDynamicSecret(DynamicSecretVersion.V1, SaltType.K2)
            .getResponseAsync()
        return { data: JSON.parse(response.data) }
    }
    private static getCookieInfo() {
        let ck = (globalThis.SelUser as User).cookie
        return {
            data: {
                'ltuid': ck.getByName('ltuid'),
                'ltoken': ck.getByName('ltoken'),
                'login_ticket': ''
            }
        }
    }
    private static getDS() {
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
    private static getDS2(query: string, body: string) {
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
    public static async getJsResultFromJsParamAsync(param) {
        switch (param.method) {
            case 'getHTTPRequestHeaders': return this.getHttpRequestHeader()
            case 'getActionTicket': return await this.getActionTicketAsync(param.payload.action_type)
            case 'configure_share': return null
            case 'getCookieInfo': return this.getCookieInfo()
            case 'getStatusBarHeight': return { data: { 'statusBarHeight': 0 } }
            case 'login': return null
            case 'getDS': return this.getDS()
            case 'getDS2': return this.getDS2(Utils.joinParams2Url('', param.payload.query).replace('?', ''), param.payload.body)
            default: console.error('unhandled method: ' + param.method)
        }
        return null
    }
}

export default MihoyoJSInterface