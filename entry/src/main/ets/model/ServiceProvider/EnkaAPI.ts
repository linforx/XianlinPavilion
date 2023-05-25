/**
 * @FileName: EnkaAPI
 * @Author: Administrator
 * @Date: 2023/5/24 18:15
 * Description:
 */

import http from '@ohos.net.http';
import apiMap from '../../common/service/EnkaNetwork/APIMap';
import CoreEnvironment from '../../common/service/CoreEnvironment';
import Utils from '../../common/utils/Utils';
import Response from '../../common/service/Response';

export default class enkaAPI {
    private url: string = ''

    public applyGetGameInfo(config: { hostOption: number, diyHost?: string, uid: string }) {
        if (config.diyHost) {
            this.url = `${config.diyHost}/api/uid/${config.uid}`
        } else {
            switch (config.hostOption) {
                case 0:     // enka.network
                    this.url = `${apiMap.EnkaNetwork}${config.uid}`
                    break
                case 1:     // enka.microgg
                    this.url = `${apiMap.EnkaMicrogg}${config.uid}`
                    break
                default:
                    this.url = `${apiMap.EnkaNetwork}${config.uid}`
            }
        }
    }

    public async getResponseAsync() {
        let requester = http.createHttp()
        let hres: http.HttpResponse = null
        let res: Response = new Response()
        let start = Date.now()
        try {
            hres = await requester.request(this.url, {
                method: http.RequestMethod.GET,
                header: { 'User-Agent': `${CoreEnvironment.APPUserAgent}` },
                connectTimeout: 10000,
                readTimeout: 20000
            });
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
            switch(Number(hres.responseCode)) {
                case 400:
                    res.message = 'UID 格式错误'
                    break
                case 404:
                    res.message = '玩家不存在（MHY 服务器说的）'
                    break
                case 424:
                    res.message = '面板服务维护中'
                    break
                case 429:
                    res.message = '请求过快'
                    break
                case 500:
                    res.message = '服务器错误'
                    break
                case 503:
                    res.message = '面板服务器崩溃'
                    break
                default:
                    res.message = '未知错误'
            }
        }

        res.data = hres.result.toString();

        return res;
    }

}