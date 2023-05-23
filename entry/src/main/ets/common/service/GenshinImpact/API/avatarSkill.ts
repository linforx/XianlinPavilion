/**
 * @FileName: avatarSkill
 * @Author: Administrator
 * @Date: 2023/5/23 19:02
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'avatarSkill',
    url: `${Host.ApiTakumi}/event/e20200928calculate/v1/avatarSkill/list`,
    params: {
        avatar_id: ''
    },
    method: http.RequestMethod.GET
}