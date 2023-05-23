/**
 * @FileName: character
 * @Author: Administrator
 * @Date: 2023/5/23 18:57
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'character',
    url: `${Host.ApiTakumiRecord}/game_record/app/genshin/api/character`,
    params: {},
    method: http.RequestMethod.POST,
    body: {
        role_id: '',
        server: ''
    }
}