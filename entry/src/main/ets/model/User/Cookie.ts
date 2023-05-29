/**
 * @FileName: Cookie
 * @Author: Administrator
 * @Date: 2023/5/28 14:36
 * Description:
 */

import CookieType from '../../common/service/CookieType'

export default class Cookie {
    private cookieObj: Object = {}
    constructor(cookie: string) {
        this.cookieObj = Cookie.parseCookie(cookie)
    }

    public join(cookie: string) {
       let newCookie = Cookie.parseCookie(cookie)
        for (let key in newCookie) {
            this.cookieObj[key] = newCookie[key]
        }
    }

    public getByType(type: CookieType) {
        switch (type) {
            case CookieType.None:
                return ''
            case CookieType.CookieToken:
                return Cookie.stringifyCookie({
                    ltuid: this.cookieObj ['ltuid'],
                    account_id: this.cookieObj ['account_id'],
                    cookie_token: this.cookieObj ['cookie_token']
                })
            case CookieType.LToken:
                return Cookie.stringifyCookie({
                    ltuid: this.cookieObj ['ltuid'],
                    account_id: this.cookieObj ['account_id'],
                    ltoken: this.cookieObj ['ltoken']
                })
            case CookieType.BothCLToken:
                return Cookie.stringifyCookie({
                    ltuid: this.cookieObj ['ltuid'],
                    cookie_token: this.cookieObj ['cookie_token'],
                    account_id: this.cookieObj ['account_id'],
                    ltoken: this.cookieObj ['ltoken'],
                })
            case CookieType.SToken:
                return Cookie.stringifyCookie({
                    stuid: this.cookieObj ['stuid'],
                    stoken: this.cookieObj ['stoken'],
                    ltoken: this.cookieObj ['ltoken'],
                    cookie_token: this.cookieObj ['cookie_token']
                })
            case CookieType.All:
                return Cookie.stringifyCookie(this.cookieObj)
        }
    }

    public getByName(name: string) {
        return this.cookieObj[name] ?? ''
    }

    public static parseCookie(cookieStr: string): Object {
        let cookieJson = {}

        cookieStr.trim()
        while (cookieStr.includes('\'') || cookieStr.includes("\"")) {       // 去除引号
            cookieStr = cookieStr.replace('\'', '')
            cookieStr = cookieStr.replace("\"", '')
        }
        while (cookieStr.includes(' ')) {       // 去除空格
            cookieStr = cookieStr.replace(' ', '')
        }
        let cookies = cookieStr.split(';')
        for (let item of cookies) {
            if (item.split('=')[0]) cookieJson[item.split('=')[0]] = item.split('=')[1]
        }

        return cookieJson
    }

    public static stringifyCookie(cookieJson: Object): string {
        let str = ''
        for (let key in cookieJson) {
            str += key + '=' + cookieJson[key] + ';'
        }
        return str.trim()
    }
}