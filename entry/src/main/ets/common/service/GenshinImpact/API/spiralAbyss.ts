/**
 * @FileName: spiralAbyss
 * @Author: Administrator
 * @Date: 2023/5/23 19:05
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'spiralAbyss',
    url: `${Host.ApiTakumiRecord}/game_record/app/genshin/api/spiralAbyss`,
    params: {
        role_id: '',
        schedule_type: 1,
        server: ''
    },
    method: http.RequestMethod.GET
}