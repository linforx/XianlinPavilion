/**
 * @FileName: index
 * @Author: Administrator
 * @Date: 2023/5/23 19:03
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'index',
    url: `${Host.ApiTakumiRecord}/game_record/app/genshin/api/index`,
    params: {
        role_id: '',
        server: ''
    },
    method: http.RequestMethod.GET
}