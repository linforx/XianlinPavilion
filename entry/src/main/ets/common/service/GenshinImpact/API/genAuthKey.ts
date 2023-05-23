/**
 * @FileName: genAuthKey
 * @Author: Administrator
 * @Date: 2023/5/23 18:58
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'genAuthKey',
    url: `${Host.ApiTakumi}/binding/api/genAuthKey`,
    params: {},
    method: http.RequestMethod.POST,
    body: {
        'auth_appid': 'webview_gacha',
        'game_biz': '',
        'game_uid': '',
        'region': ''
    }
}