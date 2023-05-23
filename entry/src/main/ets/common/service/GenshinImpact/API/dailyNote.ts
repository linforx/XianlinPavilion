/**
 * @FileName: dailyNote
 * @Author: Administrator
 * @Date: 2023/5/23 18:47
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'dailyNote',
    url: `${Host.ApiTakumiRecord}/game_record/app/genshin/api/dailyNote`,
    params: {
        role_id: '',
        server: ''
    },
    method: http.RequestMethod.GET
}