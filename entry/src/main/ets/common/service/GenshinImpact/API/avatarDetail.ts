/**
 * @FileName: avatarDetail
 * @Author: Administrator
 * @Date: 2023/5/23 18:57
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'detail',
    url: `${Host.ApiTakumi}/event/e20200928calculate/v1/sync/avatar/detail`,
    params: {
        uid: '',
        region: '',
        avatar_id: ''
    },
    method: http.RequestMethod.GET
}