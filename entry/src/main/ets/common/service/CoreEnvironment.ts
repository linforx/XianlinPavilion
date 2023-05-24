/**
 * @FileName: CoreEnvironment
 * @Author: Administrator
 * @Date: 2023/5/22 21:32
 * Description:
 */

import SaltType from './SaltType';
import Configuration from '@ohos.app.ability.Configuration';
import bundleManager from '@ohos.bundle.bundleManager';

// thanks for Snap.Hutao

function getGuid() {
    function S4 () {
        return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)
    }

    return (S4() + S4() + '-' + S4() + '-' + S4() + '-' + S4() + '-' + S4() + S4() + S4())
}

export default class CoreEnvironment {
    // 米游社Rpc版本
    public static miHoYoBBSXrpcVersion: string = '2.44.1'
    public static miHoYoBBSUserAgent: string = `Mozilla/5.0 (Linux; Android 12) Mobile miHoYoBBS/${CoreEnvironment.miHoYoBBSXrpcVersion}`
    public static APPUserAgent: string = `XianlinPavilion/1.0.0`
    public static DynamicSecretSalts: Map<SaltType, string> = new Map([
        [SaltType.K2, 'dZAwGk4e9aC0MXXItkwnHamjA1x30IYw'],
        [SaltType.LK2, 'IEIZiKYaput2OCKQprNuGsog1NZc1FkS'],
        [SaltType.X4, 'xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs'],
        [SaltType.X6, 't0qEgfub6cvueAPgR5m9aQWWVciEer7v'],
        [SaltType.PROD, 'JwYDpKvLj6MrMqqYU6jTKF17KNO2PXoS']
    ])
    public static deviceId: string = getGuid()
}