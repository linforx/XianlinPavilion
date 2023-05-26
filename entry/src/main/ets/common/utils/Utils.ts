/**
 * @FileName: Utils
 * @Author: Administrator
 * @Date: 2023/5/22 20:48
 * Description:
 */

import JSMD5 from './md5'
import Logger from './Logger'
import common from '@ohos.app.ability.common'
import util from '@ohos.util'

var crypto = {
    MD5: (value: string) => JSMD5(value)
}

const chars: string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
const charsLower: string = 'abcdefghijklmnopqrstuvwxyz1234567890'

function RandomIndex(min, max, i){
    let index = Math.floor(Math.random() * (max-min+1) + min), numStart = charsLower.length - 10
    //如果字符串第一位是数字，则递归重新获取
    if(i == 0 && index >= numStart){
        index = RandomIndex(min, max, i)
    }
    //返回最终索引值
    return index
}

const getRandomString = (len: number) => {
    let min = 0, max = charsLower.length-1, _str = ''
    //判断是否指定长度，否则默认长度为15
    len = len || 15
    //循环生成字符串
    for(var i = 0, index; i < len; i++){
        index = RandomIndex(min, max, i)
        _str += charsLower[index]
    }
    return _str
}

const joinParams2Url = (host: string, params: {}) => {
    let pairs = []
    for (let key in params) {
        pairs.push(`${key}=${params[key]}`)
    }
    if (pairs.length > 0) {
        return `${host}?${pairs.join('&')}`
    }
    return host
}

const readRawfileTextAsync = async (context: common.Context, filePath: string, encoding: string = 'utf-8') => {
    let value = await context.resourceManager.getRawFileContent(filePath)
    let decoder = util.TextDecoder.create(encoding, { ignoreBOM : true })
    let retStr = decoder.decodeWithStream( value , {stream: false})

    return retStr
}

export { crypto, Logger, getRandomString, joinParams2Url, readRawfileTextAsync }