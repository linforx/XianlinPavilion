/**
 * @FileName: EnkaAPI
 * @Author: Administrator
 * @Date: 2023/5/24 18:15
 * Description:
 */

import http from '@ohos.net.http';
import common from '@ohos.app.ability.common';
import apiMap from '../../common/service/EnkaNetwork/APIMap';
import CoreEnvironment from '../../common/service/CoreEnvironment';
import Response from '../../common/service/Response';
import { losslessJSON, Logger } from '../../common/utils/Utils'
import FileManager from '../../common/utils/FileManager'

export default class EnkaAPI {
    private url: string = ''
    private static resourceCache = {
        charactersMap: {},
        localizationMap: {},
        propMap: {},
        fightPropMap: {},
        appendPropMap: {}
    }

    public applyGetGameInfo(option: { hostOption: number,diyHost?: string,uid: string }) {
        if (option.diyHost) {
            this.url = `${option.diyHost}/api/uid/${option.uid}`
        } else {
            switch (option.hostOption) {
                case 0:     // enka.network
                    this.url = `${apiMap.EnkaNetwork.url}${option.uid}`
                    break
                case 1:     // enka.microgg
                    this.url = `${apiMap.EnkaMicrogg.url}${option.uid}`
                    break
                default:
                    this.url = `${apiMap.EnkaNetwork.url}${option.uid}`
            }
        }

        return this
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
            res.message = `http request with error: ` + err.message;
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
                    res.message = '玩家不存在（原神服务器说的）'
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
        res.success = true

        return res;
    }

    public static async getCharactersMapAsync(context: common.Context) {
        if (Object.keys(this.resourceCache.charactersMap).length == 0) {
            this.resourceCache.charactersMap = losslessJSON.parse(await new FileManager(context).getRawFileTextAsync('EnkaAPIResource/characters.json'))
        }
        return this.resourceCache.charactersMap
    }

    public static async getLocalizationMapAsync(context: common.Context) {
        if (Object.keys(this.resourceCache.localizationMap).length == 0) {
            this.resourceCache.localizationMap = losslessJSON.parse(await new FileManager(context).getRawFileTextAsync('EnkaAPIResource/Loc.json'))
        }
        return this.resourceCache.localizationMap
    }

    public static async getPropMapAsync(context: common.Context) {
        if (Object.keys(this.resourceCache.propMap).length == 0) {
            this.resourceCache.propMap = losslessJSON.parse(await new FileManager(context).getRawFileTextAsync('EnkaAPIResource/PropMap.json'))
        }
        return this.resourceCache.propMap
    }

    public static async getFightPropMapAsync(context: common.Context) {
        if (Object.keys(this.resourceCache.fightPropMap).length == 0) {
            this.resourceCache.fightPropMap = losslessJSON.parse(await new FileManager(context).getRawFileTextAsync('EnkaAPIResource/FightPropMap.json'))
        }
        return this.resourceCache.fightPropMap
    }

    public static async getAppenPropMapAsync(context: common.Context) {
        if (Object.keys(this.resourceCache.appendPropMap).length == 0) {
            this.resourceCache.appendPropMap = losslessJSON.parse(await new FileManager(context).getRawFileTextAsync('EnkaAPIResource/AppendPropMap.json'))
        }
        return this.resourceCache.appendPropMap
    }
}