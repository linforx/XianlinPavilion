/**
 * @FileName: MihoyoAPI
 * @Author: Administrator
 * @Date: 2023/5/23 19:06
 * Description: 米哈游接口封装
 */

import http from '@ohos.net.http';
import deviceInfo from '@ohos.deviceInfo';
import apiMap from '../../common/service/Mihoyo/APIMap';
import CoreEnvironment from '../../common/service/CoreEnvironment';
import DynamicSecretGenerator from '../../common/service/DynamicSecretGenerator';
import DynamicSecretVersion from '../../common/service/DynamicSecretVersion';
import Response from '../../common/service/Response';
import SaltType from '../../common/service/SaltType';
import errorMsgMap from '../../common/service/ErrorMap';
import Utils from '../../common/utils/Utils';
import NewsType from '../../common/service/Mihoyo/NewsType';


class MihoyoAPI {
    protected url: string
    protected params: {}
    protected headers: {}
    protected data: {}
    protected method: http.RequestMethod

    constructor() {
        this.url = '';
        this.params = {};
        // 初始化默认请求头
        this.headers = {
            'Accept': 'application/json',
            'User-Agent': CoreEnvironment.miHoYoBBSUserAgent,
            'x-rpc-client_type': '5',
            'x-rpc-app_version': CoreEnvironment.miHoYoBBSXrpcVersion,
            'x-rpc-sys_version': '12',
            'x-rpc-channel': 'mihoyo',
            'x-rpc-device_name': Utils.getRandomString(Math.floor(Math.random() * 10) + 1),
            'x-rpc-device_model': deviceInfo.productModel
        };
        this.data = {};
        this.method = http.RequestMethod.GET;
    }

    /*-------------------------------------接口定义------------------------------------*/
    // 获取超级令牌(stoken)的接口
    // 参数: login_ticket(string), login_uid(string)
    // 返回: this
    public applyMultiCookie(login_ticket: string, login_uid: string) {
        let api = apiMap.multiToken

        this.url = api.url;
        this.params = api.params;
        this.params['login_ticket'] = login_ticket;
        this.params['uid'] = login_uid;
        this.method = api.method;

        return this;
    }

    // 获取米游社Cookie的接口
    // 参数: stuid(string), stoken(string)
    // 返回: this
    public applyBBSCookie(stuid: number, stoken: string) {
        let api = apiMap.bbsCookie

        this.url = api.url;
        this.params = api.params;
        this.params['uid'] = stuid;
        this.params['stoken'] = stoken;
        this.method = api.method;

        return this;
    }

    // 获取行为票据(ActionTicket)的接口
    // 参数: action_type(string), stoken(string), stuid(string)
    // 返回: this
    public applyActionTicket(action_type: string, stoken: string, stuid: string) {
        let api = apiMap.actionTicket

        this.url = api.url;
        this.params = api.params;
        this.params['action_type'] = action_type;
        this.params['stoken'] = stoken;
        this.params['uid'] = stuid;
        this.method = api.method;

        return this;
    }

    // 获取米游社账户信息的接口
    // 参数: void
    // 返回: this
    public applyUserInfo() {
        let api = apiMap.userInfo

        this.url = api.url;
        this.params = api.params;
        this.method = api.method;

        return this;
    }

    // 获取账户关联的游戏角色信息的接口
    // 参数: void
    // 返回: this
    public applyGameRoleInfo() {
        let api = apiMap.gameRoleInfo

        this.url = api.url;
        this.params = api.params;
        this.method = api.method;

        return this;
    }

    // 获取米游社公告列表的接口
    // 参数: type(newsType), size(number), last_id(number)
    // 返回: this
    public applyNewsList(type: NewsType, size: number, last_id: number) {
        type = type || NewsType.announcement;
        size = size || 20;
        last_id = last_id || 0;

        let api = apiMap.newsList

        this.url = api.url;
        this.params = api.params;
        this.params['page_size'] = size;
        this.params['type'] = type;
        this.params['last_id'] = last_id;
        this.method = api.method;

        return this;
    }

    // 获取米游社帖子详细内容的接口
    // 参数: post_id(number)
    // 返回: this
    public applyPostFull(post_id: number) {
        let api = apiMap.postFull

        this.url = api.url;
        this.params = api.params;
        this.params['post_id'] = post_id;
        this.method = api.method;

        return this;
    }

    // 请求服务器生成极验验证码认证信息的接口
    // 参数: is_high(boolean)
    // 返回: this
    public applyCreateVerification(is_high: boolean) {
        let api = apiMap.createVerification

        this.url = api.url;
        this.params = api.params;
        this.params['is_hight'] = is_high;
        this.method = api.method;

        return this;
    }

    // 请求服务器确认极验验证码验证通过的接口
    // 参数: challenge(string), validate(string)
    // 返回: this
    public applyVerifyVerification(challenge: string, validate: string) {
        let api = apiMap.verifyVerification

        this.url = api.url;
        this.params = api.params;
        this.method = api.method;
        this.data = api.body;
        this.data['geetest_seccode'] = `${validate}|jordan`;
        this.data['geetest_challenge'] = challenge;
        this.data['geetest_validate'] = validate;

        return this;
    }

    // 设备登录
    // 参数: device_id(string), device_name(string)， registration_id(string)
    // 返回: this
    public applyDeviceLogin(deviceId: string, deviceName: string, registrationId: string) {
        let api = apiMap.deviceLogin

        this.url = api.url;
        this.params = api.params;
        this.method = api.method;
        this.data = api.body;
        this.data['device_id'] = deviceId;
        this.data['device_name'] = deviceName;
        this.data['registration_id'] = registrationId;
        this.data['app_version'] = CoreEnvironment.miHoYoBBSXrpcVersion;
        this.data['os_version'] = '25';
        this.data['platform'] = 'Android';

        return this;
    }

    // 设备保存
    // 参数: device_id(string), device_name(string)， registration_id(string)
    // 返回: this
    public applySaveDevice(deviceId: string, deviceName: string, registrationId: string) {
        let api = apiMap.saveDevice

        this.url = api.url;
        this.params = api.params;
        this.method = api.method;
        this.data = api.body;
        this.data['device_id'] = deviceId;
        this.data['device_name'] = deviceName;
        this.data['registration_id'] = registrationId;
        this.data['app_version'] = CoreEnvironment.miHoYoBBSXrpcVersion;
        this.data['os_version'] = '25';
        this.data['platform'] = 'Android';

        return this;
    }
    /*-------------------------------------接口定义------------------------------------*/


    /*-----------------------------------参数控制接口-----------------------------------*/
    // 在请求中使用动态密钥(DynamicSecret)
    // 参数: version(DynamicSecretVersion), saltType(SaltType)
    // 返回: this
    public useDynamicSecret(version: DynamicSecretVersion, saltType: SaltType) {
        let DS = ''
        if (version == DynamicSecretVersion.V1) {
            DS = new DynamicSecretGenerator(version)
                .useSalt(saltType)
                .create();
        }
        else if (version == DynamicSecretVersion.V2) {
            var p = Utils.joinParams2Url('', this.params).replace('?', '');
            var b = (this.method === http.RequestMethod.POST) ? JSON.stringify(this.data) : '';
            DS = new DynamicSecretGenerator(version)
                .withParams(p)
                .withBody(b)
                .useSalt(saltType)
                .create();
        }

        this.headers['DS'] = DS;

        return this;
    }

    // 设置请求头中User-Agent的属性
    // 参数: UA(string)
    // 返回: this
    public setUserAgent(UA: string) {
        this.headers['User-Agent'] = UA;

        return this;
    }

    // 设置请求头中Referer的属性
    // 参数: Referer(string)
    // 返回: this
    public setReferer(Referer: string) {
        this.headers['Referer'] = Referer;

        return this;
    }

    // 设置请求头中Origin的属性
    // 参数: Origin(string)
    // 返回: this
    public setOrigin(Origin: string) {
        this.headers['Origin'] = Origin;

        return this;
    }

    // 设置请求头中Host的属性
    // 参数: Host(string)
    // 返回: this
    public setHost(Host: string) {
        this.headers['Host'] = Host;

        return this;
    }

    // 设置请求头中Cookie的属性
    // 参数: Cookie(string)
    // 返回: this
    public setCookie(Cookie: string) {
        this.headers['Cookie'] = Cookie;

        return this;
    }
    /*-----------------------------------参数控制接口-----------------------------------*/

    /*-----------------------------------成员变量访问-----------------------------------*/
    // 设置url，覆盖原本的url，如果参数为空那么不覆盖
    // 参数: _url(string)
    // 返回: this
    public Url(_url?: string): this {
        if (typeof _url === 'string') this.url = _url;

        return this;
    }

    // 获取url
    // 参数: void
    // 返回: this.url
    public getUrl(): string {
        return this.url;
    }

    // 设置params，覆盖原本的params，如果参数为空那么不覆盖
    // 参数: _params({})
    // 返回: this
    public Params(_params?: {}): this {
        if (typeof _params === 'object') this.params = _params;

        return this;
    }

    // 获取params
    // 参数: void
    // 返回: this.params
    public getParams(): {} {
        return this.params;
    }

    // 设置headers，覆盖原本的headers，如果参数为空那么不覆盖
    // 参数: _headers({})
    // 返回: this
    public Headers(_headers?: {}): this {
        if (typeof _headers === 'object') this.headers = _headers;

        return this;
    }

    // 在原有Headers基础上添加键值对
    // 参数: key(string), value(number|string)
    // 返回: this
    public HeadersAddWith(key: string, value: number | string): this {
        this.headers[key] = value;

        return this;
    }

    // 获取headers
    // 参数: void
    // 返回: this.headers
    public getHeaders(): {} {
        return this.headers;
    }

    // 设置data，覆盖原本的data，如果参数为空那么不覆盖
    // 参数: _data({})
    // 返回: this
    public Data(_data?: {}): this {
        if (typeof _data === 'object') this.data = _data;

        return this;
    }

    // 获取data
    // 参数: void
    // 返回: this.data
    public getData(): {} {
        return this.data;
    }

    // 设置method，覆盖原本的method，如果参数为空那么不覆盖
    // 参数: _method({})
    // 返回: this
    public Method(_method?: http.RequestMethod): this {
        if (typeof _method === 'object') this.method = _method;

        return this;
    }

    // 获取method
    // 参数: void
    // 返回: this.method
    public getMethod(): {} {
        return this.method;
    }
    /*-----------------------------------成员变量访问-----------------------------------*/

    // 发起OPTIONS请求并等待结果返回
    // 参数: url(string), headers(Object)
    // 返回: true | false
    protected async OptionsAsync(url: string, headers: Object) {
        let requester = http.createHttp()
        let res: http.HttpResponse = null
        try {
            res = await requester.request(url, {
                header: headers
            })
        } catch (err) {
            return false
        }
        return (res.responseCode == http.ResponseCode.NO_CONTENT || res.responseCode == http.ResponseCode.OK)
    }

    // 发起请求并等待结果返回
    // 参数: void
    // 返回: Response
    public async getResponseAsync() {
        let requester = http.createHttp()
        let hres: http.HttpResponse = null
        let res: Response = new Response()
        let query = Utils.joinParams2Url(this.url, this.params)
        let start = Date.now()
        try {
            if (this.method == http.RequestMethod.GET) {
                hres = await requester.request(query, {
                    method: http.RequestMethod.GET,
                    header: this.headers,
                    connectTimeout: 10000,
                    readTimeout: 20000
                });
            }
            else if (this.method == http.RequestMethod.POST) {
                hres = await requester.request(query, {
                    method: http.RequestMethod.POST,
                    header: this.headers,
                    connectTimeout: 10000,
                    readTimeout: 20000,
                    extraData: JSON.stringify(this.data)
                });
            }
        } catch(err) {
            // 在结果中标识请求错误信息
            res.success = false;
            res.message = `http request with error: ` + err;
            let end = Date.now();
            res.timeCost = end - start;

            requester.destroy();
            return res;
        }
        requester.destroy();
        let end = Date.now();
        res.timeCost = end - start;

        if (hres.responseCode != http.ResponseCode.OK) {
            res.success = false;
            res.code = hres.responseCode;
            res.message = `response error: ${hres.responseCode}`;
        }

        let json;
        try {
            // 尝试将结果解析为json数据并返回
            json = JSON.parse(hres.result as string);
            res.success = (json.retcode == 0);
            res.code = json.retcode;
            res.message = json.message || errorMsgMap[`${json.retcode}`];
            res.data = JSON.stringify(json.data);
        } catch (err) {
            // 返回原数据
            res.data = hres.result.toString();
        }

        return res;
    }
}

export default MihoyoAPI;