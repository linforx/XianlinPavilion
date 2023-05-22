/**
 * @FileName: DynamicSecretGenerator
 * @Author: Administrator
 * @Date: 2023/5/22 21:35
 * Description:
 */

import { crypto, getRandomString } from '../utils/Utils';
import DynamicSecretVersion from './DynamicSecretVersion'
import SaltType from './SaltType'
import CoreEnvironment from './CoreEnvironment'

class DynamicSecretCreator {
    private version: DynamicSecretVersion
    private salt: string
    private query: string
    private body: string

    public constructor(version: DynamicSecretVersion = DynamicSecretVersion.V1) {
        this.version = version
        this.salt = ''
        this.query = ''
        this.body = ''
    }

    public useSalt(salt: SaltType): this {
        this.salt = CoreEnvironment.DynamicSecretSalts.get(salt)

        return this
    }

    public withParams(query: string) {
        this.query = query

        return this
    }

    public withBody(body: string) {
        this.body = body

        return this
    }

    public create(): string {
        let DS = ''
        if (this.version == DynamicSecretVersion.V1) {
            let randStr = getRandomString(6)
            let timeStamp = Math.floor(Date.now() / 1000)
            let sign = crypto.MD5(`salt=${this.salt}&t=${timeStamp}&r=${randStr}`)
            DS = `${timeStamp},${randStr},${sign}`
        }
        else if (this.version == DynamicSecretVersion.V2) {
            let t = Math.round(new Date().getTime() / 1000)
            let r = Math.floor(Math.random() * 900000 + 100000)
            let sign = crypto.MD5(`salt=${this.salt}&t=${t}&r=${r}&b=${this.body}&q=${this.query}`)
            DS = `${t},${r},${sign}`
        }

        return DS
    }
}

export default DynamicSecretCreator