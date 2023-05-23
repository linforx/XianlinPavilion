/**
 * @FileName: gachaLog
 * @Author: Administrator
 * @Date: 2023/5/23 19:00
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'gachaLog',
    url: `${Host.Hk4eApi}/event/gacha_info/api/getGachaLog`,
    params: {
        authkey_ver: 1,
        sign_type: 2,
        lang: 'zh-cn',
        region: '',
        authkey: '',
        game_biz: '',
        gacha_type: 301,
        page: 1,
        size: 20,
        end_id: 0
    },
    method: http.RequestMethod.GET
}